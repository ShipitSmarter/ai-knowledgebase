import type { Plugin } from "@opencode-ai/plugin"

/**
 * Auto Session Name Plugin
 *
 * Automatically generates meaningful session names based on the first user message.
 * Uses pattern matching (no external dependencies).
 * 
 * Naming conventions:
 * - PR Reviews: "review PR #123"
 * - Development: "fix(scope): description", "feat(scope): description", etc.
 */

const NAMING_PATTERNS: Array<{
  pattern: RegExp
  format: (match: RegExpMatchArray) => string
}> = [
  // PR Reviews - look for PR URLs or "review PR" mentions
  {
    pattern: /github\.com\/[\w-]+\/[\w-]+\/pull\/(\d+)/i,
    format: (match) => `review PR #${match[1]}`,
  },
  {
    pattern: /(?:review|check|look at).*?(?:pr|pull request)\s*#?(\d+)/i,
    format: (match) => `review PR #${match[1]}`,
  },
  // GitHub Issues
  {
    pattern: /github\.com\/[\w-]+\/[\w-]+\/issues\/(\d+)/i,
    format: (match) => `issue #${match[1]}`,
  },
  // Fix patterns
  {
    pattern: /(?:fix|bug|broken|error|issue with|problem with)\s+(?:the\s+)?(.{10,40})/i,
    format: (match) => `fix: ${match[1].trim().slice(0, 35).toLowerCase()}`,
  },
  // Feature patterns
  {
    pattern: /(?:add|create|implement|build|make)\s+(?:a\s+)?(?:new\s+)?(.{10,40})/i,
    format: (match) => `feat: ${match[1].trim().slice(0, 35).toLowerCase()}`,
  },
  // Refactor patterns
  {
    pattern: /(?:refactor|clean up|reorganize|restructure)\s+(.{10,40})/i,
    format: (match) => `refactor: ${match[1].trim().slice(0, 30).toLowerCase()}`,
  },
  // Test patterns
  {
    pattern: /(?:test|write tests?|add tests?)\s+(?:for\s+)?(.{10,40})/i,
    format: (match) => `test: ${match[1].trim().slice(0, 35).toLowerCase()}`,
  },
  // Docs patterns
  {
    pattern: /(?:document|update docs?|write docs?)\s+(?:for\s+)?(.{10,40})/i,
    format: (match) => `docs: ${match[1].trim().slice(0, 35).toLowerCase()}`,
  },
  // Debug patterns
  {
    pattern: /(?:debug|investigate|figure out|why)\s+(.{10,40})/i,
    format: (match) => `debug: ${match[1].trim().slice(0, 35).toLowerCase()}`,
  },
  // Explore patterns
  {
    pattern: /(?:how does?|explain|what is|explore|understand)\s+(.{10,40})/i,
    format: (match) => `explore: ${match[1].trim().slice(0, 32).toLowerCase()}`,
  },
]

function generateSessionName(userMessage: string): string | null {
  const normalized = userMessage.replace(/\s+/g, " ").trim()

  for (const { pattern, format } of NAMING_PATTERNS) {
    const match = normalized.match(pattern)
    if (match) {
      return format(match).replace(/\s+/g, " ").trim().slice(0, 50)
    }
  }

  return null
}

export const AutoSessionNamePlugin: Plugin = async ({ client }) => {
  const processedSessions = new Set<string>()

  return {
    event: async ({ event }) => {
      if (event.type !== "session.idle") return

      const sessionId = (event as any).properties?.sessionID
      if (!sessionId || processedSessions.has(sessionId)) return

      processedSessions.add(sessionId)

      try {
        const session = await client.session.get({ path: { id: sessionId } })
        if (!session.data) return

        // Skip subagent sessions
        if (session.data.parentID) return

        // Skip if already has a meaningful title
        const currentTitle = session.data.title || ""
        const isDefaultTitle =
          !currentTitle ||
          /^\d{4}-\d{2}-\d{2}/.test(currentTitle) ||
          /^New Session/i.test(currentTitle) ||
          currentTitle.length < 5

        if (!isDefaultTitle) return

        const messages = await client.session.messages({ path: { id: sessionId } })
        if (!messages.data || messages.data.length === 0) return

        const firstUserMessage = messages.data.find((m: any) => m.info.role === "user")
        if (!firstUserMessage) return

        const textParts = firstUserMessage.parts
          .filter((p: any) => p.type === "text" && !p.synthetic)
          .map((p: any) => p.text || "")
          .join("\n")

        if (!textParts || textParts.length < 10) return

        const newTitle = generateSessionName(textParts)
        if (!newTitle) return

        await client.session.update({
          path: { id: sessionId },
          body: { title: newTitle },
        })
      } catch {
        // Silently ignore errors
      }
    },
  }
}

export default AutoSessionNamePlugin
