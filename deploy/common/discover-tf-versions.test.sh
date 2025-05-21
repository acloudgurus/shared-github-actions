#!/usr/bin/env bash

set -eo pipefail

################################################
# RUN WITHIN UBUNTU
# 
# from root of repo:
#
# docker run -it --rm -v "$PWD:/repo" -w /repo \
#   ubuntu bash /repo/deploy/common/discover-tf-versions.test.sh
#
#
################################################

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT="${DIR}/discover-tf-versions.sh"

export MODULE=/tmp/module/aws/base
MODULE_PARENT_DIR=/tmp/module/aws
MODULE_BASE_DIR=/tmp/module
export GITHUB_ENV=/tmp/github-env
export GITHUB_OUTPUT=/tmp/github-output

tf_version_filename=.terraform-version
tg_version_filename=.terragrunt-version

################################################
# TEST UTILS
################################################
setup_test() {
    test_name=$1
    tfv=$2
    tgv=$3
    mkdir -p $MODULE
    echo ""
    echo ""
    echo ""
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo $test_name
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    if [[ -n "$tfv" ]]; then
        echo $tfv > "$MODULE/$tf_version_filename"
    fi
    if [[ -n "$tgv" ]]; then
        echo $tgv > "$MODULE_PARENT_DIR/$tg_version_filename"
    fi

    touch $GITHUB_OUTPUT
}

clean_test() {
    rm -rf $MODULE_BASE_DIR
    unset TF_VERSION
    unset TG_VERSION
    # reset files
    printf "" > $GITHUB_ENV
    printf "" > $GITHUB_OUTPUT
}

expect_equals() {

    acutal_value=$1
    expected_value=$2

    if [[ "$expected_value" != "$acutal_value" ]]; then
        echo "FAIL: actual=${acutal_value} != expected=${expected_value}"
        exit 1
    else
        echo "PASS: actual=${acutal_value} != expected=${expected_value}"
    fi
}


################################################
# TESTS
################################################
test_when_env_vars_are_set_then_use_env_vars() {
    setup_test $FUNCNAME

    export TF_VERSION=tf1.1.1 
    export TG_VERSION=tg1.1.1
    bash $SCRIPT
    source $GITHUB_OUTPUT

    expect_equals tf1.1.1 $tf_version
    expect_equals tg1.1.1 $tg_version
    clean_test
}

test_when_tf_version_files_set_then_use_version_files() {
    tf_v=tf2.2.2
    tg_v=tg2.2.2
    setup_test $FUNCNAME $tf_v $tg_v

    bash $SCRIPT
    source $GITHUB_OUTPUT

    expect_equals $tf_v $tf_version
    expect_equals $tg_v $tg_version
    clean_test
}

test_when_none_set_then_exit_non_zero() {
    setup_test $FUNCNAME

    (bash $SCRIPT && echo "FAIL: error expect" && exit 1) || \
        echo "PASS: Error expected, exited non-zero: $?"

    clean_test
}

test_when_env_var_and_version_files_are_set_then_use_env_vars() {
    tf_v=tf4.4.4
    tg_v=tg4.4.4
    setup_test $FUNCNAME

    export TF_VERSION=tf4 
    export TG_VERSION=tg4 
    bash $SCRIPT
    source $GITHUB_OUTPUT

    expect_equals tf4 $tf_version
    expect_equals tg4 $tg_version
    clean_test
}

################################################
# EXECUTE TESTS
################################################

test_when_env_vars_are_set_then_use_env_vars
test_when_tf_version_files_set_then_use_version_files
test_when_none_set_then_exit_non_zero
test_when_env_var_and_version_files_are_set_then_use_env_vars
