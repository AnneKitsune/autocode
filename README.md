# Anne's Autocoder

A collection of shell scripts automating programming and related tasks.
Only supports rust code.

### Features
- Automatic Code Modifications using `aider`.
- Automatic Unit Testing
- Progress Notifications
- Automated Git Branch and Commit Management

### Warnings
This might blow up your system if the AI model you use decides to generate broken or malicious code. Use at your own risk. Prefer running into a VM, container or jail.

### Setup / Dependencies
- Aider
- Access to an openai compatible api with a weak and strong model you can use. I recommend llama-swap.
- Notification script (update in lib.sh manually. if you don't want one, replace it by `echo`)
- jq

### Project-Feature-Plan-Task
A project is composed of features.
A feature is implemented by a plan.
A plan is an ordered list of tasks.
A task is an AI prompt / implementation step.

### Scripts
- Implementing a project: `run_plans.sh`
- Implementing a feature: `run_plan.sh`
- Implementing a task: `run.sh`

- Manually reviewing changes: `review_success.sh` and `review_failed.sh`

- Dividing a project into features: `todo.sh`
- Dividing a feature into tasks: `plan.sh` (WIP)

### Workflow
1. Create or import a git project. Make sure there are no pending changes and the default branch is main.
2. (optional) Write a todo file using todo.sh or manually.
3. Write one or more plan files, where each line is an implementation step / ai prompt. Either do this manually or using `plan.sh` (requires todo.md).
4. Run `run_plans.sh "/tmp/feature_name.txt /tmp/feature_name2.txt" "path/to/guidelines.md"`. The default guidelines are in testing/guidelines.md and the argument is optional.
5. Wait for notifications asking you to review manually (or failure notifications).
6. Review manually and use either `review_success.sh branch_name` or `review_failed.sh branch_name comments.txt path/to/guidelines.md`. Once again, guidelines are optional.
7. If `review_failed`, go to step 5. If `review_success`, continue to step 8.
8. Wait for a merge notification. If it succeeds, congratulations! If it doesn't, you will need to do a manual merge.
