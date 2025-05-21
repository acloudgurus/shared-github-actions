#!/usr/bin/env bash

# Usage:
#   ENV VARS:
#       - MODULE
#           from the root of the repo, which module
#       - TF_VERSION
#       - TG_VERSION


# @see terraform versions here: https://github.com/hashicorp/terraform/releases
# @see terragrunt versions here: https://github.com/gruntwork-io/terragrunt/releases
# as of 2024-09-04
# terraform latest version is: 1.9.5
# terragrunt latest version is: 0.66.9

# default to /dev/stdout for testing
GITHUB_ENV=${GITHUB_ENV:-/dev/stdout} 
GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/stdout} 

# is there a .terraform-version or .terragrunt-version file in the module
# directory or in the directory directly before the module directory.
#
# Example:
#   module/aws/base/.terraform-version
#   module/aws/base/.terragrunt-version
#   OR
#   module/aws/.terraform-version
#   module/aws/.terragrunt-version

# remove trailing slash
MODULE_DIR=${MODULE%/}
MODULE_TF_FILE="${MODULE_DIR}/.terraform-version"
MODULE_TG_FILE="${MODULE_DIR}/.terragrunt-version"

TG_FILE="${MODULE}/"

# Remove trailing slash (maybe) and last segment of the dir path
PARENT_DIR=$(dirname $MODULE)
PARENT_DIR_TG_FILE="${PARENT_DIR}/.terragrunt-version"
PARENT_DIR_TF_FILE="${PARENT_DIR}/.terraform-version"

log_message() {
    local message=$1
    local level=${2:-"debug"} # debug, notice, error
    echo "::${level}::${message}"
}

try_get_version() {
    local version_file=$1
    local version_var=$2

    if [[ -f "$version_file" ]]; then
        log_message "found version file: $version_file"
        export declare ${version_var}=$(cat $version_file)
    fi
}

# if there's a version file in the parent dir, send to github env
# this'll override the parent dir's entry too
if [[ -z "${TF_VERSION}" ]]; then

    log_message "TF_VERSION not set. Checking version files..."

    try_get_version $PARENT_DIR_TF_FILE "TF_VERSION"
    try_get_version $MODULE_TF_FILE "TF_VERSION"


    [[ -z "${TF_VERSION}" ]] && log_message "Terraform version not set!" "error" && exit 1;

    log_message "TF_VERSION=${TF_VERSION}"
else
    log_message "TF_VERSION already set: $TF_VERSION"
fi
echo "TF_VERSION=${TF_VERSION}" >> $GITHUB_ENV

if [[ -z "${TG_VERSION}" ]]; then

    log_message "TG_VERSION not set. Checking version files..."

    try_get_version $PARENT_DIR_TG_FILE "TG_VERSION"
    try_get_version $MODULE_TG_FILE "TG_VERSION"

    [[ -z "${TG_VERSION}" ]] && log_message "Terragrunt version not set!" "error" && exit 1;


    log_message "TG_VERSION=${TG_VERSION}"
else
    log_message "TG_VERSION already set: $TG_VERSION"
fi

echo "TG_VERSION=${TG_VERSION}" >> $GITHUB_ENV

log_message "tf_version -> ${TF_VERSION}"
log_message "tg_version -> ${TG_VERSION}"

# send to gh output
echo "tf_version=${TF_VERSION}" >> $GITHUB_OUTPUT
echo "tg_version=${TG_VERSION}" >> $GITHUB_OUTPUT
