# Plan: Building an Interactive CLI with Character Personality

Based on research into Astro's Houston CLI assistant implementation.

**Implementation**: See `tools/setup.sh` for our "Trucky" mascot - a delivery truck that "ships" AI skills.

## Overview

This plan outlines how to build a CLI tool with an animated character assistant (like Astro's Houston) that creates a memorable, delightful user experience while remaining practical for CI/CD and power users.

## Architecture Decision

### Two-Package Approach (Recommended)

Split into two packages for reusability:

```
your-org/
├── create-your-tool/          # Main CLI package
│   ├── src/
│   │   ├── index.ts           # Entry point, step orchestration
│   │   ├── actions/           # Individual wizard steps
│   │   │   ├── context.ts     # CLI args, config, personalization
│   │   │   ├── intro.ts       # Character greeting
│   │   │   ├── prompts.ts     # User input collection
│   │   │   └── next-steps.ts  # Post-completion guidance
│   │   ├── messages.ts        # Wrapper for cli-kit
│   │   └── data/
│   │       └── seasonal.ts    # Seasonal customization (optional)
│   └── package.json
│
└── cli-kit/                   # Reusable CLI components
    ├── src/
    │   ├── index.ts           # Exports: say, prompt, spinner, color, label
    │   ├── character/         # Your character implementation
    │   │   └── index.ts       # Character rendering + animation
    │   ├── prompt/            # Interactive prompts
    │   └── utils/             # Helpers: sleep, random, useAscii
    └── package.json
```

**Why two packages?**
- Reuse character/prompts across multiple CLI tools
- Smaller bundle for the main CLI
- Independent versioning

## Implementation Steps

### Phase 1: Core CLI Infrastructure

#### 1.1 Package Setup

```json
// create-your-tool/package.json
{
  "name": "create-your-tool",
  "type": "module",
  "bin": {
    "create-your-tool": "./dist/index.js"
  },
  "dependencies": {
    "@your-org/cli-kit": "workspace:*",
    "arg": "^5.0.2"
  }
}
```

#### 1.2 Entry Point Pattern

```typescript
// src/index.ts
import { tasks } from '@your-org/cli-kit';
import { getContext } from './actions/context.js';
import { intro } from './actions/intro.js';
import { projectName } from './actions/project-name.js';
import { template } from './actions/template.js';
import { next } from './actions/next-steps.js';

const exit = () => process.exit(0);
process.on('SIGINT', exit);
process.on('SIGTERM', exit);

export async function main() {
  console.log(''); // Spacing after npm output
  
  const ctx = await getContext(process.argv.slice(2));
  
  if (ctx.help) {
    printHelp();
    return;
  }

  // Execute steps in order
  const steps = [intro, projectName, template];
  for (const step of steps) {
    await step(ctx);
  }

  // Run collected tasks
  await tasks({ start: 'Setting up...', end: 'Done!' }, ctx.tasks);
  
  await next(ctx);
  process.exit(0);
}
```

### Phase 2: Character Implementation

#### 2.1 Character Rendering

```typescript
// cli-kit/src/character/index.ts
import readline from 'node:readline';
import color from 'chalk';
import { createLogUpdate } from 'log-update';
import { random, randomBetween, sleep, useAscii } from '../utils/index.js';

// Character parts - customize these for your brand
const EYES_UNICODE = ['●', '●', '●', '○', '○', '•'];
const EYES_ASCII = ['o', 'o', 'O', '*', '.'];
const MOUTHS_UNICODE = ['◡', '○', '▪', '▫', '-'];
const MOUTHS_ASCII = ['u', 'o', '-', '.'];

const WALLS_UNICODE = ['─', '│'];
const WALLS_ASCII = ['—', '|'];
const CORNERS_UNICODE = ['╭', '╮', '╰', '╯'];
const CORNERS_ASCII = ['+', '+', '+', '+'];

export async function say(
  messages: string | string[],
  options: { 
    clear?: boolean;
    hat?: string;
    tie?: string;
    name?: string;  // Character name
    stdout?: NodeJS.WriteStream;
  } = {}
) {
  const { 
    clear = false, 
    hat = '', 
    tie = '',
    name = 'Assistant',
    stdout = process.stdout 
  } = options;
  
  const msgs = Array.isArray(messages) ? messages : [messages];
  const logUpdate = createLogUpdate(stdout, { showCursor: false });
  
  const eyes = useAscii() ? EYES_ASCII : EYES_UNICODE;
  const mouths = useAscii() ? MOUTHS_ASCII : MOUTHS_UNICODE;
  const [h, v] = useAscii() ? WALLS_ASCII : WALLS_UNICODE;
  const [tl, tr, bl, br] = useAscii() ? CORNERS_ASCII : CORNERS_UNICODE;

  const face = (msg: string, { mouth = mouths[0], eye = eyes[0] } = {}) => {
    return [
      `${tl}${h.repeat(2)}${hat}${h.repeat(3 - hat.length)}${tr}  ${color.bold(color.cyan(`${name}:`))}`,
      `${v} ${eye} ${color.cyanBright(mouth)} ${eye}  ${msg}`,
      `${bl}${h.repeat(2)}${tie}${h.repeat(3 - tie.length)}${br}`,
    ].join('\n');
  };

  // Setup keypress handling for skip
  const rl = readline.createInterface({ input: process.stdin });
  let cancelled = false;
  
  const done = () => {
    cancelled = true;
    if (clear) logUpdate.clear();
    else logUpdate.done();
    rl.close();
  };

  if (process.stdin.isTTY) {
    process.stdin.setRawMode(true);
    readline.emitKeypressEvents(process.stdin, rl);
    process.stdin.once('keypress', done);
  }

  // Animate each message
  for (const message of msgs) {
    const words = message.split(' ');
    const displayed: string[] = [];
    let eye = random(eyes);

    for (let i = 0; i < words.length; i++) {
      displayed.push(words[i]);
      const mouth = random(mouths);
      if (i % 7 === 0) eye = random(eyes);
      
      logUpdate('\n' + face(displayed.join(' '), { mouth, eye }));
      
      if (!cancelled) await sleep(randomBetween(75, 200));
    }

    // Settle to happy face
    const happyEye = useAscii() ? '^' : '◠';
    const happyMouth = useAscii() ? 'u' : '◡';
    logUpdate('\n' + face(message, { mouth: happyMouth, eye: happyEye }));
    
    if (!cancelled) await sleep(randomBetween(1200, 1400));
  }

  done();
}
```

#### 2.2 Utility Functions

```typescript
// cli-kit/src/utils/index.ts
import { platform } from 'node:os';
import { exec } from 'node:child_process';

export const useAscii = () => platform() === 'win32';

export const sleep = (ms: number) => 
  new Promise(resolve => setTimeout(resolve, ms));

export const random = <T>(arr: T[]): T => 
  arr[Math.floor(Math.random() * arr.length)];

export const randomBetween = (min: number, max: number) => 
  Math.floor(Math.random() * (max - min + 1) + min);

export const getUserName = (): Promise<string> => 
  new Promise(resolve => {
    exec('git config user.name', { encoding: 'utf-8' }, (_, stdout) => {
      if (stdout?.trim()) {
        return resolve(stdout.split(' ')[0].trim());
      }
      exec('whoami', { encoding: 'utf-8' }, (_, stdout) => {
        resolve(stdout?.trim()?.split(' ')[0] || 'friend');
      });
    });
  });
```

### Phase 3: Context & Personalization

#### 3.1 Context Setup

```typescript
// src/actions/context.ts
import { prompt } from '@your-org/cli-kit';
import arg from 'arg';
import { getUserName } from '@your-org/cli-kit/utils';
import { getSeasonalData } from '../data/seasonal.js';

export interface Context {
  help: boolean;
  skipCharacter: boolean;
  yes: boolean;
  username: Promise<string>;
  welcome: string;
  hat: string;
  tie: string;
  tasks: Task[];
  // ... your app-specific context
}

export async function getContext(argv: string[]): Promise<Context> {
  const flags = arg({
    '--help': Boolean,
    '--yes': Boolean,
    '--skip-character': Boolean,
    '--fancy': Boolean,
    '-y': '--yes',
    '-h': '--help',
  }, { argv, permissive: true });

  const { messages, hats, ties } = getSeasonalData({ 
    fancy: flags['--fancy'] 
  });

  // Skip character on Windows (unless --fancy), or if --yes/--skip-character
  const skipCharacter = 
    ((platform() === 'win32' && !flags['--fancy']) || 
     flags['--skip-character'] || 
     flags['--yes']) ?? false;

  return {
    help: flags['--help'] ?? false,
    skipCharacter,
    yes: flags['--yes'] ?? false,
    username: getUserName(),
    welcome: random(messages),
    hat: hats ? random(hats) : '',
    tie: ties ? random(ties) : '',
    tasks: [],
  };
}
```

#### 3.2 Seasonal Customization (Optional)

```typescript
// src/data/seasonal.ts
interface SeasonalData {
  hats?: string[];
  ties?: string[];
  messages: string[];
}

export function getSeasonalData({ fancy }: { fancy?: boolean }): SeasonalData {
  const month = new Date().getMonth() + 1;
  const day = new Date().getDate();

  // Halloween: Oct 8-31
  if (month === 10 && day > 7) {
    return {
      hats: rarity(0.5, ['🎃', '👻', '💀']),
      ties: rarity(0.25, ['🍬', '🕷️']),
      messages: [
        "Let's conjure up something spooky!",
        "No tricks here, just treats!",
      ],
    };
  }

  // Holiday: Dec 8-24
  if (month === 12 && day > 7 && day < 25) {
    return {
      hats: rarity(0.75, ['🎄', '🎁']),
      ties: rarity(0.75, ['🧣']),
      messages: [
        "'Tis the season to code!",
        "Ho ho ho! Let's build something!",
      ],
    };
  }

  // Default
  return {
    hats: fancy ? ['🎩', '👑', '🧢'] : undefined,
    ties: fancy ? rarity(0.33, ['🎀', '🧣']) : undefined,
    messages: [
      "Let's build something awesome!",
      "Ready to create something great!",
      "Welcome! Let's get started.",
    ],
  };
}

// Makes decorations appear less frequently
function rarity(frequency: number, items: string[]): string[] {
  const padding = Array(Math.round(items.length / frequency - items.length)).fill('');
  return [...items, ...padding];
}
```

### Phase 4: Dependencies

#### Required Packages

```json
{
  "dependencies": {
    "chalk": "^5.0.1",
    "log-update": "^5.0.1",
    "arg": "^5.0.2"
  }
}
```

| Package | Purpose | Notes |
|---------|---------|-------|
| `chalk` | Terminal colors | ESM-only in v5+ |
| `log-update` | Flicker-free animation | Rewrites terminal lines |
| `arg` | CLI argument parsing | Lightweight alternative to commander |

#### Optional Enhancements

| Package | Purpose |
|---------|---------|
| `sisteransi` | Lower-level ANSI control |
| `giget` | Template downloading |
| `ora` | Spinners (alternative to custom) |

## Design Principles

### 1. Progressive Enhancement
- ASCII fallback for Windows terminals
- Skip animation in CI (`process.env.CI`)
- Respect `--yes` flag for non-interactive mode

### 2. Respect User Time
- Any keypress skips animation
- `--yes` bypasses all prompts
- `--skip-character` for quiet mode

### 3. Delight Through Details
- Personalize with username
- Seasonal themes create surprise
- Happy expression on completion

### 4. Clear Information Flow
```
Banner → Character Greeting → Steps → Tasks → Next Steps
```

## Testing Considerations

```typescript
// Mock stdout for testing
import { setStdout } from './messages.js';
import { PassThrough } from 'node:stream';

test('character says message', async () => {
  const output = new PassThrough();
  setStdout(output);
  
  await say('Hello!', { skipAnimation: true });
  
  expect(output.read().toString()).toContain('Hello!');
});
```

## Checklist

- [ ] Package structure (mono-repo or separate)
- [ ] Character design (ASCII art, name, personality)
- [ ] Animation timing (word delay, settle time)
- [ ] Color scheme (brand colors via chalk)
- [ ] Skip mechanisms (--yes, --skip-character, keypress)
- [ ] Windows/ASCII fallback
- [ ] CI detection (`process.env.CI`)
- [ ] Personalization (username detection)
- [ ] Seasonal data (optional)
- [ ] Error states (character sad face?)
- [ ] Testing setup (mock stdout)

## References

- [Astro create-astro source](https://github.com/withastro/astro/tree/main/packages/create-astro)
- [@astrojs/cli-kit source](https://github.com/withastro/cli-kit)
- [Research: Astro Houston CLI](../research/cli-design/2026-01-23-astro-houston-cli.md)
