#!/usr/bin/env bash

echo "Sending Webex notification"
echo "JSON body: $JSON_BODY"

EVENT_SERVICE_URL="https://events.ma-analytics-$EVENT_SERVICE_ENV.aws.zilverton.com/v1/webex"

RESPONSE=$(curl --write-out "%{http_code}\n" --silent "$EVENT_SERVICE_URL" \
    -d "$JSON_BODY" \
    -H "Authorization: $ACCESS_TOKEN" \
    -H "Content-Type: application/json")

echo "$RESPONSE"
STATUS_CODE="$(echo $RESPONSE | grep -o '...$')"
echo "Response status code: $STATUS_CODE"

if [[ "$STATUS_CODE" == 401 ]]; then
        echo "::error title=Unauthorized::Check that the appropriate event_service_env has been set"
        exit 1
fi

if [[ "$STATUS_CODE" != 200 ]]; then
    ERROR=$(echo $RESPONSE | jq 'if .error != "" then .error else .message end')
    echo "::error title=Error in sending Webex notification::$ERROR"
    exit 1
fi
