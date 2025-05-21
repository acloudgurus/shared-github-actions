#!/usr/bin/env bash
set -eo pipefail

# external-checks-git or external-checks-dir
if [[ ! -z "$INPUT_EXT_CHECK" ]]; then
    if [[ $INPUT_EXT_CHECK == *".git"*  || $INPUT_EXT_CHECK == *"https:"* ]]; then
        ARG_EXT_CHECK="--external-checks-git '$INPUT_EXT_CHECK'"
    else
        ARG_EXT_CHECK="--external-checks-dir '$INPUT_EXT_CHECK'"
    fi
fi

# soft-fail
if [[ "$INPUT_SOFT_FAIL" == "true" ]]; then
  ARG_SOFT_FAIL=--soft-fail
fi


EXTRA_ARGS=""
if [[ ! -z "$ARG_EXT_CHECK" ]]; then
  EXTRA_ARGS="$EXTRA_ARGS $ARG_EXT_CHECK"
fi

if [[ ! -z "$ARG_SOFT_FAIL" ]]; then
  EXTRA_ARGS="$EXTRA_ARGS $ARG_SOFT_FAIL"
fi

# skip-check
if [[ -n "$INPUT_SKIP_CHECK" ]]; then
    ARG_SKIP_CHECK="--skip-check $INPUT_SKIP_CHECK"
fi

if [[ ! -z "$ARG_SKIP_CHECK" ]]; then
  EXTRA_ARGS="$EXTRA_ARGS $ARG_SKIP_CHECK"
fi

echo "ARG_EXT_CHECK = $ARG_EXT_CHECK"
echo "ARG_SOFT_FAIL = $ARG_SOFT_FAIL"
echo "ARG_SKIP_CHECK = $ARG_SKIP_CHECK"
echo "EXTRA ARG = $EXTRA_ARGS"
echo "EXTRA_ARG=$EXTRA_ARGS" >> $GITHUB_ENV


