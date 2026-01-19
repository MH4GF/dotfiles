---
description: Wait for PR checks to complete and report results
---

## Task

Monitor GitHub PR checks until they complete or fail:

1. Run `gh pr checks --watch` with `run_in_background: true`
2. The process completion will be notified automatically - no polling needed
3. Report the final status to the user

If checks fail, clearly indicate which checks failed.
If checks pass, confirm all checks have passed successfully.
