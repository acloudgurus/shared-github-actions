#!/usr/bin/env bash

echo "Fetching version type from label"
PR_LABELS=$(gh pr view $PR_NUMBER --json labels --jq 'try(.labels[].name)')
VERSION_TYPE_LABEL=$(echo "$PR_LABELS" | grep -Ew 'major|minor|patch' || true)

# Raise an error if PR does not contain any version label (ie: major, minor, patch)
# or if it contains more than one
if [ -z "$VERSION_TYPE_LABEL" ]; then
    echo "::warning title=Invalid labels::Pull request must be assigned one (1) of the following labels: 'major', 'minor', or 'patch' if you want to create a new release"
elif [ $(echo $VERSION_TYPE_LABEL | wc -w) -gt 1 ]; then
    echo "::warning title=Invalid labels::Only one version label ('major', 'minor', or 'patch') is allowed"
fi
echo "VERSION_TYPE=$VERSION_TYPE_LABEL" >> $GITHUB_ENV
echo "Version type from label: $VERSION_TYPE_LABEL"