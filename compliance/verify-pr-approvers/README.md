---
prev:
    text: Compliance
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/compliance/verify-approvers
===========================================================

A GitHub action to verify a compliant number of approvers on the current commit

> [!NOTE]
> If the latest commit hash does NOT have 2 reviewers it will output a 404 error.

### Assumptions

+ The checked out commit was introduced to the repository through a pull request

### Permissions

+ `pull-requests:read`
  + Required to find the pull request associated with current commit

### Inputs

+ `token` (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`

+ `required_reviews` (optional)
  + Number of required approvers
  + default: `2`

### Outputs

+ `approver_list`
  + Comma-separated list of approver emails

### Using this action (default)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```
name: Verify Approvers

on:
  workflow_dispatch:

permissions:
  pull-requests: read

jobs:
  PreDeployChecks:
    runs-on: MA-Analytics-Runner
    steps:
    - uses: actions/checkout@v4
    - name: Verify approvers
      uses: zilvertonz/shared-github-actions/compliance/verify-approvers@v1
      id: verify-approvers
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
  Deploy:
    needs: [PreDeployChecks]
    runs-on: MA-Analytics-Runner
    steps:
    - name: Echo Approvers
      run: echo ${{ steps.verify-approvers.outputs.approver_list }}
```

This workflow will run a job `PreDeployChecks` which will fail if there is not a compliant number of approvers on the PR that introced the commit checked out. The subsequent job `Deploy` will then proceed if the `PreDeployCheck` job completed successfully.
