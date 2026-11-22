---
name: pre-push-review
description: Review the current branch with an independent code-review subagent before pushing. Use before every `git push` in this repository, or when asked to review the branch.
---

# Pre-push review

Run this before every push. The goal is a second pair of eyes that did not write the code.

## 1. Check the branch is ready

```sh
git fetch origin main
git status --short
git merge-base --is-ancestor origin/main HEAD
git log --oneline origin/main..HEAD
xcodebuild test -scheme BartoszWeather -destination 'platform=iOS Simulator,name=iPhone 17'
```

Stop and fix first if the working tree is dirty, the branch is not based on current `origin/main`, or tests fail.

## 2. Spawn the reviewer

Launch one `general-purpose` subagent with the prompt below. Do not pass it your own reasoning about the change; it should judge the diff on its own.

> You are reviewing branch `<branch>` of an iOS SwiftUI app before it is pushed. Read `CLAUDE.md` first: it defines the architecture, testing and git rules. Then inspect `git log --format='%h %s%n%b' origin/main..HEAD` and `git diff origin/main...HEAD`, opening full files where context is needed.
>
> Report only real problems, each with file:line, what is wrong, and a concrete fix. Check:
> 1. Correctness: bugs, edge cases, wrong error handling, concurrency or actor-isolation issues, force unwraps on external data. For project configuration: build settings, scheme, test target hosting. For doc comments: does each one state accurately what the code does?
> 2. Architecture: MVVM-C roles respected, folder dependency rules (Features → Core/Networking/Theming, Networking → Core, Theming → Core, no feature-to-feature imports), dependencies injected rather than created inline, and the SOLID rules in `CLAUDE.md` (for example, shared infrastructure that assumes a single use case such as GET-only requests).
> 3. Tests: new behavior covered with Swift Testing, meaningful assertions, no network or timing flakiness, test folders mirror sources.
> 4. Conventions: English only, every type (protocol, class, struct, enum, actor) has a doc comment, no explanatory or leftover comments inside function bodies, no debug prints, no dead code, naming.
> 5. History: every commit follows `type(scope): subject` and is one coherent change. Commits in `git log origin/<branch>..HEAD` are unpushed (all of them if the branch has no upstream yet): none of them may patch an earlier unpushed commit, because such fixes must be folded in. Commits already pushed are published history, so a later focused commit that addresses a review finding on them is expected, not a defect.
> 6. UI (if the diff touches views): uses Theming tokens instead of literals, supports Dark Mode and Dynamic Type, has accessibility labels where needed.
>
> End with a verdict: `READY TO PUSH` or `CHANGES NEEDED`, followed by findings ordered by severity. Do not modify any files and do not run git commands that change state.

## 3. Act on the result

- Verify each finding against the code before acting; discard ones that are wrong and say why.
- Fix valid findings based on where the faulty commit lives:
  - Unpushed commit: fold the fix in with `git commit --fixup=<sha>` and `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash @{u}` (use `origin/main` if the branch has no upstream yet). Rebasing onto `@{u}` never rewrites pushed commits.
  - Pushed commit: add a focused commit instead of rewriting history.
- Re-run tests after fixes. Re-run the review if the fixes were substantial.
- Summarize the verdict and what changed for the user.
- Push only when the user asked for it or it is the next step of a PR workflow they approved. A review-only request ends with the summary.
