---
prev:
    text: Versioning
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/version/python-poetry
=============================================================

A GitHub action to update the version of a Python package managed by Poetry


### Assumptions

+ The source code has been checked out in the current job

### Inputs

+ package_path (required)
  + Relative path to the pyproject.toml file of the package
  + type: `string`
+ token (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`
+ version_type (required)
  + Type of version associated with the code changes. This will be used to increment package version
  + type: `choice`
  + options: [`major`, `minor`, `patch`, `infer_from_label`, `infer_from_title`]

### Permissions

+ `contents:write` (required)
  + Required to push the update poetry version
+ `pull-requests:read` (optional)
  + Required to get the PR number and title if inferring

### Using this action (default)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```yaml
name: Poetry Version Update

on:
  pull_request:
    branches: [main]

permissions:
  contents: write
  pull-requests: read

jobs:
  UpdateVersion:
    runs-on: MA-Analytics-Runner
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
    - name: Update Package Version
      uses: zilvertonz/shared-github-actions/version/python-poetry@v1
      with:
        package_path: lib/package
        token: ${{ secrets.GITHUB_TOKEN }}
        version_type: infer_from_title
```

This example workflow is configured to run on a pull request to the `main` branch.

Using the conventional commit tile of the PR, the `poetry version` command is run and a commit is pushed to the branch.

For example, if `minor` is passed in as the `version_type` it will increment the package version from v1.0.0 to v1.1.0. 

### Version Type Options

The version type can be passed in to this action via one of the following:
- Directly from the input by selecting either `major`, `minor`, or `patch`
- Select `infer_from_title` to parse the PR title (title should follow the conventional commit format)
- Select `infer_from_label` to obtain version type from the pull request label 
