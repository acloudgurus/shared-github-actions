#!/usr/bin/env bash

echo "Parsing PR title" 
CHANGE_TYPE=$(echo $PR_TITLE | grep -o '^[a-zA-Z!]*')
echo "PR TITLE $PR_TITLE"
echo "CHANGE TYPE $CHANGE_TYPE"
if [ -n "$CHANGE_TYPE" ]; then
    if [ "$CHANGE_TYPE" == "feat!" ]; then
        VERSION_TYPE="major"
    elif [ "$CHANGE_TYPE" == "feat" ]; then
        VERSION_TYPE="minor"
    elif [ "$CHANGE_TYPE" == "fix" ]; then
        VERSION_TYPE="patch"
    else
        echo "::warning title=Invalid title::Invalid PR title. Check to ensure that the title meets conventional commit standards"
    fi
fi
echo "Version type $VERSION_TYPE"
echo "VERSION_TYPE=$VERSION_TYPE" >> $GITHUB_ENV
