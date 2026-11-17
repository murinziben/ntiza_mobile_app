# ISHAMI Irené: How to Push Your Files on Your Branch

| | |
|---|---|
| **Your part** | Authentication (e-mail/password + Google, verify e-mail, reset password), settings saved with SharedPreferences, edit profile, notifications |
| **Your branch** | `ishami` |
| **Your files** | 20 files, all inside the **`files/`** folder next to this guide |
| **Push into** | the **team repo**: <https://github.com/murinziben/ntiza_mobile_application> |

**Rules:** only ever push to **your** branch, `ishami`. Never push to `main` or to anyone else's branch.
Your work reaches `main` through a Pull Request.

## What's in your folder

```
team/ishami/
├── HOW_TO_PUSH.md     ← this guide
└── files/             ← your files, already in the right folders
```

Everything inside `files/` goes into the **root** of the team repo, keeping the same folders.
For example, `files/lib/...` becomes `lib/...`.

```
lib/data/repositories/firebase_auth_repository.dart
lib/data/repositories/firestore_notification_repository.dart
lib/data/repositories/prefs_settings_repository.dart
lib/domain/usecases/auth_usecases.dart
lib/domain/validators.dart
lib/presentation/controllers/auth_controller.dart
lib/presentation/controllers/settings_controller.dart
lib/presentation/screens/auth/account_status_screen.dart
lib/presentation/screens/auth/complete_profile_screen.dart
lib/presentation/screens/auth/forgot_password_screen.dart
lib/presentation/screens/auth/guest_account_screen.dart
lib/presentation/screens/auth/login_screen.dart
lib/presentation/screens/auth/register_screen.dart
lib/presentation/screens/auth/verify_email_screen.dart
lib/presentation/screens/common/edit_profile_screen.dart
lib/presentation/screens/common/notifications_screen.dart
lib/presentation/screens/common/settings_screen.dart
test/data/settings_repository_test.dart
test/domain/validators_test.dart
test/presentation/widgets_test.dart
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
Your files are now in `~/Desktop/sample/team/ishami/files/`.

### 3. Download the team repo
```bash
cd ~/Desktop
git clone https://github.com/murinziben/ntiza_mobile_application.git team-repo
cd team-repo
```
*(Already cloned? Run `cd ~/Desktop/team-repo` instead.)*

### 4. Go to your branch, starting from the latest `main`
Your branch `ishami` already exists on GitHub, so you don't create it, you just switch to it:
```bash
git checkout main
git pull origin main
git checkout ishami
git merge main
```

### 5. Copy your files into the team repo
Make sure you're inside `team-repo`, then run:
```bash
cp -R ../sample/team/ishami/files/. .
```
This copies everything from your `files/` folder into the team repo, keeping the folders.
*(Without the terminal: open `sample/team/ishami/files/`, select everything, copy it, and paste it into
the `team-repo` folder. Turn on **View → Hidden items** first so you don't miss hidden files.)*

### 6. Read your code
Open your files in VS Code and read them. You will explain this part in the demo video and in the
presentation, so make sure you understand what each file does. Change or improve anything you want.

### 7. Commit, a few files at a time
Run each block, one after the other. After each `git add`, run `git status`: under
**"Changes to be committed"** you should see only the files of that block.
If anything else appears, **stop and ask in the group**.

```bash
git add lib/domain/validators.dart lib/domain/usecases/auth_usecases.dart test/domain/validators_test.dart
git commit -m "Add input validators and auth use cases with tests"
```

```bash
git add lib/data/repositories/firebase_auth_repository.dart lib/data/repositories/prefs_settings_repository.dart lib/data/repositories/firestore_notification_repository.dart test/data/settings_repository_test.dart
git commit -m "Add Firebase auth, settings and notification repositories"
```

```bash
git add lib/presentation/controllers/auth_controller.dart lib/presentation/controllers/settings_controller.dart
git commit -m "Add auth and settings controllers"
```

```bash
git add lib/presentation/screens/auth/
git commit -m "Add login, register, verify e-mail and password reset screens"
```

```bash
git add lib/presentation/screens/common/settings_screen.dart lib/presentation/screens/common/edit_profile_screen.dart lib/presentation/screens/common/notifications_screen.dart test/presentation/widgets_test.dart
git commit -m "Add settings, edit profile and notification screens with widget tests"
```

### 8. Push your branch
```bash
git push -u origin ishami
```
*(After the first time, a plain `git push` is enough.)*

### 9. Open a Pull Request into `main`
- Open the team repo on GitHub and click the yellow **Compare & pull request** button for `ishami`.
- Check that it says **base: `main`** ← **compare: `ishami`**.
- Title: **Add authentication, settings and notifications**
- In the description, write what you added and how to test it.
- Click **Create pull request**. Then tell the group that your PR is ready for review.

### 10. After it is merged
```bash
git checkout main
git pull origin main
git checkout ishami
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
| `rejected ... fetch first` | Run `git pull origin ishami`, then push again. |
| PR says **"This branch has conflicts"** | See *Fixing conflicts* in `TEAM_GIT_GUIDE.md` in the sample repo, or ask murinziben. |
| Committed a wrong file | Don't use `--force`. Ask in the group. |
