---
description: Create a new skill with latest Claude Code specifications
---

## Task: Create a New Skill

### Input
`$ARGUMENTS`

### Process

1. **Get latest specs**
   Use `claude-code-guide` agent to fetch current Claude Code skill/command specifications.

2. **Design the skill**
   - Infer name and description from input
   - Name: kebab-case
   - Location: `.claude/commands/<name>.md` or `.claude/skills/<name>/SKILL.md`

3. **Create with minimal structure**
   Only add complexity when needed.

### Core Principles
- **Concise over comprehensive** - Every token competes for context
- **Specific over vague** - Concrete instructions, not abstract guidelines
- **Trust Claude's knowledge** - Don't explain what Claude already knows
