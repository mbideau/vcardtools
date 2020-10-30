#!/bin/sh

set -e

if [ -z "$DEBUG" ]; then
    DEBUG=false
fi
IFS_BAK="$IFS"
test_dir="$(dirname "$(realpath "$0")")"
cases_dir="$test_dir"/cases
project_dir="$(dirname "$test_dir")"
python_bin="$project_dir"/bin/python3
vcardtools_py="$project_dir"/vcardtools.py

if [ ! -f "$vcardtools_py" ]; then
    echo "Error: failed to find vcardtools python script '$vcardtools_py'" >&2
    exit 1
fi

if [ ! -e  "$python_bin" ]; then
    echo "Error: the project directory '$python_bin' is not a python virtualenv" >&2
    echo "       you can run : python -m venv '$python_bin, to make one" >&2
    exit 1
fi

find "$cases_dir" -maxdepth 1 -type d -not -path "$cases_dir" | while read -r case_dir; do
    case_name="$(basename "$case_dir")"
    sources_dir="$case_dir"/src
    expected_dir="$case_dir"/expected
    options_file="$case_dir"/options

    if [ ! -d "$sources_dir" ]; then
        echo "$case_name: FAIL (sources dir '$sources_dir' doesn't exist)"
        continue
    fi
    if [ ! -d "$expected_dir" ]; then
        echo "$case_name: FAIL (expectations dir '$expected_dir' doesn't exist)"
        continue
    fi

    options=
    if [ -f "$options_file" ]; then
        options="$(head -n 1 "$options_file")"
    fi

    tmp_dir="$(mktemp -u "/tmp/vcardtools-tests.XXXXXXXXXX.tmp")"
    tmp_err="$(mktemp "/tmp/vcardtools-tests.XXXXXXXXXX.err.tmp")"
    if [ "$DEBUG" = 'true' ]; then
        echo "[DEBUG] running: '$python_bin' '$vcardtools_py' --log-level WARNING $options '$tmp_dir' '$sources_dir'/*" >&2
    fi

    failed=false
 
    # shellcheck disable=SC2086
    if ! "$python_bin" "$vcardtools_py" --log-level WARNING $options "$tmp_dir" "$sources_dir"/* 2>"$tmp_err"; then
        failed=true
    fi

    expectations_matched=true

    if [ -f "$expected_dir"/FAILURE ]; then
        case_exp="$expected_dir"/FAILURE
        if [ "$failed" != 'true' ]; then
            echo "$case_name: FAIL (should have failed but did not)'"
            expectations_matched=false
        elif ! diff -q "$case_exp" "$tmp_err" >/dev/null 2>&1; then
            echo "$case_name: FAIL (expected file '$(basename "$case_exp")' differs)'"
            expectations_matched=false
            if [ "$DEBUG" = 'true' ]; then
                diff --color=always "$case_exp" "$tmp_err" | sed 's/^/[DEBUG] /' >&2
            fi
        fi
    elif [ "$failed" = 'true' ]; then
        echo "$case_name: FAIL (failed but should have succeeded)"
        if [ "$DEBUG" = 'true' ]; then
            sed 's/^/[DEBUG] /' "$tmp_err" >&2
        fi
    else
        IFS="
"
        # shellcheck disable=SC2044
        for case_exp in $(find "$expected_dir" -maxdepth 1 -type f -o -type l); do
            IFS="$IFS_BAK"
            case_out="$tmp_dir/$(basename "$case_exp")"
            if [ "$DEBUG" = 'true' ]; then
                echo "[DEBUG] comparing '$case_exp' to '$case_out'" >&2
            fi
            if [ ! -f "$case_out" ]; then
                echo "$case_name: FAIL (missing expected file '$(basename "$case_exp")'"
                expectations_matched=false
            elif ! diff -q "$case_exp" "$case_out" >/dev/null 2>&1; then
                echo "$case_name: FAIL (expected file '$(basename "$case_exp")' differs)'"
                expectations_matched=false
                if [ "$DEBUG" = 'true' ]; then
                    diff --color=always "$case_exp" "$case_out" | sed 's/^/[DEBUG] /' >&2
                fi
            fi
        done
    fi

    if [ "$expectations_matched" = 'true' ]; then
        echo "$case_name: OK"
    fi

    #echo "$tmp_dir" "$tmp_err"
    rm -fr "$tmp_dir" "$tmp_err"
done
