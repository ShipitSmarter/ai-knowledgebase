# AI Tools for Designers

**Get AI help creating and improving frontend interfaces at ShipitSmarter.**

This guide covers the AI tools most useful for designers working on Viya's user interface.

---

## Quick Setup

Run this in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
```

Then restart your terminal. Done!

---

## Your Main Tools

### Frontend Design Skill

The `frontend-design` skill teaches AI to create distinctive, production-grade interfaces that avoid generic "AI slop" aesthetics.

**What it knows:**
- Typography (scales, pairing, loading)
- Color systems (OKLCH, dark mode, accessibility)
- Spatial design (grids, rhythm, spacing)
- Motion design (easing, timing, reduced motion)
- Interaction patterns (forms, focus, loading states)
- Responsive design (mobile-first, container queries)
- UX writing (labels, errors, empty states)

**Example prompts:**
```
Create a card component for displaying shipment status

Design a form for entering delivery preferences

Build a dashboard showing shipping metrics
```

### Design Commands

These commands help you improve existing interfaces:

| Command | What it does |
|---------|-------------|
| `/i-audit` | Technical quality check (accessibility, performance, responsive) |
| `/i-critique` | UX design review (hierarchy, clarity, emotional resonance) |
| `/i-polish` | Final pass before shipping (alignment, spacing, consistency) |
| `/i-simplify` | Remove unnecessary complexity |
| `/i-bolder` | Make boring designs more visually impactful |
| `/i-quieter` | Tone down overly aggressive designs |
| `/i-colorize` | Add strategic color to monochromatic interfaces |
| `/i-animate` | Add purposeful motion and transitions |
| `/i-delight` | Add moments of joy and personality |
| `/i-clarify` | Improve unclear UX copy and labels |

**Example usage:**
```
/i-audit the shipment tracking page

/i-simplify the carrier settings form

/i-polish before we ship the new dashboard
```

### Setting Up Your Design Context

Run this once per project to teach the AI about your design direction:

```
/i-teach-impeccable
```

This asks questions about your target users, brand personality, and aesthetic preferences, then saves the context for future sessions.

---

## Working with Penpot

If you use Penpot for designs, the `designer` skill connects AI directly to your design files.

```
/designer
```

This starts the Penpot MCP server and guides you through connecting the plugin.

**What you can do:**
- Get an overview of your design structure
- Find elements by name or type
- Modify colors, text, and properties
- Export assets as PNG/SVG
- Generate code from designs

---

## Design Anti-Patterns to Avoid

The AI is trained to avoid these common "AI-generated look" patterns:

**Typography:**
- Overused fonts (Inter, Roboto, Arial)
- Monospace for "technical" vibes
- Large icons above every heading

**Color:**
- Purple-to-blue gradients
- Cyan on dark backgrounds
- Gray text on colored backgrounds
- Pure black (#000) or pure white (#fff)

**Layout:**
- Cards nested inside cards
- Identical card grids everywhere
- Hero metric layouts (big number + gradient)
- Everything centered

**Effects:**
- Glassmorphism everywhere
- Gradient text on headings
- Bounce/elastic animations
- Generic drop shadows

---

## Workflow Example

### Starting a New Feature

1. **Set up design context** (if not done):
   ```
   /i-teach-impeccable
   ```

2. **Create the initial design**:
   ```
   Create a shipment tracking page that shows delivery progress,
   current location, and estimated arrival time
   ```

3. **Review and refine**:
   ```
   /i-critique
   ```

4. **Polish before handoff**:
   ```
   /i-polish
   ```

### Improving an Existing Page

1. **Audit for issues**:
   ```
   /i-audit the carrier profile page
   ```

2. **Address specific concerns**:
   ```
   /i-simplify - there's too much visual noise
   
   /i-bolder - it feels too safe and generic
   ```

3. **Final polish**:
   ```
   /i-polish
   ```

---

## Tips for Better Results

### Be Specific About Context
```
Good: "Design a form for warehouse workers scanning packages on mobile devices"
Bad: "Design a form"
```

### Mention the Emotional Goal
```
Good: "Create a success state that feels celebratory but not over the top"
Bad: "Create a success state"
```

### Reference Existing Patterns
```
"Use a similar layout to the existing shipment detail page, but for consignments"
```

### Ask for Options
```
"Show me 3 different approaches for the empty state - one minimal, one playful, one instructive"
```

---

## Getting Help

- **Commands not working?** Restart your terminal after setup
- **Need to check setup:** Run `echo $OPENCODE_CONFIG_DIR`
- **Questions?** Ask in the team Slack or create an issue in this repository
