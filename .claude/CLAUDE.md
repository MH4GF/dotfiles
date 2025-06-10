# Global Guidelines

## Git Workflow Guidelines
- Make meaningful commits for each logical unit of work
- Use descriptive commit messages that explain what and why
- Keep commits focused on a single responsibility 
- Run tests and linters before committing

## Task Completion Criteria
For any implementation task to be considered complete, it must satisfy all of the following conditions:
1. All linters must pass (`pnpm lint` / `pnpm fmt` must succeed without errors)
2. The build must succeed (`pnpm build` must complete without errors)
3. All tests must pass (`pnpm test` must succeed)
4. User must confirm and approve the implementation

## Post-Task Process
- After completing the task, interact with the user to review the work done so far and think about how to do it better.We then update the project documentation.