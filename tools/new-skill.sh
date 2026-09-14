#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SKILLS_DIR="${REPO_ROOT}/skills"

usage() {
    cat <<EOF
Usage:
  $(basename "$0") <skill-name>
  $(basename "$0") --help

Examples:
  $(basename "$0") bug-debugging
  $(basename "$0") test-engineering
EOF
}

fail() {
    echo
    echo "✗ $1"
    echo
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

if [[ $# -ne 1 ]]; then
    fail "Expected exactly one argument: <skill-name>"
fi

SKILL_NAME="$1"

# -------------------------------------------------------------
# Validate skill name
# -------------------------------------------------------------

if [[ ! "${SKILL_NAME}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    fail "Invalid skill name '${SKILL_NAME}'.

Skill names must:
  - use lowercase letters
  - use numbers when needed
  - use hyphens as separators
  - not start or end with a hyphen
  - not contain consecutive hyphens"
fi

if [[ ${#SKILL_NAME} -gt 64 ]]; then
    fail "Skill name must not exceed 64 characters."
fi

# -------------------------------------------------------------
# Resolve paths
# -------------------------------------------------------------

SKILL_DIR="${SKILLS_DIR}/${SKILL_NAME}"
SKILL_FILE="${SKILL_DIR}/SKILL.md"

# -------------------------------------------------------------
# Prevent overwrite
# -------------------------------------------------------------

if [[ -e "${SKILL_DIR}" ]]; then
    fail "Skill already exists: ${SKILL_DIR}"
fi

# -------------------------------------------------------------
# Create skill
# -------------------------------------------------------------

mkdir -p "${SKILL_DIR}"

cat > "${SKILL_FILE}" <<EOF
---
name: ${SKILL_NAME}
description: TODO — Describe what this skill does and when it should be used.
---

# ${SKILL_NAME}

## Purpose

Describe the purpose of this skill.

Explain:

- What problem it solves
- What type of work it handles
- What the agent should accomplish

---

## Workflow

Describe the steps the agent should follow.

### 1. Understand the task

Determine:

- The requested outcome
- Relevant requirements
- Constraints
- Existing project conventions

### 2. Inspect the relevant context

Inspect only the files, code, documentation, and resources relevant to the task.

### 3. Perform the task

Describe the concrete actions the agent should take.

### 4. Validate the result

Verify:

- Correctness
- Relevant edge cases
- Tests
- Project conventions
- Regression risks

---

## Output

Define the expected output of the skill.

---

## Rules

Define important constraints and things the agent must avoid.
EOF

echo "✓ Skill created successfully."
echo
echo "Skill:"
echo "  ${SKILL_NAME}"
echo
echo "Location:"
echo "  ${SKILL_DIR}"
echo
echo "Next:"
echo "  Edit ${SKILL_FILE}"