#!/usr/bin/env bash

set -euo pipefail

# Resolve repository root regardless of the current working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"

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
    echo
    echo "Validation failed."
    exit 1
}

validate_skill() {
    local skill_name="$1"
    local skill_dir="${SKILLS_DIR}/${skill_name}"

    echo
    echo "Validating skill: ${skill_name}"
    echo

    # ---------------------------------------------------------
    # 1. Skill directory
    # ---------------------------------------------------------

    if [[ ! -d "${skill_dir}" ]]; then
        fail "Skill directory does not exist: ${skill_dir}"
    fi

    echo "✓ Skill directory exists"

    # ---------------------------------------------------------
    # 2. SKILL.md
    # ---------------------------------------------------------

    if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
        fail "SKILL.md is missing"
    fi

    echo "✓ SKILL.md exists"

    # ---------------------------------------------------------
    # 3. Official Agent Skills validator
    # ---------------------------------------------------------

    if ! command -v skills-ref >/dev/null 2>&1; then
        echo "✗ skills-ref is not installed"
        echo
        echo "Install the Agent Skills reference validator:"
        echo
        echo "  pipx install \"git+https://github.com/agentskills/agentskills.git#subdirectory=skills-ref\""
        echo
        exit 1
    fi

    if ! skills-ref validate "${skill_dir}"; then
        echo
        echo "✗ skills-ref validation failed"
        exit 1
    fi

    echo "✓ skills-ref validation passed"

    # ---------------------------------------------------------
    # 4. Check referenced local files
    # ---------------------------------------------------------

    local missing_reference=0

    while IFS= read -r reference; do
        [[ -z "${reference}" ]] && continue

        # Ignore URLs and anchors.
        if [[ "${reference}" =~ ^https?:// ]]; then
            continue
        fi

        if [[ "${reference}" =~ ^# ]]; then
            continue
        fi

        local target="${skill_dir}/${reference}"

        if [[ ! -e "${target}" ]]; then
            echo "✗ Referenced file does not exist: ${reference}"
            missing_reference=1
        fi
    done < <(
        grep -oE '\]\([^)]+\)' "${skill_dir}/SKILL.md" 2>/dev/null \
            | sed 's/^](//; s/)$//' \
            || true
    )

    if [[ "${missing_reference}" -ne 0 ]]; then
        echo
        echo "✗ Local reference validation failed"
        exit 1
    fi

    echo "✓ Local references are valid"

    echo
    echo "Skill '${skill_name}' is valid."
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

            validate_skill "${skill_name}"
        done

        if [[ "${found}" -eq 0 ]]; then
            fail "No skills found in ${SKILLS_DIR}"
        fi

        echo
        echo "All skills are valid."
        ;;

    *)
        if [[ "$1" == -* ]]; then
            echo "Unknown option: $1"
            echo
            usage
            exit 1
        fi

        validate_skill "$1"
        ;;
esac