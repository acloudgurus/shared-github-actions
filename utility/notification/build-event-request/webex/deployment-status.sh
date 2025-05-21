#!/usr/bin/env bash

echo "Deployment status notification for: $REPO_LINK"
echo "Deployment tag: $DEPLOYMENT_TAG"

EVENT_NAME="Deployment Status"
EVENT_DESC="Webex notification about deployment status via Event Service GitHub Action"

# Build event details
EVENT_DETAILS_JSON=$(jq -n \
    --arg "Repo" "[$REPO]($REPO_LINK/tree/$BRANCH)" \
    --arg "Branch" "$BRANCH" \
    --arg "Status" "$DEPLOYMENT_STATUS" \
    --arg "Environment" "$DEPLOYMENT_ENV" \
    '$ARGS.named')

if [[ -n "${DEPLOYMENT_TAG}" ]]; then
    echo "Finding deployment tag"
    RELEASE=$(jq -n \
        --arg "Release" "[$DEPLOYMENT_TAG]($REPO_LINK/releases/tag/$DEPLOYMENT_TAG)" \
        '$ARGS.named')
    EVENT_DETAILS_JSON=$(jq --slurp 'add' <(echo "$EVENT_DETAILS_JSON") <(echo "$RELEASE"))
    echo "EVENT_DETAILS_JSON: $EVENT_DETAILS_JSON"
fi

EVENT_DETAILS=$EVENT_DETAILS_JSON

HEADER="$EVENT_NAME"
FOOTER="Event Service notification via Github Action"

# Build API request body in json
JSON_BODY=$(jq -n \
    --arg event_name "$EVENT_NAME" \
    --arg event_desc "$EVENT_DESC" \
    --argjson event_details "$EVENT_DETAILS" \
    --arg header "$HEADER" \
    --arg footer "$FOOTER" \
    --arg markdown_body "$MARKDOWN_BODY" \
    '$ARGS.named')

# Check if the Webex room id is provided
if [[ -n "${WEBEX_ROOM_ID}" ]]; then
    ROOM_ID=$(jq -n \
        --arg "room_id" "$WEBEX_ROOM_ID" \
        '$ARGS.named')
    JSON_BODY=$(jq --slurp 'add' <(echo "$JSON_BODY") <(echo "$ROOM_ID"))
    echo "Sending notification to Webex room: $WEBEX_ROOM_ID"
else
    # Notification will be sent to the actor of the commit
    ACTOR_EMAIL=$(gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /users/$ACTOR \
    | jq -r '.email')
    PERSON_EMAIL=$(jq -n \
        --arg "person_email" "$ACTOR_EMAIL" \
        '$ARGS.named')
    JSON_BODY=$(jq --slurp 'add' <(echo "$JSON_BODY") <(echo "$PERSON_EMAIL"))
    echo "Sending notification to the commit actor: $ACTOR_EMAIL"
fi

echo "JSON body: ${JSON_BODY}"

{
    echo 'JSON_BODY<<EOF'
    echo "$JSON_BODY"
    echo 'EOF'
} >> $GITHUB_ENV

