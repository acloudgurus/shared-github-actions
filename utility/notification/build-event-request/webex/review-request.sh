#!/usr/bin/env bash

echo "Requesting review for repo: $REPO"
echo "PR link: $PR_LINK"

EVENT_NAME="Requesting a Review"
EVENT_DESC="Webex notification for a PR review via Event Service GitHub Action"

# Build event details
REQUESTED_BY=$(gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /users/$ACTOR \
    | jq -r '.email'
)
echo "Requested by: $REQUESTED_BY"
EVENT_DETAILS_JSON=$(jq -n \
    --arg "Pull request link" "[$PR_LINK]($PR_LINK)" \
    --arg "Requested by" "$REQUESTED_BY" \
    '$ARGS.named')
EVENT_DETAILS=$EVENT_DETAILS_JSON

REVIEWER_EMAIL=$(gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /users/$REVIEWER \
    | jq -r '.email'
)

HEADER="$EVENT_NAME"
FOOTER="Event Service notification via Github Action"

# Build API request body in json
JSON_BODY=$(jq -n \
    --arg event_name "$EVENT_NAME" \
    --arg event_desc "$EVENT_DESC" \
    --argjson event_details "$EVENT_DETAILS" \
    --arg person_email "$REVIEWER_EMAIL" \
    --arg header "$HEADER" \
    --arg footer "$FOOTER" \
    --arg markdown_body "$MARKDOWN_BODY" \
    '$ARGS.named')

echo "JSON body: $JSON_BODY"

{
    echo 'JSON_BODY<<EOF'
    echo "$JSON_BODY"
    echo 'EOF'
} >> $GITHUB_ENV
