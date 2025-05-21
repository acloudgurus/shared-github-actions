---
prev:
    text: Code Scanning
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/code-scan/checkov
==================================================================

Run checkov code scanning over a terraform module. 

Findings are uploaded to Github Security tab on the repository. Furthermore,
findings will be added to your branches pull request, for further action.

## Assumptions

+ The source code has been checked out in the current job
+ Permissions are defined at the top level of the workflow as [shown below](#permissions)

## Permissions

+ the following permissions are needed:
```yaml
permissions:
  # required for uploading results
  security-events: write
  contents: read
  pull-requests: write
  actions: read
```

## Inputs

+ module (required)
  + Directory path from the root to tf module (use full path from repo root)
  + type: `string`
+ org_read_token:
  + Always pass <span v-pre>${{ secrets.ORG_REPO_READ_ACCESS }}</span>
  + required: true
  + type: string
+ token (required)
  + Github token for cross organization read-only permissions
  + type: `string`
+ external-checks:
  + Source for external checks. Defaults to `https://github.com/zilvertonz/shared-checkov.git?ref=tag/v0`
  + type: string
  + default: `https://github.com/zilvertonz/shared-checkov.git?ref=tag/v0`
+ soft-fail:
  + When true, don't exit non-zero if checkov checks fail. Defaults to `false`
  + type: boolean
  + default: false
+ skip-check:
  + When set, checks will be skipped. Wild cards are allowed, ie `ZCC_AWS_*`
  + type: string

## Using this action, on pull request (before terraform plan)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```yaml{42-48}
name: tfplan

on:
  pull_request:
    branches:
      - main

env:
  # use your region
  REGION: us-east-1
  # use your account number
  ACCOUNT_NUMBER: 9999999999

jobs:
  plan_base:
    name: Terraform Action
    runs-on: MA-Analytics-Runner

    permissions:
      # required for uploading results
      security-events: write
      contents: read
      actions: read
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

      - name: Checkov Code-Scan
        uses: zilvertonz/shared-github-actions/code-scan/checkov@v1
        with:
          org_read_token: ${{ secrets.ORG_REPO_READ_ACCESS }}
          token: ${{ github.token }}
          module: module/aws/base
          soft-fail: true

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

## Recommended Pattern

This pattern requires all findings to be resolved and presents those findings 
within the pull request (PR).

When findings are found, fix them. When something cannot be fixed,
utilize the built-in Github Advanced Security 
annotations within the PR to dismiss with comment. 

This pattern enables engineering teams 
take responsibility with findings while maintaining visibility and accountability.

> [!WARNING]
> You should only be dismissing findings when needed.
> These findings are visible whether they are dismissed or not, so take 
> responsibility over our shared environments. You are ultimately accountable.

### Quick note on findings

Findings will only be presented in the PR when they are new to the repository. To 
view all (new findings or otherwise), goto the security tab in the repository and 
filter based on PR number, ie, 
<span v-pre>https://github.com/zilvertonz/${YOUR_REPO}/security/code-scanning?query=is%3Aopen+pr%3A9</span>

### Configuring the Pattern

> [!WARNING]
> This pattern requires you to successfully run this checkov action within your
> before you can implement what is outlined below.

It is recommended to add branch protection (under repository "Settings" > 
"Rules" (sidebar) > "Rulesets" or <span v-pre>https://github.com/zilvertonz/${YOUR_REPO}/settings/rules</span>)
where "Require status checks to pass" is checked and configured with "Checkov" with "Github Advanced Security" 
added (click "+ Add checks" and search checkov). Make sure it's "Github Advanced Security" and not "Github Actions" for this specific check.

Once all findings are resolved (via fixing them or dismissing false positives) the 
"Github Advanced Security" check will be shown as passing. 

Furthermore, since `soft-fail: true`, findings won't force the Github Action job 
to fail. Only, the Checkov "Github Advanced Security" will show as a failure 
when findings occur. Again, see the security tab for all findings within a PR or 
across the repository.

