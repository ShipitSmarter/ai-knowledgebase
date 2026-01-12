# Google AI Search Plugin

Use Google's AI Mode (SGE - Search Generative Experience) as a search tool in OpenCode. No API key required - uses browser automation.

## Overview

- **Repository**: `IgorWarzocha/Opencode-Google-AI-Search-Plugin`
- **Method**: Playwright browser automation
- **Tool Name**: `google_ai_search_plus`
- **Advantage**: Access to Google's AI-synthesized answers with source citations

## Installation

### 1. Install Playwright

```bash
# Install Playwright
npm install -g playwright

# Install Chromium browser
npx playwright install chromium
```

### 2. Clone and Build Plugin

```bash
# Create plugins directory
mkdir -p ~/.opencode/plugins
cd ~/.opencode/plugins

# Clone the repository
git clone https://github.com/IgorWarzocha/Opencode-Google-AI-Search-Plugin.git opencode-google-ai-search

# Install dependencies and build
cd opencode-google-ai-search
npm install
npm run build
```

### 3. Configure OpenCode

Add to `.opencode/config.json`:

```json
{
  "mcpServers": {
    "google-ai-search": {
      "command": "node",
      "args": ["${HOME}/.opencode/plugins/opencode-google-ai-search/dist/index.js"],
      "env": {}
    }
  }
}
```

## Usage

The plugin provides the `google_ai_search_plus` tool:

```javascript
google_ai_search_plus({
  query: "best practices for React Server Components 2025"
})
```

### Response Format

```json
{
  "aiOverview": "React Server Components allow you to...",
  "sources": [
    {
      "title": "React Documentation",
      "url": "https://react.dev/reference/...",
      "snippet": "Server Components are a new type..."
    }
  ],
  "relatedQuestions": [
    "How do Server Components differ from Client Components?",
    "When should I use Server Components?"
  ]
}
```

## How It Works

1. Launches headless Chromium browser
2. Navigates to Google with AI Mode enabled
3. Executes search query
4. Waits for AI-generated response
5. Extracts and returns structured response with sources

## Configuration Options

Create `~/.opencode/plugins/opencode-google-ai-search/config.json`:

```json
{
  "headless": true,
  "timeout": 30000,
  "userAgent": "Mozilla/5.0 ...",
  "locale": "en-US",
  "viewport": {
    "width": 1280,
    "height": 720
  }
}
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `headless` | Run browser without UI | `true` |
| `timeout` | Max wait time (ms) | `30000` |
| `locale` | Search locale | `en-US` |
| `viewport` | Browser viewport size | `1280x720` |

## Comparison: Google AI Search vs Brave Search

| Feature | Google AI Search | Brave Search |
|---------|------------------|--------------|
| API Key | Not required | Required |
| Response Type | AI-synthesized | Traditional results |
| Source Quality | Google's full index | Brave's independent index |
| Rate Limits | Browser-based | API limits apply |
| Speed | Slower (browser) | Faster (API) |
| Reliability | May break with UI changes | Stable API |

## Best Practices

1. **Use for Complex Queries**: Best for questions needing synthesis
2. **Fallback Strategy**: Keep Brave Search as backup for simple lookups
3. **Rate Limiting**: Add delays between searches to avoid blocks
4. **Cache Results**: Store responses in opencode-mem for repeated queries

## Troubleshooting

### Browser Launch Fails
```bash
# Reinstall Chromium
npx playwright install chromium --force

# Check for missing dependencies (Linux)
npx playwright install-deps chromium
```

### Search Blocked
- Google may block automated requests
- Try increasing delays between searches
- Consider using a different user agent

### AI Mode Not Loading
- Google AI Mode availability varies by region
- Try setting different locale
- May require Google account (not currently supported)

### Timeout Errors
- Increase `timeout` in config
- Check internet connection
- AI responses can take 10-20 seconds

## Updating

```bash
cd ~/.opencode/plugins/opencode-google-ai-search
git pull
npm install
npm run build
```

## Alternatives

If Google AI Search is unreliable:

1. **Brave Search MCP**: Traditional search with API
2. **Perplexity MCP**: AI search with API (requires subscription)
3. **Tavily MCP**: AI search API designed for agents

## Resources

- [Plugin Repository](https://github.com/IgorWarzocha/Opencode-Google-AI-Search-Plugin)
- [Playwright Documentation](https://playwright.dev/)
- [Google AI Mode Info](https://blog.google/products/search/google-search-ai-mode/)
