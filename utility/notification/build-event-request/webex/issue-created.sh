#!/usr/bin/env bash

echo "Issue createad notification for: $REPO"
echo "Issue title: $ISSUE_TITLE"
echo "Issue link: $ISSUE_URL"

EVENT_NAME="Issue Created"
EVENT_DESC="Webex notification for a new created GitHub issue via Event Service GitHub Action"

# Build event details
EVENT_DETAILS_JSON=$(jq -n \
    --arg "Repo" "[$REPO]($REPO_LINK)" \
    --arg "Title" "[$ISSUE_TITLE]($ISSUE_URL)" \
    --arg "Creator" "$ACTOR" \
    '$ARGS.named')

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

