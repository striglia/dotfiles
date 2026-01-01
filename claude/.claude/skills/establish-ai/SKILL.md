---
name: establish-ai
description: Bootstrap Claude Code configuration for any project. Analyzes codebase and creates CLAUDE.md + settings for first-interaction effectiveness. Also audits/improves existing configs.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(ls:*), Bash(cat:*), Bash(head:*), Bash(find:*), AskUserQuestion, Task
---

# Establish AI - Claude Code Project Setup

Bootstrap Claude Code configuration for maximum first-interaction effectiveness. Creates CLAUDE.md (project context) and .claude/settings.local.json (permissions) by analyzing the codebase and asking minimal questions.

## When to Use

**Invoke immediately when:**
- Entering a new project without CLAUDE.md
- User says `/establish-ai`
- User asks to "set up Claude Code for this project"
- User wants to "improve Claude's understanding of this codebase"

**Also works as audit mode:**
- Run on projects with existing CLAUDE.md to enhance it
- Merges new insights without clobbering existing content

## Quick Usage

```bash
# In the target project directory
/establish-ai

# Audit/improve existing config
/establish-ai --audit
```

## Core Philosophy

### First-Interaction Effectiveness

The goal is simple: after running establish-ai, Claude should be able to make **meaningful code changes on the very first prompt** without needing orientation time.

This means the generated CLAUDE.md must answer:
1. **What is this?** - Purpose in one sentence
2. **Where do I look?** - Key files and entry points (not generic "src/")
3. **What's safe?** - Permissions for common operations
4. **How does it work?** - Architecture patterns and data flow
5. **What will trip me up?** - Gotchas, conventions, non-obvious things

### Minimal Questions, Maximum Detection

Auto-detect everything possible. Only ask what genuinely cannot be inferred:
- Project purpose (the "why" behind the code)
- Preferred conventions when multiple valid options exist

## Workflow

### Phase 1: Deep Analysis

**Analyze the codebase thoroughly before asking any questions.**

1. **Detect tech stack** by checking for:
   ```
   Python: requirements.txt, setup.py, pyproject.toml, *.py
   JavaScript/TypeScript: package.json, tsconfig.json, *.ts, *.js
   Rust: Cargo.toml
   Go: go.mod
   Generic: Makefile, Dockerfile, docker-compose.yml
   ```

2. **Map architecture** by examining:
   - Directory structure (what lives where)
   - Entry points (main.py, index.js, src/main.rs)
   - Key abstractions (classes, modules, patterns)
   - Data flow (how components connect)
   - External dependencies (APIs, databases, services)

3. **Identify conventions**:
   - Coding style (inferred from existing code)
   - Naming patterns
   - Error handling approaches
   - Testing patterns (if tests exist)

4. **Detect existing tooling**:
   - Linters (flake8, eslint, clippy)
   - Formatters (black, prettier, rustfmt)
   - Type checkers (mypy, tsc)
   - Test runners (pytest, jest, cargo test)
   - Build tools (make, npm scripts, cargo)

5. **Find gotchas**:
   - TODO/FIXME comments
   - README warnings
   - Non-obvious configuration
   - Known limitations

### Phase 2: Minimal Interview (1-2 questions max)

Ask ONLY what cannot be inferred:

```
[AskUserQuestion]
Question 1: "In one sentence, what does this project do?"
- Auto-detection found: {tech stack, patterns}
- But purpose/intent requires human input

Question 2 (if needed): "Any critical conventions or gotchas I should know?"
- Only ask if codebase is unusual or conventions aren't obvious
```

**Skip questions entirely if:**
- README clearly explains purpose
- Project is small/obvious
- Running in audit mode on well-documented project

### Phase 3: Generate CLAUDE.md

Create or merge content following this structure:

```markdown
# {Project Name}

{One-sentence purpose from user or README}

## Quick Reference

| Task | Command |
|------|---------|
| Run | `{detected run command}` |
| Test | `{detected test command}` |
| Lint | `{detected lint command}` |
| Build | `{detected build command}` |

## Architecture

{Brief description of how the project is organized}

### Key Files
- `{entry_point}` - {description}
- `{core_module}` - {description}
- `{config_file}` - {description}

### Key Patterns
- {Pattern 1}: {How it's used in this codebase}
- {Pattern 2}: {How it's used in this codebase}

## Conventions

- {Convention 1}
- {Convention 2}
- {Convention 3}

## Gotchas

- {Non-obvious thing 1}
- {Non-obvious thing 2}

## Dependencies

{Key external services, APIs, or systems this project interacts with}
```

**Quality Guidelines:**
- Be specific, not generic ("UserService handles auth" not "services/ has services")
- Include actual file paths
- Describe patterns in terms of THIS codebase
- Gotchas should save future-Claude real debugging time

### Phase 4: Generate settings.local.json

Create or merge permissions based on detected tooling:

**Python projects:**
```json
{
  "permissions": {
    "allow": [
      "Bash(python:*)",
      "Bash(pip:*)",
      "Bash(pytest:*)",
      "Bash(mypy:*)",
      "Bash(black:*)",
      "Bash(flake8:*)"
    ]
  }
}
```

**JavaScript/TypeScript projects:**
```json
{
  "permissions": {
    "allow": [
      "Bash(npm:*)",
      "Bash(npx:*)",
      "Bash(node:*)",
      "Bash(jest:*)",
      "Bash(eslint:*)",
      "Bash(prettier:*)",
      "Bash(tsc:*)"
    ]
  }
}
```

**Universal (always include):**
```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(gh:*)"
    ]
  }
}
```

**Only include permissions for tools that actually exist in the project.**

### Phase 5: Merge with Existing (if applicable)

If CLAUDE.md or settings.local.json already exist:

1. **Read existing content**
2. **Identify gaps** - what's missing that we detected?
3. **Preserve user content** - never delete existing sections
4. **Add new sections** - append detected information
5. **Deduplicate** - remove redundant entries
6. **Show diff** - tell user what was added/changed

## Tech Stack Detection (Python-First)

### Python Projects

**Entry points to check:**
- `main.py`, `app.py`, `run.py`
- `src/main.py`, `src/{project_name}/__init__.py`
- `setup.py:entry_points`, `pyproject.toml:[project.scripts]`

**Patterns to detect:**
- Pydantic models (data validation)
- SQLAlchemy/Django ORM (database)
- FastAPI/Flask/Django (web framework)
- Click/Typer (CLI)
- pytest fixtures (testing patterns)
- httpx/requests (HTTP clients)
- boto3 (AWS integration)

**Commands to detect:**
| Check for | Command |
|-----------|---------|
| pytest in requirements | `pytest` |
| unittest usage | `python -m unittest` |
| mypy in requirements | `mypy .` |
| black in requirements | `black .` |
| flake8 in requirements | `flake8` |
| Makefile with targets | `make {target}` |

### Future: Other Tech Stacks

The patterns above can be adapted for JavaScript, Rust, Go, etc. The core approach remains:
1. Detect from manifest files
2. Map entry points
3. Identify framework patterns
4. Generate appropriate permissions

## Audit Mode

When running on a project with existing CLAUDE.md:

1. **Analyze current coverage** - what's documented vs. what exists
2. **Detect new patterns** - things added since last run
3. **Identify stale content** - documented things that no longer exist
4. **Propose enhancements** - specific additions to improve effectiveness

**Output format:**
```
Audit Results:
- Current coverage: X% of key files documented
- Missing sections: [list]
- Stale entries: [list]
- Suggested additions: [list]

Would you like me to update CLAUDE.md with these enhancements?
```

## Success Criteria

establish-ai succeeded if:

1. **First-interaction test** - Could a fresh Claude session make meaningful changes on first prompt?
2. **No orientation needed** - Key files and patterns are clear without exploration
3. **Permissions work** - Common commands run without approval dialogs
4. **Gotchas prevent wasted time** - Non-obvious things are documented

## Example Session

```
User: /establish-ai

[Claude analyzes codebase...]

Claude: I've analyzed this Python project. Here's what I found:

Tech Stack:
- Python 3.10+ with httpx, boto3, pydantic
- AWS integration (S3, SQS, Cognito)
- No test framework detected

Architecture:
- Entry point: main.py
- Core logic: auraframes/aura.py (orchestrator)
- API modules: auraframes/api/*.py
- Data models: auraframes/models/*.py
- AWS clients: auraframes/aws/*.py

Before I generate the config, one question:

[AskUserQuestion: "In one sentence, what does this project do?"]

User: "Unofficial Python client for Aura Frames digital photo frame API"

Claude: Got it. Creating configuration...

✓ Created CLAUDE.md with:
  - Project overview
  - Quick reference commands
  - Architecture map (6 key files)
  - Conventions (Pydantic models, httpx patterns)
  - Gotchas (AWS credentials, no tests yet)

✓ Created .claude/settings.local.json with:
  - Python tooling permissions (python, pip)
  - Git permissions

You're all set. Claude Code will now be effective from the first interaction.
```

## Tips for Claude

1. **Analyze before asking** - don't ask questions you could answer by reading code
2. **Be specific** - "handles auth" is useless; "validates JWT and manages session" is useful
3. **Include paths** - always reference actual files, not abstract descriptions
4. **Think about future-Claude** - what would confuse you starting fresh?
5. **Respect existing work** - merge, don't overwrite
6. **Keep permissions minimal** - only what's actually used in this project
7. **Test your output mentally** - could you implement a feature with just this CLAUDE.md?

## Error Handling

| Scenario | Action |
|----------|--------|
| No manifest files found | Ask user about tech stack |
| Conflicting patterns | Ask user which is primary |
| Write permission denied | Suggest manual creation with content |
| Git-ignored config files | Warn user, suggest adding to .gitignore exceptions |
