#!/usr/bin/env bash
set -euo pipefail

REPO=$1
echo 'number,state,html_url,dependency.package.ecosystem,dependency.package.name,dependency.manifest_path,security_vulnerability.severity,security_advisory.cve_id,security_advisory.summary,created_at,updated_at,dismissed_at,dismissed_by,dismissed_reason,dismissed_comment,fixed_at,auto_dismissed_at'
  # -f ref=${REF} -f state=open 
gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -X GET /repos/zilvertonz/${REPO}/dependabot/alerts \
  | jq -r '.[] |
    [
        .number,
        .state,
        .html_url,
        .dependency.package.ecosystem,
        .dependency.package.name,
        .dependency.manifest_path,
        .security_vulnerability.severity,
        .security_advisory.cve_id,
        .security_advisory.summary,
        .created_at,
        .updated_at,
        .dismissed_at,
        .dismissed_by,
        .dismissed_reason,
        .dismissed_comment,
        .fixed_at,
        .auto_dismissed_at
    ] | @csv'
