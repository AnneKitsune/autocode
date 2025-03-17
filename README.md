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

### Dependencies
- Aider
- Ollama
- Aider custom configs (WIP to move into the repo)
- Env file (WIP to move into repo)
- Notification script (WIP: make optional)

### Project-Feature-Plan-Task
A project is composed of features.
A feature is implemented by a plan.
A plan is an ordered list of tasks.

### Scripts
Implementing a project: `run_plans.sh`
Implementing a feature: `run_plan.sh`
Implementing a task: `run.sh`

Dividing a project into features: `WIP`
Dividing a feature into tasks: `WIP`
