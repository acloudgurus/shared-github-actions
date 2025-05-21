---
prev:
    text: Versioning
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/version/github-release-validate
=============================================================

A GitHub action to validate pull request for proposed version in GitHub repo


### Assumptions

+ The source code has been checked out in the current job
+ This action uses [Semantic Versioning](https://semver.org) with `vX.X.X` format to indicate how tag is created

### Inputs

+ token (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`
+ version_type (required)
  + Type of version associated with the code changes. This will be used to increment tag
  + type: `choice`
  + options: [`infer_from_label`, `infer_from_title`]

### Permissions

+ `contents:write` (required)
  + Required to push a new git tag and generate release notes
+ `pull-requests:write` (required)
  + Required to get the PR number or title and comment on PR the findings

### Using this action (default)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```yaml
name: Git Tag and Release

on:
  pull_request:
    branches: [main]

permissions:
  contents: write
  pull-requests: write

jobs:
  TagAndRelease:
    runs-on: MA-Analytics-Runner
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
    - name: Validate GitHub Release
      uses: zilvertonz/shared-github-actions/version/github-release-validate@v1
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        version_type: infer_from_title
```

This example workflow is configured to run on a pull request to the `main` branch. 

This action will then comment on the pull request letting the user know what type of version (if any) will be created on merge to the target branch. This is useful to verify the pull request has been configured to meet the desired version depending on not only the workflow configuration but the type of change.

### Version Type Options

The version type can be passed in to this action via one of the following:
- Select `infer_from_title` to parse the PR title (title should follow the conventional commit format)
- Select `infer_from_label` to obtain version type from the pull request label 

