#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SKILLS_DIR="${REPO_ROOT}/skills"
TESTS_DIR="${REPO_ROOT}/tests"

usage() {
    cat <<EOF
Usage:
  $(basename "$0") <skill-name>
  $(basename "$0") --all
  $(basename "$0") --help

Examples:
  $(basename "$0") code-review
  $(basename "$0") --all
EOF
}

fail() {
    echo "✗ $1"
    exit 1
}

test_skill() {
    local skill_name="$1"
    local skill_dir="${SKILLS_DIR}/${skill_name}"
    local skill_file="${skill_dir}/SKILL.md"
    local test_dir="${TESTS_DIR}/${skill_name}"

    echo
    echo "========================================"
    echo "Testing skill: ${skill_name}"
    echo "========================================"
    echo

    # ---------------------------------------------------------
    # 1. Skill exists
    # ---------------------------------------------------------

    if [[ ! -d "${skill_dir}" ]]; then
        fail "Skill directory does not exist: ${skill_dir}"
    fi

    if [[ ! -f "${skill_file}" ]]; then
        fail "SKILL.md is missing: ${skill_file}"
    fi

    echo "✓ Skill exists"

    # ---------------------------------------------------------
    # 2. Test directory
    # ---------------------------------------------------------

    if [[ ! -d "${test_dir}" ]]; then
        echo "⚠ No tests found for '${skill_name}'"
        echo
        return 0
    fi

    echo "✓ Test directory exists"

    # ---------------------------------------------------------
    # 3. Test cases
    # ---------------------------------------------------------

    local test_count=0
    local failed_count=0

    for test_file in "${test_dir}"/*.md; do
        [[ -f "${test_file}" ]] || continue

        test_count=$((test_count + 1))

        local test_name
        test_name="$(basename "${test_file}")"

        echo
        echo "Test: ${test_name}"

        # -----------------------------------------------------
        # Basic test contract
        #
        # Each test file must contain:
        #
        # ## Input
        #
        # <test input>
        #
        # ## Expected
        #
        # <expected behavior>
        # -----------------------------------------------------

        if ! grep -qE "^## Input[[:space:]]*$" "${test_file}"; then
            echo "  ✗ Missing '## Input' section"
            failed_count=$((failed_count + 1))
            continue
        fi

        if ! grep -qE "^## Expected[[:space:]]*$" "${test_file}"; then
            echo "  ✗ Missing '## Expected' section"
            failed_count=$((failed_count + 1))
            continue
        fi

        echo "  ✓ Test format is valid"
    done

    # ---------------------------------------------------------
    # 4. Results
    # ---------------------------------------------------------

    if [[ "${test_count}" -eq 0 ]]; then
        echo
        echo "⚠ No test cases found."
        return 0
    fi

    echo
    echo "Tests: ${test_count}"
    echo "Failures: ${failed_count}"

    if [[ "${failed_count}" -ne 0 ]]; then
        echo
        fail "Skill tests failed."
    fi

    echo
    echo "✓ Skill tests passed."
}

# -------------------------------------------------------------
# Arguments
# -------------------------------------------------------------

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

case "$1" in
    --help|-h)
        usage
        exit 0
        ;;

    --all)
        if [[ ! -d "${SKILLS_DIR}" ]]; then
            fail "Skills directory does not exist: ${SKILLS_DIR}"
        fi

        found=0

        for skill_dir in "${SKILLS_DIR}"/*; do
            [[ -d "${skill_dir}" ]] || continue

            skill_name="$(basename "${skill_dir}")"
            found=1

            test_skill "${skill_name}"
        done

        if [[ "${found}" -eq 0 ]]; then
            fail "No skills found."
        fi

        echo
        echo "All skill tests passed."
        ;;

    *)
        if [[ "$1" == -* ]]; then
            echo "Unknown option: $1"
            echo
            usage
            exit 1
        fi

        test_skill "$1"
        ;;
esac