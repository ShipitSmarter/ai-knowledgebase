/**
 * Session Title Plugin
 * 
 * Automatically generates session titles following conventional commit style:
 * - PR reviews: "review PR #123"
 * - Development: "fix(scope): description", "feat(scope): description", etc.
 * 
 * Only generates title once per session (when title is not set).
 * Uses OpenCode's unified auth - works with any configured provider.
 */

import type { Plugin } from "@opencode-ai/plugin"

interface OpenCodeClient {
  session: {
    messages: (params: { path: { id: string } }) => Promise<any>
    update: (params: { path: { id: string }, body: { title: string } }) => Promise<any>
    get: (params: { path: { id: string } }) => Promise<any>
  }
  app: {
    log: (params: { service: string, level: string, message: string, extra?: any }) => Promise<any>
  }
}

interface MessagePart {
  type: string
  text?: string
  synthetic?: boolean
}

interface Message {
  info: {
    id: string
    role: "user" | "assistant" | "system"
    sessionID: string
  }
  parts: MessagePart[]
}

// Track sessions we've already titled to avoid re-processing
const titledSessions = new Set<string>()

// Fallback models in priority order (cheap/fast models for title generation)
const FALLBACK_MODELS: Record<string, string> = {
  openai: 'gpt-4o-mini',
  anthropic: 'claude-haiku-4-5',
  google: 'gemini-2.0-flash',
  deepseek: 'deepseek-chat',
  opencode: 'big-pickle'
}

const PROVIDER_PRIORITY = ['openai', 'anthropic', 'google', 'deepseek', 'opencode']

const TITLE_PROMPT = `You are a session title generator for a development assistant. Output ONLY the title, nothing else.

<format>
Generate titles following conventional commit style:

For PR reviews (when user mentions PR, pull request, or review):
- "review PR #123" (extract the PR number)

For development work:
- fix(scope): brief description - for bug fixes
- feat(scope): brief description - for new features  
- refactor(scope): brief description - for refactoring
- docs(scope): brief description - for documentation
- test(scope): brief description - for tests
- chore(scope): brief description - for maintenance

The scope should be the component, file, or area being worked on.
</format>

<rules>
- Maximum 50 characters total
- Extract scope from filenames, components, or features mentioned
- If unclear, use a general scope like "app", "api", "ui"
- Focus on what the user is trying to accomplish
- No quotes around the output
- No explanations, just the title
</rules>

<examples>
User asks to review PR #456 -> review PR #456
User fixing type error in input component -> fix(input): type error
User adding OAuth to auth module -> feat(auth): add OAuth support
User refactoring rates calculation -> refactor(rates): simplify calculation
User updating API docs -> docs(api): update endpoints
User writing tests for cart -> test(cart): add unit tests
User updating dependencies -> chore(deps): update packages
</examples>`

function extractTextOnly(parts: MessagePart[]): string {
  return parts
    .filter(part => part.type === "text" && !part.synthetic)
    .map(part => part.text || '')
    .join("\n")
    .trim()
}

async function getFirstUserMessage(
  client: OpenCodeClient,
  sessionId: string
): Promise<string | null> {
  try {
    const { data: messages } = await client.session.messages({
      path: { id: sessionId }
    })

    const userMessage = messages.find((msg: Message) => msg.info.role === "user")
    if (!userMessage) return null

    return extractTextOnly(userMessage.parts)
  } catch {
    return null
  }
}

async function hasExistingTitle(
  client: OpenCodeClient,
  sessionId: string
): Promise<boolean> {
  try {
    const result = await client.session.get({ path: { id: sessionId } })
    // Check if title exists and is not empty/default
    const title = result.data?.title
    return !!(title && title.trim() && !title.startsWith("Session"))
  } catch {
    return false
  }
}

async function isSubagentSession(
  client: OpenCodeClient,
  sessionId: string
): Promise<boolean> {
  try {
    const result = await client.session.get({ path: { id: sessionId } })
    return !!result.data?.parentID
  } catch {
    return false
  }
}

function cleanTitle(raw: string): string {
  // Remove thinking tags if present
  let cleaned = raw.replace(/<think>[\s\S]*?<\/think>\s*/g, "")
  
  // Get first non-empty line
  const lines = cleaned.split("\n").map(line => line.trim())
  cleaned = lines.find(line => line.length > 0) || "Untitled"
  
  // Remove quotes if wrapped
  cleaned = cleaned.replace(/^["']|["']$/g, "")
  
  // Truncate if too long
  if (cleaned.length > 50) {
    cleaned = cleaned.substring(0, 47) + "..."
  }
  
  return cleaned
}

async function generateTitle(
  userMessage: string,
  client: OpenCodeClient
): Promise<string | null> {
  try {
    // Lazy import auth provider
    const { OpencodeAI } = await import('@tarquinen/opencode-auth-provider')
    const { generateText } = await import('ai')
    
    const opencodeAI = new OpencodeAI()
    const providers = await opencodeAI.listProviders()
    const availableProviderIDs = Object.keys(providers)
    
    // Find first available provider from priority list
    let model = null
    for (const providerID of PROVIDER_PRIORITY) {
      if (!providers[providerID]) continue
      
      const modelID = FALLBACK_MODELS[providerID]
      if (!modelID) continue
      
      try {
        model = await opencodeAI.getLanguageModel(providerID, modelID)
        break
      } catch {
        continue
      }
    }
    
    if (!model) {
      throw new Error('No available models')
    }
    
    const result = await generateText({
      model,
      messages: [
        {
          role: 'user',
          content: `${TITLE_PROMPT}\n\n<user_message>\n${userMessage.substring(0, 1000)}\n</user_message>\n\nOutput the title now:`
        }
      ],
      maxTokens: 50
    })

    return cleanTitle(result.text)
  } catch (error) {
    // Fallback: try to extract a simple title from the message
    const prMatch = userMessage.match(/PR\s*#?(\d+)|pull\s*request\s*#?(\d+)/i)
    if (prMatch) {
      return `review PR #${prMatch[1] || prMatch[2]}`
    }
    return null
  }
}

export const SessionTitlePlugin: Plugin = async (ctx) => {
  const { client } = ctx

  await client.app.log({
    service: "session-title",
    level: "info",
    message: "Session Title plugin initialized"
  })

  return {
    event: async ({ event }) => {
      // @ts-ignore - session.status event type
      if (event.type === "session.status" && event.properties.status.type === "idle") {
        // @ts-ignore
        const sessionId = event.properties.sessionID

        // Skip if we've already titled this session
        if (titledSessions.has(sessionId)) {
          return
        }

        // Skip subagent sessions
        if (await isSubagentSession(client, sessionId)) {
          titledSessions.add(sessionId) // Mark to skip future checks
          return
        }

        // Skip if session already has a meaningful title
        if (await hasExistingTitle(client, sessionId)) {
          titledSessions.add(sessionId)
          return
        }

        // Get the first user message for context
        const userMessage = await getFirstUserMessage(client, sessionId)
        if (!userMessage) {
          return
        }

        // Generate title
        const title = await generateTitle(userMessage, client)
        if (!title) {
          return
        }

        // Update session
        try {
          await client.session.update({
            path: { id: sessionId },
            body: { title }
          })

          titledSessions.add(sessionId)

          await client.app.log({
            service: "session-title",
            level: "info",
            message: `Session titled: ${title}`,
            extra: { sessionId }
          })
        } catch (error: any) {
          await client.app.log({
            service: "session-title",
            level: "error",
            message: `Failed to update title: ${error.message}`,
            extra: { sessionId }
          })
        }
      }
    }
  }
}
