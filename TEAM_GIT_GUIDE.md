# Team Git Guide

**Team:** murinziben (team leader, team repo owner), ISHAMI Irené, Kabera Nshuti Samuel, Maellene, Ridaa

## How it works

There are **two repositories**:

| Repo | What it's for | Link |
|---|---|---|
| **Sample repo** | Holds the finished app and **your folder** in `team/<your-branch>/`. You only copy from it. Never push to it. | <https://github.com/murinziben/ntiza_mobile_app> |
| **Team repo** | Where everyone **pushes their work**, each on their own branch. | <https://github.com/murinziben/ntiza_mobile_application> |

Each person has **their own branch** in the team repo:

| Person | Branch | Part of the app | Your guide |
|---|---|---|---|
| murinziben (leader) | `murinziben` | Foundation: entities, repository interfaces, Firestore mappers, providers, router, theme, shared widgets | [team/murinziben/](team/murinziben/HOW_TO_PUSH.md) |
| ISHAMI Irené | `ishami` | Authentication, settings (SharedPreferences), edit profile, notifications | [team/ishami/](team/ishami/HOW_TO_PUSH.md) |
| Kabera Nshuti Samuel | `samuel` | Farmer: booking, pricing, payment, my bookings | [team/samuel/](team/samuel/HOW_TO_PUSH.md) |
| Maellene | `maellene` | Public screens, equipment owner, ERD | [team/maellene/](team/maellene/HOW_TO_PUSH.md) |
| Ridaa | `ridaa` | Admin, booking agent, expert, security rules, seed tool | [team/ridaa/](team/ridaa/HOW_TO_PUSH.md) |

**See who pushes every single file** in [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md).

**Open your own folder** in the sample repo, `team/<your-branch>/`. It contains:
- **`files/`**: the exact files and folders you push, already in the right layout;
- **`HOW_TO_PUSH.md`**: every command you need, step by step.

### The rules

1. **Push only to your own branch.** Nobody pushes to `main` or to someone else's branch.
2. Your work reaches `main` through a **Pull Request (PR)**: your branch → `main`.
   Another member reviews it (reads it, leaves a real comment, approves), then it is merged.
3. **murinziben goes first.** The others start after murinziben posts "Foundation is on main".
4. Then **Irené, Samuel, Maellene and Ridaa can all push at the same time.** Nobody's files overlap,
   so there are no conflicts.
5. **Understand your code.** Everyone presents their own part in the demo video, so read every file
   you push.
6. **Keep committing after the first push.** Fixes, tests and screenshots of your screens go on your
   branch too. The graders look at commits spread over the days, not one big push.

> The app only builds fully once all 5 branches are merged into `main`. Until then, `flutter run`
> may fail on your branch because of screens someone else is adding. That's expected.

---

## Part A: murinziben's one-time setup

murinziben's guide covers this in detail ([team/murinziben/](team/murinziben/HOW_TO_PUSH.md), step 1):

- Push the sample repo with the `team/` folder.
- Invite Irené, Samuel, Maellene and Ridaa to the **team repo** *and* the **sample repo**.
- Protect `main` in the team repo: **Settings → Branches →** tick **Require a pull request before merging**.

---

## Part B: Everyone's one-time setup

### 1. Accept the invites
Accept **both** invitations (team repo + sample repo) from your email or <https://github.com/notifications>.

### 2. Install Git
- **Windows:** install it from <https://git-scm.com/download/win> with the default options,
  then use **Git Bash** for every command in these guides.
- **macOS:** open Terminal and run `git --version`. If Git isn't installed, macOS offers to install it.

### 3. Tell Git who you are (use your GitHub email)
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```
If the email is not the one on your GitHub account, your commits **will not count for you**.

### 4. Sign in to GitHub from your computer
```bash
# Windows: winget install --id GitHub.cli
# macOS:   brew install gh
gh auth login        # choose: GitHub.com → HTTPS → Login with a web browser
```

Now open **`team/<your-branch>/HOW_TO_PUSH.md`** and follow it from step 2.

---

## Everyday workflow (after your first push)

```bash
git checkout main && git pull origin main     # 1. get the latest main
git checkout <your-branch>                    # 2. go to your branch
git merge main                                # 3. bring main's updates into your branch
# ... edit your files ...
git add <the files you changed>               # 4. stage only your files
git commit -m "Say what you changed"          # 5. commit
git push                                      # 6. push your branch
```
Then open a new Pull Request on GitHub, or your existing one updates automatically.

Before you open a PR, run:
```bash
dart format .
flutter analyze
flutter test
```

---

## Fixing conflicts

If GitHub says **"This branch has conflicts"**:
```bash
git checkout main && git pull origin main
git checkout <your-branch>
git merge main
```
Open each file Git lists, keep the correct code, and delete the `<<<<<<<`, `=======`, `>>>>>>>` lines. Then:
```bash
git add <those files>
git commit -m "Resolve merge conflicts"
git push
```
If you get stuck, ask in the group. **Never use `git push --force`.**

---

## Never commit these

They're already in `.gitignore`, so don't force-add them:
- `build/`, `.dart_tool/`, `coverage/`, `.idea/`
- Passwords, Firebase **service-account** JSON files (`tools/serviceAccountKey.json`), signing keystores

---

## Cheat sheet

| What | Command |
|---|---|
| Go to your branch | `git checkout <your-branch>` |
| Get latest `main` into your branch | `git checkout main && git pull && git checkout <your-branch> && git merge main` |
| See what changed | `git status` |
| Save changes | `git add <files> && git commit -m "message"` |
| Upload your branch | `git push` |
| Which branch am I on? | `git branch` (the one with `*`) |
