#!/usr/bin/env bash

echo "Version type to release: $VERSION_TYPE"
# Get the latest version of tag
LATEST_TAG=$(git tag | grep -v '^v[0-9]\+$' | sort -V | tail -1)
echo "Latest tag: $LATEST_TAG"

NEW_MAJOR_VERSION=false
if [ ! -n "$LATEST_TAG" ]; then
    echo "Creating the first tag"
    case "$VERSION_TYPE" in
        major)
        NEW_TAG="v1.0.0"
        NEW_MAJOR_VERSION=true
        ;;
        minor)
        NEW_TAG="v0.1.0"
        ;;
        patch)
        NEW_TAG="v0.0.1"
        ;;
    esac
else
    # Increment tag based on VERSION_TYPE
    echo "Incrementing tag version: $VERSION_TYPE"
    IFS=. read -r MAJOR MINOR PATCH <<<"${LATEST_TAG:1}"
    case "$VERSION_TYPE" in
        major)
            NEW_TAG="v$((MAJOR+1)).0.0"
            NEW_MAJOR_VERSION=true
            ;;
        minor)
            NEW_TAG="v$MAJOR.$((MINOR+1)).0"
            ;;
        patch)
            NEW_TAG="v$MAJOR.$MINOR.$((PATCH+1))"
            ;;
    esac
fi

# Create tag
git tag $NEW_TAG
git push origin $NEW_TAG
echo "$NEW_TAG has been pushed successfully"

echo "version=$NEW_TAG" >> $GITHUB_OUTPUT

# If configured to track the major version as a tag
if [ "$TAG_MAJOR_VERSION" = true ]; then
    # If there is a new major version to tag
    if [ "$NEW_MAJOR_VERSION" = true ]; then
        # If this is the initial major version
        if [ "$NEW_TAG" = "v1.0.0" ]; then
            echo "Pushing initial major tag v1"
            git tag v1
            git push origin v1
        else
            echo "Pushing new major tag v$((MAJOR+1))"
            git tag "v$((MAJOR+1))"
            git push origin "v$((MAJOR+1))"
        fi
    # Else we increment the current major version tag to the newest non-major release
    else
        echo "Updating ref to major tag v$MAJOR"
        git tag --force "v$MAJOR" $NEW_TAG
        git push origin "v$MAJOR" --force
    fi
fi

# Create release notes
gh release create $NEW_TAG --generate-notes --notes-start-tag "$LATEST_TAG"
echo "Release notes have been created"
