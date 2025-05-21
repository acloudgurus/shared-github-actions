---
prev:
    text: Deployment
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/deploy/terragrunt
==================================================================

A GitHub action to Plan/Apply/Destroy/etc Terraform and Terragrunt

> [!WARNING]
> Canceling the terragrunt action while in progress will result in 
> terraform state lock issues.

### Assumptions

+ The source code has been checked out in the current job
+ AWS authentication has already been established
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

See full workflow example [below](#using-this-action-on-pull-request-terraform-plan)

### Permissions

+ A token for cross repository read is needed

### Inputs

+ module (required)
  + Directory path from the root to tf module (use full path from repo root)
  + type: `string`
+ terraform_action (required)
  + type: `string`
+ token (required)
  + Github token for cross organization read-only permissions
  + type: `string`
+ workspace (required)
  + terrafrom workspace name
  + type: `string`
  + default: `default`
+ tf_version 
  + Terraform version. See latest here: https://github.com/hashicorp/terraform/releases
    NOTE: use `.terraform-version` files in the module or parent dir to the 
    module. Passing inputs here will take priority.
  + type: `string`
+ tg_version 
  + Terragrunt version. See latest here: https://github.com/gruntwork-io/terragrunt/releases
    NOTE: use `.terragrunt-version` files in the module or parent dir to the 
    module. Passing inputs here will take priority.
  + type: `string`

### Outputs

+ terraform_outputs
    + Outputs from an apply, in json format
        WARNING: this could be empty so check to make sure it's popluated before using
    + type: json

### Setting TF and TG Versions

#### Explict via inputs VS Implicit via Version files

Managing versions for terraform and terragrunt can be done within dot files 
(`.terragrunt-version` and `.terragrunt-version`) within the module directories 
OR the parent to the module. For example, if the AWS-d pattern is used, you can 
place these files within `module/aws` or `module/aws/<module-name>`.

We support these files due to third party tools like [tfenv](https://github.com/tfutils/tfenv)
and [tgswitch](https://tgswitch.warrensbox.com/Quick-Start/#use-tgswitchrc-file) utilizing 
these. This can make managing versions easier within the code instead of within the 
code and in the CICD.

### Using this action, on pull request (terraform plan)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```yaml
name: tfplan

on:
  pull_request:
    branches:
      - develop

permissions:
  contents: read
  id-token: write

env:
  # use your region
  REGION: us-east-1
  # use your account number
  ACCOUNT_NUMBER: 9999999999

jobs:
  plan_base:
    name: Terraform Action
    runs-on: MA-Analytics-Runner

    # since v1, using shared-github-actions custom image is required!
    container:
      image: ghcr.io/zilvertonz/shared-github-actions:v1-base
      credentials:
        username: GTHBAUTO_Zilver
        password: ${{ secrets.ORG_REPO_READ_ACCESS }}

    permissions:
      contents: read
      id-token: write
    
    environment:
      # default to dev
      # https://docs.github.com/en/actions/using-jobs/using-environments-for-jobs#example-using-an-expression-as-environment-name
      name: ${{ github.ref_name == 'main' && 'prod' || github.ref_name == 'test' && 'test' || 'dev' }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Authenticate via OIDC Role
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.REGION }}
          # make sure this follows your repository role setup through https://github.com/zilvertonz/RJ/
          role-to-assume: "arn:aws:iam::${{ env.ACCOUNT_NUMBER }}:role/Enterprise/${{ github.event.repository.name }}-deployer"

      - name: Terraform Plan
        uses: zilvertonz/shared-github-actions/deploy/terragrunt@v1
        env: 
          TF_VAR_account_number: ${{ env.ACCOUNT_NUMBER }}
          TF_VAR_region: ${{ env.REGION }}
          TF_VAR_test_secret: ${{ secrets.TF_VAR_TEST_SECRET }} 
        with:
          module: module/aws/base
          terraform_action: plan
          workspace: develop
          token: ${{ secrets.ORG_REPO_READ_ACCESS }}
```

### Using this action, on push (terraform apply)

```yaml
name: deploy

on:
  push:
    branches:
      - develop
      - next
      - main

permissions:
  contents: read
  id-token: write

env:
  # use your region
  REGION: us-east-1
  # use your account number
  ACCOUNT_NUMBER: ${{ github.ref_name == 'main' && '9999999999' || github.ref_name == 'test' && '888888888' || '7777777777' }}

jobs:
  plan_base:
    name: Terraform Action
    runs-on: MA-Analytics-Runner

    # since v1, using shared-github-actions custom image is required!
    container:
      image: ghcr.io/zilvertonz/shared-github-actions:v1-base
      credentials:
        username: GTHBAUTO_Zilver
        password: ${{ secrets.ORG_REPO_READ_ACCESS }}

    permissions:
      contents: read
      id-token: write
    
    environment:
      # default to dev
      # https://docs.github.com/en/actions/using-jobs/using-environments-for-jobs#example-using-an-expression-as-environment-name
      name: ${{ github.ref_name == 'main' && 'prod' || github.ref_name == 'test' && 'test' || 'dev' }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Authenticate via OIDC Role
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.REGION }}
          # make sure this follows your repository role setup through https://github.com/zilvertonz/RJ/
          role-to-assume: "arn:aws:iam::${{ env.ACCOUNT_NUMBER }}:role/Enterprise/${{ github.event.repository.name }}-deployer"

      - name: Terraform Apply
        id: terraform_action
        uses: zilvertonz/shared-github-actions/deploy/terragrunt@v1
        env: 
          TF_VAR_account_number: ${{ env.ACCOUNT_NUMBER }}
          TF_VAR_region: ${{ env.REGION }}
          TF_VAR_test_secret: ${{ secrets.TF_VAR_TEST_SECRET }} 
        with:
          module: module/aws/base
          terraform_action: apply
          workspace: develop
          workspace: ${{ github.ref_name == 'main' && 'prod' || github.ref_name == 'test' && 'test' || 'dev' }}
          token: ${{ secrets.ORG_REPO_READ_ACCESS }}
      - name: Use Outputs
        env:
          # load into an env var to avoid parsing errors
          TF_OUT: ${{ steps.terraform_action.outputs.terraform_outputs }}
        run: |
            # make sure the output is not an empty string
            if [[ -n "$TF_OUT" ]]; then
                echo "$TF_OUT" | jq .
            fi
            
```

### Using this action to get terraform outputs
```yaml
name: test

on:
  push:
    branches:
      - develop

permissions:
  contents: read
  id-token: write

env:
  # use your region
  REGION: us-east-1
  # use your account number
  ACCOUNT_NUMBER: ${{ github.ref_name == 'main' && '9999999999' || github.ref_name == 'test' && '888888888' || '7777777777' }}

jobs:
  plan_base:
    name: Terraform Action
    runs-on: MA-Analytics-Runner

    permissions:
      contents: read
      id-token: write
    
    environment:
      # default to dev
      # https://docs.github.com/en/actions/using-jobs/using-environments-for-jobs#example-using-an-expression-as-environment-name
      name: ${{ github.ref_name == 'main' && 'prod' || github.ref_name == 'test' && 'test' || 'dev' }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Authenticate via OIDC Role
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ env.REGION }}
          # make sure this follows your repository role setup through https://github.com/zilvertonz/RJ/
          role-to-assume: "arn:aws:iam::${{ env.ACCOUNT_NUMBER }}:role/Enterprise/${{ github.event.repository.name }}-deployer"

      - name: Terraform Output
        id: terraform_action
        uses: zilvertonz/shared-github-actions/deploy/terragrunt@v1
        env: 
          TF_VAR_account_number: ${{ env.ACCOUNT_NUMBER }}
          TF_VAR_region: ${{ env.REGION }}
          TF_VAR_test_secret: ${{ secrets.TF_VAR_TEST_SECRET }} 
        with:
          module: module/aws/base
          terraform_action: output
          workspace: ${{ github.ref_name == 'main' && 'prod' || github.ref_name == 'test' && 'test' || 'dev' }}
          token: ${{ secrets.ORG_REPO_READ_ACCESS }}
      - name: Use Outputs
        env:
          # load into an env var to avoid parsing errors
          TF_OUT: ${{ steps.terraform_action.outputs.terraform_outputs }}
        run: |
            # make sure the output is not an empty string
            if [[ -n "$TF_OUT" ]]; then
                echo "$TF_OUT" | jq .
            fi
            
```
