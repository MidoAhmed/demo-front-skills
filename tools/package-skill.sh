#!/usr/bin/env bash

set -euo pipefail

# Resolve repository root regardless of the current working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SKILLS_DIR="${REPO_ROOT}/skills"
DIST_DIR="${REPO_ROOT}/dist"
VALIDATE_SCRIPT="${SCRIPT_DIR}/validate-skill.sh"

usage() {
    cat <<EOF
Usage:
  $(basename "$0") <skill-name>
  $(basename "$0") --help

Examples:
  $(basename "$0") code-review
EOF
}

fail() {
    echo "✗ $1"
    echo
    echo "Packaging failed."
    exit 1
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

    --*)
        echo "Unknown option: $1"
        echo
        usage
        exit 1
        ;;

    *)
        SKILL_NAME="$1"
        ;;
esac

SKILL_DIR="${SKILLS_DIR}/${SKILL_NAME}"
ARCHIVE="${DIST_DIR}/${SKILL_NAME}.zip"

# -------------------------------------------------------------
# Preconditions
# -------------------------------------------------------------

if [[ ! -d "${SKILL_DIR}" ]]; then
    fail "Skill directory does not exist: ${SKILL_DIR}"
fi

if [[ ! -f "${SKILL_DIR}/SKILL.md" ]]; then
    fail "SKILL.md is missing: ${SKILL_DIR}/SKILL.md"
fi

if [[ ! -x "${VALIDATE_SCRIPT}" ]]; then
    fail "Validation script is missing or not executable: ${VALIDATE_SCRIPT}"
fi

# -------------------------------------------------------------
# Validate before packaging
# -------------------------------------------------------------

echo "Validating skill: ${SKILL_NAME}"
echo

"${VALIDATE_SCRIPT}" "${SKILL_NAME}"

echo
echo "Validation passed."
echo

# -------------------------------------------------------------
# Prepare dist directory
# -------------------------------------------------------------

mkdir -p "${DIST_DIR}"

# Remove previous package for this skill.
rm -f "${ARCHIVE}"

# -------------------------------------------------------------
# Package
# -------------------------------------------------------------

echo "Packaging skill: ${SKILL_NAME}"
echo

cd "${SKILLS_DIR}"

zip -r "${ARCHIVE}" "${SKILL_NAME}" \
    -x "*/.DS_Store" \
    -x "*/.git/*" \
    -x "*/.git" \
    -x "*/node_modules/*" \
    -x "*/__pycache__/*" \
    >/dev/null

# -------------------------------------------------------------
# Verify archive
# -------------------------------------------------------------

if [[ ! -f "${ARCHIVE}" ]]; then
    fail "Archive was not created: ${ARCHIVE}"
fi

echo "Archive contents:"
echo

unzip -l "${ARCHIVE}"

echo
echo "✓ Package created:"
echo "  ${ARCHIVE}"