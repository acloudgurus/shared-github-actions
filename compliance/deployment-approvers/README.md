# GitHub Action: Gather Deployment Approvers
This GitHub Action collects and stores the names of approvers for a deployment workflow, providing a record for audting and compliance purposes.

## Features

- Retrieves a list of deployment approvers using the GitHub API.
- Generates a text file with  the approvers' usernames.
- Uploads the approvers list as an artifact for record-keeping.

## Inputs
| Input     | Required | Description                                       |
|-----------|----------|---------------------------------------------------|
|`token`|   Yes     |    GitHub token for running CLI commands. `GITHUB_TOKEN` secret.|

## Outputs

| Output     | Description                                       |
|-----------|----------------------------------------------------|
|`WORKFLOW_RUN_APPROVERS`|   Path to the file containing the approvers' usernames.|

## Usage

Here's an example of how to use this action in your workflow:

```yaml
- name: Gather Deployment Approvers
  uses: zilvertonz/shared-github-actions/compliance/deployment-approvers@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
```

## How It Works

1. **Retrieve Approvers**:
    The action uses the GitHub API to fetch the list of users who approved the deployment for the current workflow run.

2. **Generate Approvers File**:
    The list of approvers is written to a text file.

3. **Upload Artifact**:
    The generated file is uploadad as an artifact.