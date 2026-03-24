---
name: branch-policy
description: Check that all commits from release branches have been forward-ported, and open PRs for missing ones
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *)
---

# Branch Policy Check

Run the branch policy check, summarize the results, and open cherry-pick PRs for any missing commits.

## Policy

Commits must flow forward through the release branches:

1. **2.2.x → 2.3 and main:** All non-trivial commits from `2.2.x` branches (>= 2.2.13, including future 2.2.14, 2.2.15, etc.) must land in both `2.3` and `main` (currently version 2.4).
2. **2.3 → main:** All non-trivial commits on `2.3` must also land in `main`.

Ignore these commits:
- Version bumps (`chore: bump build number`, `Bump version`, `Fix version`)
- Merge commits

## Steps

### 1. Discover missing commits

1. Run `git fetch --all --quiet` to get latest state.

2. **Check 2.2.x → 2.3 and main.** For each `origin/2.2.N` branch where N >= 13, run:
   ```
   git cherry origin/main origin/2.2.N
   git cherry origin/2.3 origin/2.2.N
   ```
   Lines starting with `+` are commits NOT present in the target branch.

3. **Check 2.3 → main.** Run:
   ```
   git cherry origin/main origin/2.3
   ```
   Lines starting with `+` are commits on `2.3` NOT present in `main`.

4. For each missing commit (marked with `+`), check if it's a merge commit (skip those) or matches an ignore pattern (skip those too). For the remaining ones, get the subject with `git log --format='%s' -1 <sha>` and the diffstat with `git show --stat --format="" <sha>`.

5. Present a clear natural language summary:
   - Which branches were checked and against which targets
   - How many real commits are missing from each target
   - For each missing commit: its short SHA, subject line, and which files it touches (from diffstat)
   - If everything is clean, say so

### 2. Create cherry-pick PRs

If there are missing commits, create a PR for **each (source, target) pair** that has missing commits. The pairs to check are:
- `2.2.N` → `2.3`
- `2.2.N` → `main`
- `2.3` → `main`

For each pair with missing commits:

1. **Create a branch** from the target:
   ```
   git checkout -b cherry-pick/<source>-to-<target> origin/<target>
   ```
   Use the highest 2.2.N branch number if multiple 2.2.x branches exist. If the branch already exists remotely, append a date suffix (e.g., `cherry-pick/2.2.13-to-main-20260324`).

2. **Cherry-pick** each missing commit (in the order they appear on the source branch):
   ```
   git cherry-pick <sha>
   ```
   - If a cherry-pick **conflicts**, abort (`git cherry-pick --abort`), skip that commit, and note it in the PR body as needing manual resolution.
   - Continue with the remaining commits.

3. **Push** the branch:
   ```
   git push -u origin <branch-name>
   ```

4. **Create a PR** using `gh pr create`:
   - **Title:** `cherry-pick: <source> commits into <target>`
   - **Base:** the target branch
   - **Body:** use a HEREDOC and include:
     - A list of all cherry-picked commits (short SHA + subject)
     - A list of any skipped commits (conflicts) with instructions to resolve manually
     - The source branch

5. **Return to the original branch** after creating all PRs:
   ```
   git checkout -
   ```

6. Print the PR URL(s) at the end.
