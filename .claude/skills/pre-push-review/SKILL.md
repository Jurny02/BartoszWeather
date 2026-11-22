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
git log --oneline origin/main..HEAD
xcodebuild test -scheme BartoszWeather -destination 'platform=iOS Simulator,name=iPhone 17'
```

Stop and fix first if the working tree is dirty, the branch is not based on current `origin/main`, or tests fail.

## 2. Spawn the reviewer

Launch one `general-purpose` subagent with the prompt below. Do not pass it your own reasoning about the change; it should judge the diff on its own.

> You are reviewing branch `<branch>` of an iOS SwiftUI app before it is pushed. Read `CLAUDE.md` first: it defines the architecture, testing and git rules. Then inspect `git log --format='%h %s%n%b' origin/main..HEAD` and `git diff origin/main...HEAD`, opening full files where context is needed.
>
> Report only real problems, each with file:line, what is wrong, and a concrete fix. Check:
> 1. Correctness: bugs, edge cases, wrong error handling, concurrency or actor-isolation issues, force unwraps on external data. For project configuration: build settings, scheme, test target hosting.
> 2. Architecture: MVVM-C roles respected, folder dependency rules (Features → Core/Networking/Theming, Networking → Core, Theming → Core, no feature-to-feature imports), dependencies injected rather than created inline.
> 3. Tests: new behavior covered with Swift Testing, meaningful assertions, no network or timing flakiness, test folders mirror sources.
> 4. Conventions: English only, no explanatory or leftover comments, no debug prints, no dead code, naming.
> 5. History: every commit follows `type(scope): subject`, is one coherent change, and contains no fix-up of an earlier commit in the same branch.
> 6. UI (if the diff touches views): uses Theming tokens instead of literals, supports Dark Mode and Dynamic Type, has accessibility labels where needed.
>
> End with a verdict: `READY TO PUSH` or `CHANGES NEEDED`, followed by findings ordered by severity. Do not modify any files.

## 3. Act on the result

- Verify each finding against the code before acting; discard ones that are wrong and say why.
- Fix valid findings. While the branch is unpushed, fold each fix into the commit it belongs to with `git commit --fixup=<sha>` and `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash origin/main`. After the branch is pushed, add a focused commit instead of rewriting history.
- Re-run tests after fixes. Re-run the review if the fixes were substantial.
- Summarize the verdict and what changed for the user, then push.
