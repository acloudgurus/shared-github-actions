---
prev:
    text: Utilities
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/utility/load-dot-env
=============================================================

A GitHub action to load environment variables


### Assumptions

+ The source code has been checked out in the current job
+ There exists a `.env` configuration file in the directory `.github/workflows/environments` which is named to match the `env_name` input.

### Inputs

+ env_name (required)
  + Environment name from which to load file
  + type: `string`

### Permissions

None

### Using this action (default)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```
name: deployment

on:
    push:
        branches: [develop]

jobs:
  Deploy:
    runs-on: MA-Analytics-Runner
    steps:
    - uses: actions/checkout@v4
    - name: Load Common Variables
      uses: zilvertonz/shared-github-actions/utility/load-dot-env@v1
      with:
        env_name: common
```

This will load the file `.github/workflows/environments/common.env` which defines the variables to be loaded into `$GITHUB_ENV`. This allows more simpler configuration of variables reused across workflows per environment and/or branch.

Any variables loaded are then accessible within the job either through the `env` context as <span v-pre>`${{ env.VARIABLE_NAME }}`</span> or within a script as `$VARIABLE_NAME`.
