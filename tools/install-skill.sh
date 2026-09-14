#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SKILLS_DIR="${REPO_ROOT}/skills"
VALIDATE_SCRIPT="${SCRIPT_DIR}/validate-skill.sh"

usage() {
    cat <<EOF
Usage:
  $(basename "$0") <skill-name> <target-project> --target <target> [--overwrite]
  $(basename "$0") --help

Targets:
  claude     Install to .claude/skills/
  agents     Install to .agents/skills/
  github     Install to .github/skills/
  all        Install to all supported locations

Options:
  --overwrite    Ask for confirmation before replacing an existing skill

Examples:
  $(basename "$0") code-review ../my-project --target claude
  $(basename "$0") code-review ../my-project --target claude --overwrite
  $(basename "$0") code-review ../my-project --target all --overwrite
EOF
}

fail() {
    echo
    echo "✗ $1"
    echo
    echo "Installation failed."
    exit 1
}

# -------------------------------------------------------------
# Arguments
# -------------------------------------------------------------

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
    exit 0
fi

if [[ $# -lt 4 || $# -gt 5 ]]; then
    echo "Invalid arguments."
    echo
    usage
    exit 1
fi

SKILL_NAME="$1"
TARGET_PROJECT="$2"

if [[ "$3" != "--target" ]]; then
    fail "Expected --target."
fi

TARGET="$4"
OVERWRITE=false

if [[ $# -eq 5 ]]; then
    if [[ "$5" != "--overwrite" ]]; then
        fail "Unknown option: $5"
    fi

    OVERWRITE=true
fi

# -------------------------------------------------------------
# Validate target
# -------------------------------------------------------------

case "${TARGET}" in
    claude|agents|github|all)
        ;;
    *)
        fail "Unknown target '${TARGET}'. Supported targets: claude, agents, github, all."
        ;;
esac

# -------------------------------------------------------------
# Resolve target project
# -------------------------------------------------------------

TARGET_PROJECT="${TARGET_PROJECT/#\~/${HOME}}"

if [[ ! -d "${TARGET_PROJECT}" ]]; then
    fail "Target project does not exist: ${TARGET_PROJECT}"
fi

TARGET_PROJECT="$(cd "${TARGET_PROJECT}" && pwd)"

# -------------------------------------------------------------
# Resolve skill
# -------------------------------------------------------------

SKILL_DIR="${SKILLS_DIR}/${SKILL_NAME}"

if [[ ! -d "${SKILL_DIR}" ]]; then
    fail "Skill does not exist: ${SKILL_NAME}"
fi

if [[ ! -f "${SKILL_DIR}/SKILL.md" ]]; then
    fail "SKILL.md is missing: ${SKILL_DIR}/SKILL.md"
fi

if [[ ! -x "${VALIDATE_SCRIPT}" ]]; then
    fail "Validation script is missing or not executable."
fi

# -------------------------------------------------------------
# Validate before installation
# -------------------------------------------------------------

echo "Validating skill: ${SKILL_NAME}"
echo

"${VALIDATE_SCRIPT}" "${SKILL_NAME}"

echo
echo "Validation passed."
echo

# -------------------------------------------------------------
# Determine installation directories
# -------------------------------------------------------------

declare -a TARGET_DIRS=()

case "${TARGET}" in
    claude)
        TARGET_DIRS+=("${TARGET_PROJECT}/.claude/skills")
        ;;

    agents)
        TARGET_DIRS+=("${TARGET_PROJECT}/.agents/skills")
        ;;

    github)
        TARGET_DIRS+=("${TARGET_PROJECT}/.github/skills")
        ;;

    all)
        TARGET_DIRS+=(
            "${TARGET_PROJECT}/.claude/skills"
            "${TARGET_PROJECT}/.agents/skills"
            "${TARGET_PROJECT}/.github/skills"
        )
        ;;
esac

# -------------------------------------------------------------
# Check existing installations
# -------------------------------------------------------------

declare -a EXISTING_SKILLS=()

for target_dir in "${TARGET_DIRS[@]}"; do
    target_skill_dir="${target_dir}/${SKILL_NAME}"

    if [[ -e "${target_skill_dir}" ]]; then
        EXISTING_SKILLS+=("${target_skill_dir}")
    fi
done

if [[ "${#EXISTING_SKILLS[@]}" -gt 0 ]]; then

    if [[ "${OVERWRITE}" != true ]]; then
        echo "The following skill installation(s) already exist:"
        echo

        for existing_skill in "${EXISTING_SKILLS[@]}"; do
            echo "  ${existing_skill}"
        done

        echo
        echo "Use --overwrite if you want to replace them."
        exit 1
    fi

    echo "The following skill installation(s) already exist:"
    echo

    for existing_skill in "${EXISTING_SKILLS[@]}"; do
        echo "  ${existing_skill}"
    done

    echo
    read -r -p "Overwrite existing installation(s)? [y/N] " confirmation

    case "${confirmation}" in
        y|Y|yes|YES)
            echo
            echo "Overwrite confirmed."
            ;;

        *)
            echo
            echo "Installation cancelled."
            exit 0
            ;;
    esac
fi

# -------------------------------------------------------------
# Install
# -------------------------------------------------------------

for target_dir in "${TARGET_DIRS[@]}"; do

    target_skill_dir="${target_dir}/${SKILL_NAME}"

    mkdir -p "${target_dir}"

    if [[ -e "${target_skill_dir}" ]]; then
        rm -rf "${target_skill_dir}"
    fi

    cp -R "${SKILL_DIR}" "${target_skill_dir}"

    if [[ ! -f "${target_skill_dir}/SKILL.md" ]]; then
        fail "Installation verification failed: ${target_skill_dir}"
    fi

    echo "✓ Installed:"
    echo "  ${target_skill_dir}"
done

echo
echo "Skill '${SKILL_NAME}' installed successfully."