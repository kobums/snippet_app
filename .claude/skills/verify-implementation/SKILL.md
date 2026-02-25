---
name: verify-implementation
description: Sequentially runs all verify skills in the project to generate an integrated verification report. Use after feature implementation, before PRs, or during code review.
disable-model-invocation: true
argument-hint: "[optional: specific verify skill name]"
---

# Implementation Verification

## Purpose

Performs integrated verification by sequentially running all registered `verify-*` skills in the project:

- Executes checks defined in each skill's Workflow
- References each skill's Exceptions to prevent false positives
- Suggests fixes for discovered issues
- Applies fixes and re-verifies after user approval

## When to Run

- After implementing a new feature
- Before creating a Pull Request
- During code review
- When auditing codebase rule compliance

## Target Skills

List of verification skills that this skill runs sequentially. `/manage-skills` automatically updates this list when creating/deleting skills.

(No verification skills registered yet)

<!-- When skills are added, register in the following format:
| # | Skill | Description |
|---|-------|-------------|
| 1 | `verify-example` | Example verification description |
-->

## Workflow

### Step 1: Introduction

Check the skills listed in the **Target Skills** section above.

If an optional argument is provided, filter to only that skill.

**If there are 0 registered skills:**

```markdown
## Implementation Verification

No verification skills found. Run `/manage-skills` to create verification skills for your project.
```

In this case, terminate the workflow.

**If there is 1 or more registered skills:**

Display the contents of the Target Skills table:

```markdown
## Implementation Verification

Running the following verification skills sequentially:

| # | Skill | Description |
|---|-------|-------------|
| 1 | verify-<name1> | <description1> |
| 2 | verify-<name2> | <description2> |

Starting verification...
```

### Step 2: Sequential Execution

For each skill listed in the **Target Skills** table, perform the following:

#### 2a. Read Skill SKILL.md

Read the skill's `.claude/skills/verify-<name>/SKILL.md` and parse the following sections:

- **Workflow** — Check steps and detection commands to execute
- **Exceptions** — Patterns considered not to be violations
- **Related Files** — List of files to check

#### 2b. Run Checks

Execute each check defined in the Workflow section in order:

1. Use the tool specified in the check (Grep, Glob, Read, Bash) to detect patterns
2. Compare detected results against the skill's PASS/FAIL criteria
3. Exempt patterns that match the Exceptions section
4. If FAIL, record the issue:
   - File path and line number
   - Problem description
   - Recommended fix (with code example)

#### 2c. Record Per-Skill Results

Display progress after each skill completes:

```markdown
### verify-<name> Verification Complete

- Check items: N
- Passed: X
- Issues: Y
- Exempted: Z

[Moving to next skill...]
```

### Step 3: Integrated Report

After all skills have completed, consolidate results into a single report:

```markdown
## Implementation Verification Report

### Summary

| Verification Skill | Status | Issue Count | Details |
|--------------------|--------|-------------|---------|
| verify-<name1> | PASS / X issues | N | Details... |
| verify-<name2> | PASS / X issues | N | Details... |

**Total issues found: X**
```

**When all verifications pass:**

```markdown
All verifications passed!

The implementation complies with all project rules:

- verify-<name1>: <pass summary>
- verify-<name2>: <pass summary>

Ready for code review.
```

**When issues are found:**

List each issue with file path, problem description, and recommended fix:

```markdown
### Issues Found

| # | Skill | File | Problem | How to Fix |
|---|-------|------|---------|------------|
| 1 | verify-<name1> | `path/to/file.ts:42` | Problem description | Fix code example |
| 2 | verify-<name2> | `path/to/file.tsx:15` | Problem description | Fix code example |
```

### Step 4: User Action Confirmation

If issues are found, use `AskUserQuestion` to confirm with the user:

```markdown
---

### Fix Options

**X issues were found. How would you like to proceed?**

1. **Fix all** - Automatically apply all recommended fixes
2. **Fix individually** - Review and apply each fix one by one
3. **Skip** - Exit without changes
```

### Step 5: Apply Fixes

Apply fixes based on user selection.

**When "Fix all" is selected:**

Apply all fixes in order and display progress:

```markdown
## Applying fixes...

- [1/X] verify-<name1>: `path/to/file.ts` fix complete
- [2/X] verify-<name2>: `path/to/file.tsx` fix complete

X fixes complete.
```

**When "Fix individually" is selected:**

Show the fix content for each issue and use `AskUserQuestion` to confirm approval.

### Step 6: Post-Fix Re-verification

If fixes were applied, re-run only the skills that had issues to compare Before/After:

```markdown
## Post-Fix Re-verification

Re-running skills that had issues...

| Verification Skill | Before Fix | After Fix |
|--------------------|------------|-----------|
| verify-<name1> | X issues | PASS |
| verify-<name2> | Y issues | PASS |

All verifications passed!
```

**If issues still remain:**

```markdown
### Remaining Issues

| # | Skill | File | Problem |
|---|-------|------|---------|
| 1 | verify-<name> | `path/to/file.ts:42` | Cannot auto-fix — manual review required |

Resolve manually, then run `/verify-implementation` again.
```

---

## Exceptions

The following are **not issues**:

1. **Projects with no registered skills** — Display an informational message and exit, not an error
2. **Skill-specific exceptions** — Patterns defined in each verify skill's Exceptions section are not reported as issues
3. **verify-implementation itself** — Does not include itself in the target skills list
4. **manage-skills** — Not included in target skills since it does not start with `verify-`

## Related Files

| File | Purpose |
|------|---------|
| `.claude/skills/manage-skills/SKILL.md` | Skill maintenance (manages this file's target skills list) |
| `CLAUDE.md` | Project guidelines |