---
description: Wait for PR checks to complete and report results
---

## Task

Monitor GitHub PR checks until they complete or fail:

1. Start `gh pr checks --watch` in background using `run_in_background: true`
2. Wait 120 seconds, then check the background process output using BashOutput
3. Look for completion indicators or failure messages in the output
4. Repeat step 2-3 until checks complete or fail
5. Report the final status to the user

If checks fail, clearly indicate which checks failed.
If checks pass, confirm all checks have passed successfully.
