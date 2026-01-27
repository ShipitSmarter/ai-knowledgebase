---
topic: Astro Houston CLI Assistant Implementation
date: 2026-01-23
project: cli-design
sources_count: 8
status: final
tags: [cli, npm, create-astro, houston, ux, character-design, interactive-cli]
---

# Astro Houston CLI: How `npm create astro@latest` Creates an Interactive Character

## Summary

Astro's `create-astro` CLI features "Houston", an animated ASCII character that greets users with personality during project scaffolding. This research examines how Astro implements this experience, breaking down the architecture into: **package structure**, **character rendering**, **animation system**, and **seasonal customization**.

The implementation is split across two packages:
1. **`create-astro`** - The main scaffolding CLI (in the monorepo at `packages/create-astro`)
2. **`@astrojs/cli-kit`** - A reusable CLI component library (separate repo: `withastro/cli-kit`)

This separation allows the interactive prompts, spinner, and Houston character to be reused across other Astro tools.

## Key Findings

### 1. Package Architecture

When users run `npm create astro@latest`:

```
npm create astro@latest
        │
        ▼
create-astro (bin: create-astro.mjs)
        │
        ├── @astrojs/cli-kit (say, prompt, spinner, label, color)
        │       └── log-update (terminal animation)
        │       └── chalk (colors)
        │       └── sisteransi (ANSI escape codes)
        │
        └── @bluwy/giget-core (template downloading)
```

**Key files:**
- `packages/create-astro/package.json` - defines `bin.create-astro`
- `packages/create-astro/src/index.ts` - main entry point orchestrating steps
- `packages/create-astro/src/messages.ts` - wraps cli-kit's `say` function
- `packages/create-astro/src/actions/*.ts` - individual wizard steps

### 2. Houston Character Rendering

The Houston character is rendered via the `say()` function in `@astrojs/cli-kit`. Here's the core rendering logic:

```typescript
// From @astrojs/cli-kit/src/messages/index.ts
const face = (msg: string, { mouth = mouths[0], eye = eyes[0] } = {}) => {
    const [h, v] = walls;        // '─', '│'
    const [tl, tr, bl, br] = corners;  // '╭', '╮', '╰', '╯'
    const head = h.repeat(3 - strip(hat).split('').length);
    const bottom = h.repeat(3 - strip(tie).split('').length);
    return [
        `${tl}${h.repeat(2)}${hat}${head}${tr}  ${color.bold(color.cyan('Houston:'))}`,
        `${v} ${eye} ${color.cyanBright(mouth)} ${eye}  ${msg}`,
        `${bl}${h.repeat(2)}${tie}${bottom}${br}`,
    ].join('\n')
};
```

This produces output like:
```
╭─────╮  Houston:
│ ● ◡ ●  Welcome to astro v5.16.15, Wouter!
╰─────╯
```

**Character variations:**
- **Eyes**: `['●', '●', '●', '●', '●', '○', '○', '•']` (randomly cycles)
- **Mouths**: `['•', '○', '■', '▪', '▫', '▬', '▭', '-', '○']` (randomly cycles during animation)
- **ASCII fallback** (Windows): `['•', '•', 'o', 'o', '•', 'O', '^', '•']` for eyes, `['•', 'O', '*', 'o', 'o', '•', '-']` for mouths

### 3. Typing Animation System

Houston doesn't just display text—it "types" word-by-word with animated facial expressions:

```typescript
for (let word of [''].concat(_message)) {
    word = await word;
    if (word) msg.push(word);
    const mouth = random(mouths);  // Change mouth each word
    if (j % 7 === 0) eye = random(eyes);  // Change eyes every 7 words
    logUpdate('\n' + face(msg.join(' '), { mouth, eye }));
    if (!cancelled) await sleep(randomBetween(75, 200));  // Variable typing speed
    j++;
}
```

**Key techniques:**
- Uses `log-update` to rewrite the same terminal lines (no flicker)
- Random delays between 75-200ms per word create natural typing feel
- Face changes during typing, then settles to a "happy" expression: `◠ ◡ ◠`
- Supports skipping animation via any keypress (respects user impatience)

### 4. Seasonal Customization

Houston wears seasonal accessories! The `getSeasonalHouston()` function adds contextual flair:

```typescript
// From create-astro/src/data/seasonal.ts
switch (season) {
    case 'spooky':  // October after 7th
        return {
            hats: rarity(0.5, ['🎃', '👻', '☠️', '💀', '🕷️', '🔮']),
            ties: rarity(0.25, ['🦴', '🍬', '🍫']),
            messages: [`Boo! Just kidding. Let's make a website!`, ...],
        };
    case 'holiday':  // December 8-24
        return {
            hats: rarity(0.75, ['🎁', '🎄', '🌲']),
            ties: rarity(0.75, ['🧣']),
            messages: [`'Tis the season to code and create.`, ...],
        };
    case 'new-year':  // January 1-7
        return {
            hats: rarity(0.5, ['🎩']),
            ties: rarity(0.25, ['🎊', '🎀', '🎉']),
            messages: [`New year, new Astro site!`, ...],
        };
}
```

The `rarity()` function pads arrays with empty strings to make decorations appear less frequently:
```typescript
// 50% chance of hat appearing
rarity(0.5, ['🎃']) // Returns ['🎃', '']
```

### 5. Personalization

Houston greets users by name, detected via:
```typescript
export const getUserName = () => new Promise<string>((resolve) => {
  exec('git config user.name', { encoding: 'utf-8' }, (err, stdout) => {
    if (stdout.trim()) {
        return resolve(stdout.split(' ')[0].trim());  // First name only
    }
    exec('whoami', { encoding: 'utf-8' }, (err, stdout) => {
        if (stdout.trim()) {
            return resolve(stdout.split(' ')[0].trim());
        }
        return resolve('astronaut');  // Fallback
    });
  });
});
```

### 6. Skip Mechanism

Houston can be skipped for CI/CD or users who prefer quiet mode:
- `--skip-houston` flag
- `--yes` or `--no` flags (auto-skip)
- Windows without `--fancy` flag (ASCII art looks poor, so skipped by default)
- Any keypress during animation skips to end

```typescript
skipHouston =
    ((os.platform() === 'win32' && !fancy) || skipHouston) ??
    [yes, no, install, git].some((v) => v !== undefined);
```

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                       npm create astro@latest                 │
└──────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                        create-astro                           │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ index.ts - Orchestrates steps:                         │  │
│  │   verify → intro → projectName → template → deps → git │  │
│  └────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ actions/context.ts                                     │  │
│  │   - Parses CLI args                                    │  │
│  │   - Detects package manager                            │  │
│  │   - Gets username, version                             │  │
│  │   - Loads seasonal data (hats, ties, messages)         │  │
│  └────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ messages.ts - Wrapper for cli-kit                      │  │
│  │   - say(messages, { hat, tie })                        │  │
│  │   - banner(), info(), error(), nextSteps()             │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                       @astrojs/cli-kit                        │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ messages/index.ts - Houston character                  │  │
│  │   - say() function renders animated face               │  │
│  │   - Handles keypress to skip                           │  │
│  │   - Uses log-update for smooth animation               │  │
│  └────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ prompt/prompt.ts - Interactive prompts                 │  │
│  │   - text, select, multiselect, confirm                 │  │
│  └────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ spinner/index.ts - Loading spinners                    │  │
│  └────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ utils/index.ts - Helpers                               │  │
│  │   - sleep(), random(), useAscii(), align()             │  │
│  │   - getUserName(), getAstroVersion()                   │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

## Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| `@astrojs/cli-kit` | Houston, prompts, spinners | ^0.4.1 |
| `@bluwy/giget-core` | Template downloading | ^0.1.6 |
| `chalk` | Terminal colors | ^5.0.1 |
| `log-update` | Smooth terminal animation | ^5.0.1 |
| `sisteransi` | ANSI escape codes | ^1.0.5 |
| `arg` | CLI argument parsing | ^5.0.2 |

## Sources

| Source | Contribution |
|--------|-------------|
| [withastro/astro](https://github.com/withastro/astro) | Main monorepo |
| [packages/create-astro/package.json](https://github.com/withastro/astro/blob/main/packages/create-astro/package.json) | Package structure |
| [packages/create-astro/src/index.ts](https://github.com/withastro/astro/blob/main/packages/create-astro/src/index.ts) | Main CLI flow |
| [packages/create-astro/src/messages.ts](https://github.com/withastro/astro/blob/main/packages/create-astro/src/messages.ts) | CLI messaging wrapper |
| [packages/create-astro/src/actions/context.ts](https://github.com/withastro/astro/blob/main/packages/create-astro/src/actions/context.ts) | Context/config setup |
| [packages/create-astro/src/data/seasonal.ts](https://github.com/withastro/astro/blob/main/packages/create-astro/src/data/seasonal.ts) | Seasonal decorations |
| [withastro/cli-kit](https://github.com/withastro/cli-kit) | Reusable CLI components |
| [cli-kit/src/messages/index.ts](https://github.com/withastro/cli-kit/blob/main/src/messages/index.ts) | Houston character rendering |
| [cli-kit/src/utils/index.ts](https://github.com/withastro/cli-kit/blob/main/src/utils/index.ts) | Utility functions |

## Key Takeaways for CLI Design

1. **Separate reusable components** - cli-kit is a standalone package usable by other tools
2. **Progressive enhancement** - ASCII fallback for Windows, skip option for CI
3. **Personality through animation** - Word-by-word typing with facial changes creates character
4. **Contextual delight** - Seasonal themes show attention to detail
5. **Respect user time** - Any keypress skips animation, `--yes` skips interaction entirely
6. **Personalization** - Greeting by name (from git/whoami) creates connection
7. **Clear information architecture** - Banner → Houston greeting → Steps → Next steps

## Questions for Further Research

- [ ] How do other CLI tools (Vite, Next.js, SvelteKit) approach interactive scaffolding?
- [ ] What accessibility considerations exist for animated CLI output?
- [ ] How does the `log-update` library handle terminal resize during animation?
- [ ] Performance impact of the animation on slow terminals?
