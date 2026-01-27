/**
 * AI Attribution Plugin for OpenCode
 * 
 * Automatically sets environment variables for AI commit attribution when
 * OpenCode modifies files. Works with the git hooks installed by setup.sh.
 * 
 * Environment variables set:
 * - AI_ASSISTED=1
 * - AI_MODEL=<model being used>
 * - AI_TOOL=opencode
 * - AI_SESSION_ID=<session timestamp>
 * - AI_CONTRIBUTION=partial
 * - AI_FILES_TOUCHED=<comma-separated list of modified files>
 * 
 * The git hooks (prepare-commit-msg and post-commit) use these to add
 * trailers and notes to commits.
 */

import type { Plugin } from "@opencode-ai/plugin"

// Track files modified in this session
let filesModified: Set<string> = new Set()
let sessionStartTime: string | null = null

export const AIAttributionPlugin: Plugin = async ({ client }) => {
  
  // Helper to set environment variable
  const setEnv = (key: string, value: string) => {
    process.env[key] = value
  }
  
  // Initialize session tracking
  const initSession = async (sessionId: string) => {
    if (!sessionStartTime) {
      // Format: YYYYMMDD-HHMMSS-sessionId (last 8 chars)
      const now = new Date()
      const datePart = now.toISOString().slice(0, 10).replace(/-/g, '')
      const timePart = now.toTimeString().slice(0, 8).replace(/:/g, '')
      const sessionPart = sessionId.slice(-8)
      sessionStartTime = `${datePart}-${timePart}-${sessionPart}`
      
      setEnv('AI_ASSISTED', '1')
      setEnv('AI_TOOL', 'opencode')
      setEnv('AI_SESSION_ID', sessionStartTime)
      setEnv('AI_CONTRIBUTION', 'partial')
      
      await client.app.log({
        service: 'ai-attribution',
        level: 'info',
        message: `AI attribution session started: ${sessionStartTime}`,
      })
    }
  }
  
  // Update files touched
  const trackFile = (filePath: string) => {
    filesModified.add(filePath)
    setEnv('AI_FILES_TOUCHED', Array.from(filesModified).join(','))
  }
  
  return {
    // Handle various events (session lifecycle, messages)
    event: async ({ event }) => {
      if (event.type === 'session.created') {
        // Reset tracking for new session
        filesModified = new Set()
        sessionStartTime = null
      }
      
      if (event.type === 'session.deleted') {
        // Clean up when session ends
        filesModified = new Set()
        sessionStartTime = null
      }
      
      // Track model being used when messages are updated
      if (event.type === 'message.updated') {
        const message = (event as { type: string; message?: { model?: string } }).message
        if (message?.model) {
          // Extract model name (e.g., "anthropic/claude-opus-4.5" -> "claude-opus-4.5")
          const modelName = message.model.split('/').pop() || message.model
          setEnv('AI_MODEL', modelName)
        }
      }
    },
    
    // Track file modifications via edit/write tools
    'tool.execute.after': async (input, output) => {
      // Only track successful file modifications
      if (input.tool === 'edit' || input.tool === 'write') {
        const filePath = input.args?.filePath || input.args?.path
        if (filePath && !output.error) {
          // Initialize session on first file modification
          await initSession(input.sessionID || 'unknown')
          trackFile(filePath)
          
          await client.app.log({
            service: 'ai-attribution',
            level: 'debug',
            message: `Tracked file modification: ${filePath}`,
          })
        }
      }
    },
  }
}

// Default export for OpenCode to load
export default AIAttributionPlugin
