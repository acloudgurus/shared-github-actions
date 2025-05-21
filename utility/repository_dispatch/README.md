# Deploy Workflow via Repository Dispatch Action

This GitHub Shared Action makes API call to trigger a workflow run in a different repository via `repository_dispatch` event.

### Inputs

+ token (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`
+ event_type (required)
  + The event type that identifies the workflow to dispatch. Ensure this amtches the `repository_dispatch` types configured in the target workflow.
  + type: `string`
+ repo_name (required)
  + The name of the repository where the workflow will be triggered. Ignore repo `owner`. Example: ignore `zilverton` from `zilverton/silverton-analytics-playbook`, use only `silverton-analytics-playbook` as input.
  + type: `string`

### Using this action

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```yaml
jobs:
  trigger-workflows:
    runs-on: zilverton-private-x64-ubuntu
    steps:
      - name: Trigger repository dispatch
        uses: zilvertonz/shared-github-actions/utility/repository_dispatch@v0
        with:
          token: ${{ github.token }}
          repo_name: silverton-analytics-playbook
          event_type: publish
```

## Notes

- The `event_type` parameter must match the `repository_dispatch` types defined in the target repository's workflow configuration. Example:
```yaml
name: Deploy

on:
  repository_dispatch:
    types:
      - publish

jobs:
  Deploy:
```

## How it Works

This action:
1. Calls the GitHub API via the `gh api` command to dispatch an event to the specified repository.

The request structure includes:
- A `POST` request to the `/dispatches` endpoint of the target repository.
- The `event_type` set in the payload to identify the target workflow.

## Example API Call

```bash
gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/<owner>/<repo>/dispatches \
    -f event_type="<your-matching-event-type>"
