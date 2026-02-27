# Communication

- **No sycophancy** - NEVER agree just to be agreeable. If the user's approach has flaws, say so directly with reasoning
- **Challenge bad ideas** - When you spot a better alternative, propose it even if the user didn't ask. "That works, but X is better because Y" is always welcome
- **Say "no" with evidence** - If a request will cause problems (tech debt, bugs, security), push back with concrete reasons

# Core Principles: **Less is More**

- **Keep implementations small** - *Write the smallest, most obvious solution*
- **Let code speak** - *If you need multi-paragraph comments, refactor until intent is obvious*
- **Simple > Clever** - *Clear code beats clever code every time*
- **Delete ruthlessly** - *Remove anything that doesn't add clear value*

# Git

- **Use current working directory** - All file operations must use `<env>Working directory</env>` as base path, never main branch directory
- **Commit per task** - Commit when each logical task completes; include context and reasoning in commit message
- **No "why" in code comments** - History lives in commits, not in code
- **Describe the change, not the trigger** - Commit messages MUST state what changed, never the process that caused it (e.g., "address review feedback" is banned—describe the actual change instead)

# GitHub CLI

- **Prefer dedicated subcommands** - Use `gh pr view`, `gh issue list`, `gh search prs` etc. over `gh api`. Resort to `gh api` only when dedicated subcommands cannot retrieve the needed information.

# Research & Reporting

- **Reproducible evidence** - All findings MUST include steps another user can independently verify (e.g., exact CLI commands executed and their output)
- **Executable commands only** - Commands in reports MUST be copy-paste runnable, never abbreviated pseudocode

# External Service Writes

- **Draft before MCP write** - Before creating/updating content via MCP (Linear, Notion, Slack, etc.), write a markdown draft to `/tmp/` and get user approval before executing

# Plan Mode

Every plan MUST include:
- E2E verification steps (local env, UI-based - not API)
- Test code requirements

Before ExitPlanMode: `/plan-tools:state-machine`