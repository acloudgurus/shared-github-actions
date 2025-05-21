---
prev:
    text: Linting
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/lint/terraform-terragrunt
==================================================================

A GitHub action to lint Terraform and Terragrunt files

### Assumptions

+ The source code has been checked out in the current job
+ Any variables need to run `terragrunt init` exist in the `$GITHUB_ENV`

#### REQUIRED - Using a `shared-github-actions` Custom Image


```yaml
# within the .github/workflows/example.yaml
jobs:
  tf-apply-job:
    runs-on: MA-Analytics-Runner
    container:
      image: ghcr.io/zilvertonz/shared-github-actions:v1-base
      credentials:
        username: GTHBAUTO_Zilver
        password: ${{ secrets.ORG_REPO_READ_ACCESS }}
```
### Permissions

### Inputs

+ module_path (required)
  + Full directory path from the repository root to the Terraform module
  + type: `string`
+ tf_version (required)
  + Terraform version to use
  + type: `string`
+ tg_version (required)
  + Terragrunt version to use
  + type: `string`

### Using this action (default)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```yaml
name: deployment

on:
  pull_request:
    branches: [develop]

jobs:
  Deploy:
    runs-on: MA-Analytics-Runner

    # REQUIRED - use the shared-github-actions custom image
    container:
      image: ghcr.io/zilvertonz/shared-github-actions:v1-base
      credentials:
        username: GTHBAUTO_Zilver
        password: ${{ secrets.ORG_REPO_READ_ACCESS }}

    steps:
    - uses: actions/checkout@v4
    - name: Load Common Variables
      uses: zilvertonz/shared-github-actions/utility/load-dot-env@v1
      with:
        env_name: common
    - name: IaC Linting
      uses: zilvertonz/shared-github-actions/linting/terraform-terragrunt@v1
      with:
        module_name: module/aws/example
        tf_version: ${{ env.TF_VERSION }}
        tg_version: ${{ env.TG_VERSION }}
```

This will lint the directory at <span v-pre>`${{ inputs.module_name }}`</span> and exit non-zero if any of the files in the directory contain any linting errors. Output will show a list of files with linting errors to be rectified.
