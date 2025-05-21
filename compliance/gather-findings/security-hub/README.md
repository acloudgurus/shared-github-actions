# GitHub Action: Gather Findings from SecurityHub
This GitHub Action collects and findings from the repository's GitHub code scanning 
alerts, providing a strcutured CSV file with the findings for audit purposes.

## Features

- Retrieves security findings for the current branch (or PR).
- Filters fidings based on their open status and when tagged properly. See [Tagging AWS Resources](#tagging-aws-resources), for more information.
- Outputs a CSV file containing to an artifact, that is downloadable

## Inputs

| Input     | Required | Description                                       |
|-----------|----------|---------------------------------------------------|
|`token`|   Yes     |    GitHub token for running CLI commands. `GITHUB_TOKEN` secret.|

## Tagging AWS Resources
To use this action you must use the `shared-github-actions/deploy/terragrunt` action (v1 or higher)
to deploy your AWS resources OR set [aws provider default tags](https://www.hashicorp.com/en/blog/default-tags-in-the-terraform-aws-provider) to match the following:
- Key, Value format

```
SourceRepoID=${{ github.repository_id }}
```
> [!NOTE]
> Value uses [github actions github context](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs#github-context))

### Examples on how to do this

#### Use shared-github-actions
More on the [deploy action](../../../deploy/terragrunt/)

```yaml
# this will automatically add SourceRepoID to all resources as needed
- name: deploy
  uses: zilvertonz/shared-github-actions/deploy/terragrunt@v1
  with:
    terraform_action: apply
  ...

```

#### Set AWS Provider Default Tag via Environment Variable
```yaml
- name: deploy
  env:
    # adds SourceRepoID tag too all resources created
    TF_AWS_DEFAULT_TAGS_SourceRepoID: ${{ github.repository_id }}
  run: |
    terraform apply
```


## Assumptons
- AWS authentication has already been established
- AWS resources are tagged appropriately, see [Tagging AWS Resources](#tagging-aws-resources)

## Required Permissions

Permission required for the Github Actions Job

|scope|level|
|---|---|
|contents| read|
|pull-requests| write|
|id-token| write|

### Required RJ Permissions 

Your deployer roles needs the following permissions to gather these findings

```yaml
GetSecurityHubFindings:
    Type: "AWS::IAM::ManagedPolicy"
    Properties:
      ManagedPolicyName: !Sub "GetSecurityHubFindings-${Env}"
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Action:
              - securityhub:GetFindings
              - tag:GetResources
            Resource: ['*']
```

## Artifacts

Once the workflow has run successfully, you can download and share the 
github artifact.

- aws-securityhub-findings

## Usage

Here's an example of how to use this action in your workflow:

```yaml
- name: Gather AWS SecurityHub Findings
  uses: zilvertonz/shared-github-actions/compliance/gather-findings/security-hub@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
```

## Example Workflow

```yaml
name: Manual Gather AWS SecurityHub Findings

on:
  workflow_dispatch:

jobs:
  GatherFindings:
    runs-on: MA-Analytics-Runner

    container:
      image: ghcr.io/zilvertonz/shared-github-actions:v1-base
      credentials:
        username: GTHBAUTO_Zilver
        password: ${{ secrets.ORG_REPO_READ_ACCESS }}

    permissions:
      contents: read
      pull-requests: write
      id-token: write

    steps:
      - name: Authenticate via OIDC Role
        uses: aws-actions/configure-aws-credentials@v4
        env:
          REGION: us-east-1
          ACCOUNT_NUMBER: 1234
          # deployer role needs allow for these actions:
          #  - securityhub:GetFindings
          #  - tag:GetResources
          DEPLOYER_ROLE: my-rj-deployer-role
        with:
          aws-region: ${{ env.REGION }}
          role-to-assume: "arn:aws:iam::${{ env.ACCOUNT_NUMBER }}:role/Enterprise/${{ env.DEPLOYER_ROLE }}"

      - name: Gather AWS SecurityHub Findings
        uses: zilvertonz/shared-github-actions/compliance/gather-findings/security-hub@v1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```
