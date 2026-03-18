---
description: Create implementation plan (interactive, read-only)
mode: interactive
permission_mode: plan
on_done: implement
on_cancel: classify-next-action
---

## Instruction

{{index .Action.Meta "instruction"}}

## Your job

Create a detailed implementation plan by reading the codebase. You MUST:
1. Read the codebase to understand the current architecture
2. Identify all files that need modification
3. Describe each change precisely
4. Note dependencies between changes
5. Include test requirements and verification steps

Discuss the plan with the user. When the user approves, call /tq:done
with the complete plan text as the result.
