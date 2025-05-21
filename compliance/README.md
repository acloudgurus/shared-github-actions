# GitHub Actions: Compliance/Audit Bundle

## Usage

Here's an example of how to use this bundle in your workflow:

```yaml
name: prod-deploy-audit-bundle

on:
  workflow_dispatch:
    inputs:
      change_ticket:
        type: string
        required: true
        default: "test"

permissions:
  id-token: write
  checks: write
  contents: write
  security-events: write
  actions: read
  pull-requests: read

env:
  MODULE_PATH: path/to/module # update

jobs:
  PreDeploy:
    name: PreDeploy
    uses: zilvertonz/maa-deployment-audit/.github/workflows/pre-deploy.yaml@v0
    secrets: inherit

  CodeScanning:
    needs:
      - PreDeploy
    name: CodeScanning
    runs-on: MA-Analytics-Runner
    container:
      image: ghcr.io/zilvertonz/shared-github-actions:v1-base
      credentials:
        username: GTHBAUTO_Zilver
        password: ${{ secrets.ORG_REPO_READ_ACCESS }}
    environment:
      name: audit
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set GitHub Read Acess Token
        run: git config --global url."https://${{ secrets.ORG_REPO_READ_ACCESS }}@github.com".insteadOf "https://github.com"

      - name: Load Environment Variables
        uses: zilvertonz/shared-github-actions/utility/load-dot-env@v1
        with:
          env_name: prod # update if testing lower environments

      - name: Load Common Variables
        uses: zilvertonz/shared-github-actions/utility/load-dot-env@v1
        with:
          env_name: common

      - name: Setup uv
        uses: zilvertonz/shared-github-actions/uv/setup@v1
        with:
          python_version: "3.11.6"
          install_tools: |
            tox==4.11.3
            poetry

      - name: IaC Linting
        uses: zilvertonz/shared-github-actions/lint/terraform-terragrunt@v1
        with:
          module: ${{ env.MODULE_PATH }}

      - name: Tox Testing
        run: |
          find $MODULE_PATH/lambda_code -name tox.ini -execdir tox run \;

      - name: Publish Test Report
        id: publish_junit
        uses: mikepenz/action-junit-report@v4
        if: success() || failure()
        with:
          report_paths: ${{ env.MODULE_PATH }}/lambda_code/*/reports/*.xml
          include_passed: true
          fail_on_failure: true
          commit: ${{ github.event.workflow_run.head_sha }}
          detailed_summary: true
    
      - name: upload xml artifacts
        id: xml_artifacts
        uses: actions/upload-artifact@v4
        with:
          name: xml-artifacts
          path: ${{ env.MODULE_PATH }}/lambda_code/*/reports/*.xml
  Deploy:
    needs:
      - CodeScanning
    name: Deploy
    uses: ./.github/workflows/deploy.yaml
    with:
      environment: prod # update if testing lower environments
      action: apply # update if testing lower environments
    secrets: inherit

  PostDeploy:
    needs:
      - Deploy
    name: PostDeploy
    uses: zilvertonz/maa-deployment-audit/.github/workflows/post-deploy.yaml@main
    with:
      environment: prod # OPTIONAL INPUT (default value is prod) - update if testing lower environments
      job_names: |
        Deploy
    secrets: inherit
```

## How It Works

1. **Pre Deploy**:
    runs `verify-pr-approvers` [shared action](https://github.com/zilvertonz/shared-github-actions/tree/main/compliance/verify-pr-approvers).

2. **Code Scanning**:
    generates and stores `.xml` test reports artifacts. This example uses `uv` [shared action](https://github.com/zilvertonz/shared-github-actions/tree/main/uv/setup) to install python and necessary tools for testing (tox and poetry). Next, lints Terraform code using `tf lint`[shared action](https://github.com/zilvertonz/shared-github-actions/tree/main/lint/terraform-terragrunt). Finally, tests python code using `tox`, publishes the test report using `mikepenz/action-junit-report@v4`, then uploads the reports as artifacts.

2. **Deploy**:
    Under this job you can define deployment steps. This example uses a [reusable deploy workflow](https://github.com/zilvertonz/silverton-analytics-scaffold-trunk/blob/main/.github/workflows/deploy.yaml).

3. **Post Deploy**:
    Post Deploy job runs `download-job-logs` [shared action](https://github.com/zilvertonz/shared-github-actions/tree/main/compliance/download-job-logs) and `s3-upload` [shared action](https://github.com/zilvertonz/shared-github-actions/tree/main/compliance/s3-upload) to download logs from the Deploy job and then upload all artifacts generated in the entire workflow run. This example uses the `post-deploy` [reusable workflow](https://github.com/zilvertonz/maa-deployment-audit/blob/main/.github/workflows/post-deploy.yaml) found in [scaffold repo](https://github.com/zilvertonz/silverton-analytics-scaffold-trunk)