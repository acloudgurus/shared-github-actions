#!/bin/bash
set -e -o pipefail

pip install poetry
pushd $PACKAGE_PATH

# increment versions
poetry version $VERSION_TYPE

NEW_VERSION=$(poetry version -s)

echo "Updated version to $NEW_VERSION"

popd
git add ${PACKAGE_PATH}/pyproject.toml
git commit -m "Update Poetry Version to $NEW_VERSION"
# Push changes to PR branch
git push origin HEAD:$CHANGE_BRANCH
