---
prev:
    text: Compliance
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/compliance/download-job-logs
=====================================================================

A GitHub action to download the run logs of a job within the current workflow

### Assumptions

+ The step is run in a job following the job from which you want to download the logs

### Permissions

+ `actions:read`
  + Required to retrieve the workflow job details and job run logs

### Inputs

+ `job_names` (required)
  + The names of the jobs within the workflow
  + type: `string`
> [!NOTE]
> The current version uses `startswith()` function to look for job name. If you have multiple jobs that start with `Deploy` or your input, it will not work. Make sure that your input is unique.
+ `token` (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`

### Outputs

+ `log_file_names`
  + Name of the log file created
+ `log_file_paths`
  + Path to the log file created
+ `logs_folder`
  + Folder that contains logs

### Using this action (default)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```
name: DeployWithLogs

on:
  workflow_dispatch:

permissions:
  actions: read

jobs:
  PreDeploy:
    runs-on: MA-Analytics-Runner
    steps:
    - name: Echo to Log
      run: echo "Hello world!"
  CodeScanning:
    runs-on: MA-Analytics-Runner
    steps:
    - name: Echo to Log
      run: echo "Hello world!"
  Deploy:
    runs-on: MA-Analytics-Runner
    steps:
    - name: Echo to Log
      run: echo "Hello world!"
  PostDeployLogs:
    runs-on: MA-Analytics-Runner
    needs: [Deploy]
    steps:
    - name: Download Job Logs
      id: download-job-logs
      uses: zilvertonz/shared-github-actions/compliance/download-job-logs@v1
      with:
        job_names: |
          Deploy
          PreDeploy
          CodeScanning
        token: ${{ secrets.GITHUB_TOKEN }}
```

This workflow will run a job `Deploy` which simply echos a string to generate some log message. The subsequent job `PostDeployLogs` will then download the run logs from the `Deploy`, `PreDeploy`, and `CodeScanning` jobs and upload them as artifacts.