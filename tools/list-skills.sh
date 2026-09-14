#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"

usage() {
    cat <<EOF
Usage:
  $(basename "$0")
  $(basename "$0") --help
EOF
}

if [[ $# -gt 0 ]]; then
    case "$1" in
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo
            usage
            exit 1
            ;;
    esac
fi

if [[ ! -d "${SKILLS_DIR}" ]]; then
    echo "Skills directory does not exist: ${SKILLS_DIR}"
    exit 1
fi

found=0

echo "Available skills"
echo "================"
echo

for skill_dir in "${SKILLS_DIR}"/*; do
    [[ -d "${skill_dir}" ]] || continue

    skill_name="$(basename "${skill_dir}")"
    skill_file="${skill_dir}/SKILL.md"

    if [[ ! -f "${skill_file}" ]]; then
        echo "⚠ ${skill_name} — SKILL.md missing"
        continue
    fi

    description="$(
        awk '
            BEGIN { in_frontmatter=0 }

            /^---$/ {
                if (in_frontmatter == 0) {
                    in_frontmatter=1
                } else {
                    in_frontmatter=2
                }
                next
            }

            in_frontmatter == 1 && /^description:/ {
                sub(/^description:[[:space:]]*/, "")
                print
                exit
            }
        ' "${skill_file}"
    )"

    if [[ -z "${description}" ]]; then
        description="No description found"
    fi

    echo "• ${skill_name}"
    echo "  ${description}"
    echo

    found=1
done

if [[ "${found}" -eq 0 ]]; then
    echo "No skills found."
    exit 1
fi