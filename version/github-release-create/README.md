---
prev:
    text: Versioning
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/version/github-release-create
=============================================================

A GitHub action to create a new tag and generate release notes in GitHub repo


### Assumptions

+ The source code has been checked out in the current job
+ This action uses [Semantic Versioning](https://semver.org) with `vX.X.X` format to indicate how tag is created

### Inputs

+ tag_major_version (optional)
  + Maintain an additional tag pointing to the latest major version
  + default: `true`
  + type: `boolean`
+ token (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`
+ version_type (required)
  + Type of version associated with the code changes. This will be used to increment tag
  + type: `choice`
  + options: [`major`, `minor`, `patch`, `infer_from_label`, `infer_from_title`]

### Permissions

+ `contents:write` (required)
  + Required to push a new git tag and generate release notes
+ `pull-requests:read` (required)
  + Required to get the PR number and title

### Using this action (default)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```yaml
name: Git Tag and Release

on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: read

jobs:
  TagAndRelease:
    runs-on: MA-Analytics-Runner
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
    - name: GitHub Tag and Release
      uses: zilvertonz/shared-github-actions/version/github-release-create@v1
      with:
        tag_major_version: true
        token: ${{ secrets.GITHUB_TOKEN }}
        version_type: infer_from_title
```

This example workflow is configured to run on a push to the `main` branch. 

It creates either a new tag if none exists, or an increment of the latest tag based on the semantic versioning keyword passed in the input.

For example, if `minor` is passed in as the `version_type` it will increment an existing tag from v1.0.0 to v1.1.0. 

### Version Type Options

The version type can be passed in to this action via one of the following:
- Directly from the input by selecting either `major`, `minor`, or `patch`
- Select `infer_from_title` to parse the PR title (title should follow the conventional commit format)
- Select `infer_from_label` to obtain version type from the pull request label 

### Customizing Release Notes

Release notes may be customized by:
- Including a release.yaml file inside the .github directory, and
- Adding labels in the pull request to categorize the notes

#### Example of `release.yaml`

```yaml
changelog:
  categories:
    - title: Major
      labels:
        - major
    - title: Minor
      labels:
        - minor
    - title: Patch
      labels:
        - patch
```

More configuration options and examples can be found [here](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes#configuration-options).

