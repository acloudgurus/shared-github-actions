# GitHub Action: Upload Artifacts to S3 Audit Bucket

This GitHub Action uploads combined artifacts to an S3 bucket for audit purposes

## Features

- Downloads artifacts generated in previous workflow steps (including separate jobs).
- Combines and compresses artifacts into a single `.zip` file.
- Uploads the compressed file to an S3 bucket with a structured path.

## Inputs
| Input     | Required | Default Value | Description                                       |
|-----------|----------|---------------|---------------------------------------------------|
|`environment`|   No     |        prod       | The s3 bucket where the artifacts will be uploaded|

## Output Path Structure

The artifacts are stored in the following path structure within the S3 bucket:

```
silverton-maa-global-artifactory-${ENV}/adjudicator/<repository_name>/year/month/day/workflow_<run_id>.zip
```

## Usage

Here's an example of how to use this action in your workflow:

```yaml
- name: upload artifacts to s3
  uses: zilvertonz/shared-github-actions/compliance/s3-upload@v0
  with:
    environment: dev # prod is default
```

## How It Works

1. **Artifact Download**:
    The action usues the `actions/download-artifact` to fetch all workflow artifacts

2. **Artifact Preparation**:
    Artifacts are combined into a single folder, compressed into a `.zip` file.

3. **Upload to S3**:
    The compressed file is uploaded to S3 bucket using the AWS CLI. The path structure is dynamically generated based on the repository name, current date, and workflow run ID.