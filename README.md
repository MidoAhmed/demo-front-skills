# Agent Skills Repository

## Phase A — Repository infrastructure

- **A1. Repository structure**
- **A5. `new-skill.sh`**
- **A2. `validate-skill.sh`**
- **A4. `test-skill.sh`**
- **A3. `package-skill.sh`**
- **A6. `install-skill.sh`**
- **A7. README / documentation**

## Phase B — Build skills

- **B1. `code-review`** ← current
- **B2. `bug-debugging`**
- **B3. `regression-check`**
- **B4. `test-engineering`**
- **B5. `feature-implementation`**

## Skill lifecycle

```text
Create
  ↓
Validate
  ↓
Test
  ↓
Package
  ↓
Install locally
  ↓
Test in real project
```

## creation workflow

```text
./tools/new-skill.sh bug-debugging
             │
             ▼
       Edit SKILL.md
             │
             ▼
./tools/validate-skill.sh bug-debugging
             │
             ▼
./tools/test-skill.sh bug-debugging
             │
             ▼
./tools/package-skill.sh bug-debugging
             │
             ▼
./tools/install-skill.sh ...
```

## Repository layout

```text
agent-skills/
├── skills/
│   └── code-review/
│       ├── SKILL.md
│       └── references/
│           └── review-checklist.md
│
├── tools/
│   ├── validate-skill.sh
│   ├── package-skill.sh
│   ├── test-skill.sh
│   ├── list-skills.sh
│   └── install-skill.sh
│
├── tests/
│   └── code-review/
│       └── basic-review.md
│
├── dist/
│   └── code-review.zip
│
├── README.md
└── CONTRIBUTING.md
```
