# Ridaa: How to Push Your Files on Your Branch

| | |
|---|---|
| **Your part** | Admin (approvals, users, disputes), booking agent, expert screens, Firestore security rules and indexes, seed tool |
| **Your branch** | `ridaa` |
| **Your files** | 14 files, all inside the **`files/`** folder next to this guide |
| **Push into** | the **team repo**: <https://github.com/murinziben/ntiza_mobile_application> |

**Rules:** only ever push to **your** branch, `ridaa`. Never push to `main` or to anyone else's branch.
Your work reaches `main` through a Pull Request.

## What's in your folder

```
team/ridaa/
├── HOW_TO_PUSH.md     ← this guide
└── files/             ← your files, already in the right folders
```

Everything inside `files/` goes into the **root** of the team repo, keeping the same folders.
For example, `files/lib/...` becomes `lib/...`.

```
firebase.json
firestore.indexes.json
firestore.rules
lib/data/repositories/firestore_admin_repository.dart
lib/domain/usecases/agent_usecases.dart
lib/presentation/controllers/admin_controller.dart
lib/presentation/screens/admin/admin_screens.dart
lib/presentation/screens/agent/agent_screens.dart
lib/presentation/screens/expert/expert_screens.dart
test/presentation/controllers_test.dart
tools/README.md
tools/package-lock.json
tools/package.json
tools/seed.js
```

## When you push

**After murinziben posts "Foundation is on main"** in the group. You don't need to wait for anyone else.
Your files are different from everyone else's, so all four of you can push at the same time.

> The app only builds fully once all 5 branches are merged into `main`. If `flutter run` fails on your
> branch because of screens someone else is adding, that's expected.

## Step by step

### 1. One-time setup
- Accept **both** invites from murinziben (team repo + sample repo), from your email or
  <https://github.com/notifications>.
- Install Git from <https://git-scm.com/download/win> with the default options, then use **Git Bash**
  for every command below. (On a Mac, use Terminal.)
- Tell Git who you are. **Use the e-mail of your GitHub account**, or your commits will not count for you:
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"
  ```
- Sign in to GitHub:
  ```bash
  winget install --id GitHub.cli     # Mac: brew install gh
  gh auth login                      # GitHub.com → HTTPS → Login with a web browser
  ```

### 2. Download the sample repo (has your folder)
```bash
cd ~/Desktop
git clone https://github.com/murinziben/ntiza_mobile_app.git sample
```
Your files are now in `~/Desktop/sample/team/ridaa/files/`.

### 3. Download the team repo
```bash
cd ~/Desktop
git clone https://github.com/murinziben/ntiza_mobile_application.git team-repo
cd team-repo
```
*(Already cloned? Run `cd ~/Desktop/team-repo` instead.)*

### 4. Go to your branch, starting from the latest `main`
```bash
git checkout main
git pull origin main
git checkout -b ridaa
```
*(If your branch already exists, run `git checkout ridaa` and then `git merge main` instead.)*

### 5. Copy your files into the team repo
Make sure you're inside `team-repo`, then run:
```bash
cp -R ../sample/team/ridaa/files/. .
```
This copies everything from your `files/` folder into the team repo, keeping the folders.
*(Without the terminal: open `sample/team/ridaa/files/`, select everything, copy it, and paste it into
the `team-repo` folder. Turn on **View → Hidden items** first so you don't miss hidden files.)*

### 6. Read your code
Open your files in VS Code and read them. You will explain this part in the demo video and in the
presentation, so make sure you understand what each file does. Change or improve anything you want.

### 7. Commit, a few files at a time
Run each block, one after the other. After each `git add`, run `git status`: under
**"Changes to be committed"** you should see only the files of that block.
If anything else appears, **stop and ask in the group**.

```bash
git add firestore.rules firestore.indexes.json firebase.json
git commit -m "Add Firestore security rules and indexes"
```

```bash
git add lib/domain/usecases/agent_usecases.dart lib/data/repositories/firestore_admin_repository.dart lib/presentation/controllers/admin_controller.dart test/presentation/controllers_test.dart
git commit -m "Add admin and agent use cases, repository and controller with tests"
```

```bash
git add lib/presentation/screens/admin/ lib/presentation/screens/agent/ lib/presentation/screens/expert/
git commit -m "Add admin, booking agent and expert screens"
```

```bash
git add tools/
git commit -m "Add Firestore seed tool"
```

### 8. Push your branch
```bash
git push -u origin ridaa
```
*(After the first time, a plain `git push` is enough.)*

### 9. Open a Pull Request into `main`
- Open the team repo on GitHub and click the yellow **Compare & pull request** button for `ridaa`.
- Check that it says **base: `main`** ← **compare: `ridaa`**.
- Title: **Add admin, agent and expert features with security rules**
- In the description, write what you added and how to test it.
- Click **Create pull request**. Then tell the group that your PR is ready for review.

### 10. After it is merged
```bash
git checkout main
git pull origin main
git checkout ridaa
git merge main
```
Your branch is now up to date. For your next change (a fix, a test, an improvement), edit your files,
then `git add <the files you changed>`, `git commit -m "..."` and `git push`, and open a new PR.

## If something goes wrong

| Problem | Fix |
|---|---|
| `Repository not found` / `Permission denied` | Accept the invites on GitHub (team repo **and** sample repo), then run `gh auth login` again. |
| `git push` asks for a password | Use `gh auth login`. Your normal GitHub password won't work. |
| `cp: ../sample/...: No such file or directory` | You're not in the `team-repo` folder, or step 2 wasn't done. Run `cd ~/Desktop/team-repo` and try again. |
| `git status` shows files that aren't yours | **Don't commit.** Run `git restore --staged .` and ask in the group. |
| `rejected ... fetch first` | Run `git pull origin ridaa`, then push again. |
| PR says **"This branch has conflicts"** | See *Fixing conflicts* in `TEAM_GIT_GUIDE.md` in the sample repo, or ask murinziben. |
| Committed a wrong file | Don't use `--force`. Ask in the group. |
