#!/usr/bin/env bash
set -euo pipefail
REPO_ID=$1
# Filters:
#   ComplianceStatus:
#     - Comparison: EQUALS
#       Value: FAILED
#   # SeverityNormalized:
#   #   - Gte: 40
#   # ProductName:
#   #   - Value: Macie
#   #     Comparison: EQUALS
#   #   - Value: Inspector
#   #     Comparison: EQUALS
#   ResourceTags:
#     - Key: SourceRepoID
#       Value: "${REPO_ID}"
#       Comparison: EQUALS
#     # - Key: AppName
#     #   Value: "MAA Alarm Service"
#     #   Comparison: EQUALS
#
#   RecordState:
#     - Value: ACTIVE
#       Comparison: EQUALS
CLI_INPUT_YAML="Filters:
  ComplianceStatus:
    - Comparison: EQUALS
      Value: FAILED
  ResourceTags:
    - Key: SourceRepoID
      Value: '${REPO_ID}'
      Comparison: EQUALS
  RecordState:
    - Value: ACTIVE
      Comparison: EQUALS
"
echo 'AwsAccountName,Title,Description,ResourceId,WorkflowStatus,Severity,ProductARN,GeneratorID,ProcessedAt'
aws securityhub get-findings --cli-input-yaml "$CLI_INPUT_YAML" | \
     jq -r '.Findings[] | [
         .AwsAccountName,
         .Title,
         .Description,
         .Resources[].Id,
         .Workflow.Status,
         .Severity.Label,
         .ProductArn,
         .GeneratorId,
         .ProcessedAt
     ] | @csv'
