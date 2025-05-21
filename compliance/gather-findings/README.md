# GitHub Action: Gather Historical Security Findings
This GitHub Action collects and stores historical findings from the repository's GitHub code scanning alerts, providing a strcutured JSON file with the findings for audit purposes.
> [!NOTE]
> THIS IS A PROTOTYPE! Checkout `security-hub` for a working version.

## Features

- Retrieves security findings for pull requests from GitHub Scanning Alerts.
- Filters fidings based on their state (`closed`) and resolution (`dismissed`).
- Outputs a JSON file containing the historical security findings.

## Inputs
| Input     | Required | Description                                       |
|-----------|----------|---------------------------------------------------|
|`token`|   Yes     |    GitHub token for running CLI commands. `GITHUB_TOKEN` secret.|
|`SECURITY_FINDINGS_FILE`|   No     |    Name of the file where the security findings will be stored, defaults to `historical_security_findings.json`.|

## Outputs

| Output     | Description                                       |
|-----------|----------------------------------------------------|
|`SECURITY_FINDINGS_FILE`|   Path to the JSON file containing he historical security findings.|

## Usage

Here's an example of how to use this action in your workflow:

```yaml
- name: upload artifacts to s3
  uses: zilvertonz/shared-github-actions/compliance/gather-findings@v0
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    SECURITY_FINDINGS_FILE: `SECURITY_FINDINGS_FILE.json`
```

## How It Works

1. **Get Commits and PRs**:
    The action uses Git commands to gather a list of commits and pull requests associated with the repository.

2. **Fetch Security Fidings**:
    Using the GitHub API, it retieves security alerts filtered by:
    - Pull Requests
    - State (`closed`)
    - Resolution (`dismissed`)

3. **Store Findings**:
    The findings are processed and appended to a JSON file named `historical_security_findings.json`

## Generated File Example

The output JSON file will look similar to this:

```json
[
    {
        "alert_number": 12345,
        "state": "closed",
        "resolution": "dismissed"
    },
...
]
```

