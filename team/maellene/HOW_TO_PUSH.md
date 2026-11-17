# Maellene: How to Push Your Files on Your Branch

| | |
|---|---|
| **Your part** | Public screens (welcome, home, marketplace, equipment detail, experts, training), equipment owner screens with equipment CRUD, ERD |
| **Your branch** | `maellene` |
| **Your files** | 19 files, all inside the **`files/`** folder next to this guide |
| **Push into** | the **team repo**: <https://github.com/murinziben/ntiza_mobile_application> |

**Rules:** only ever push to **your** branch, `maellene`. Never push to `main` or to anyone else's branch.
Your work reaches `main` through a Pull Request.

## What's in your folder

```
team/maellene/
├── HOW_TO_PUSH.md     ← this guide
└── files/             ← your files, already in the right folders
```

Everything inside `files/` goes into the **root** of the team repo, keeping the same folders.
For example, `files/lib/...` becomes `lib/...`.

```
docs/ERD.md
docs/erd.mmd
docs/erd.png
lib/data/repositories/firestore_catalog_repository.dart
lib/data/sample_data.dart
lib/domain/usecases/catalog_usecases.dart
lib/presentation/controllers/catalog_controller.dart
lib/presentation/screens/common/role_widgets.dart
lib/presentation/screens/owner/owner_screens.dart
lib/presentation/screens/owner/provider_helpers.dart
lib/presentation/screens/public/equipment_detail_screen.dart
lib/presentation/screens/public/experts_screen.dart
lib/presentation/screens/public/home_screen.dart
lib/presentation/screens/public/marketplace_screen.dart
lib/presentation/screens/public/public_shell.dart
lib/presentation/screens/public/training_screen.dart
lib/presentation/screens/public/welcome_screen.dart
lib/presentation/screens/public/widgets.dart
test/data/mappers_test.dart
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
Your files are now in `~/Desktop/sample/team/maellene/files/`.

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
git checkout -b maellene
```
*(If your branch already exists, run `git checkout maellene` and then `git merge main` instead.)*

### 5. Copy your files into the team repo
Make sure you're inside `team-repo`, then run:
```bash
cp -R ../sample/team/maellene/files/. .
```
This copies everything from your `files/` folder into the team repo, keeping the folders.
*(Without the terminal: open `sample/team/maellene/files/`, select everything, copy it, and paste it into
the `team-repo` folder. Turn on **View → Hidden items** first so you don't miss hidden files.)*

### 6. Read your code
Open your files in VS Code and read them. You will explain this part in the demo video and in the
presentation, so make sure you understand what each file does. Change or improve anything you want.

### 7. Commit, a few files at a time
Run each block, one after the other. After each `git add`, run `git status`: under
**"Changes to be committed"** you should see only the files of that block.
If anything else appears, **stop and ask in the group**.

```bash
git add docs/ERD.md docs/erd.mmd docs/erd.png
git commit -m "Add ERD of the Firestore database"
```

```bash
git add lib/domain/usecases/catalog_usecases.dart lib/data/repositories/firestore_catalog_repository.dart lib/data/sample_data.dart
git commit -m "Add catalog use cases, Firestore catalog repository and sample data"
```

```bash
git add lib/presentation/controllers/catalog_controller.dart test/data/mappers_test.dart
git commit -m "Add catalog controller and Firestore mapper tests"
```

```bash
git add lib/presentation/screens/public/ lib/presentation/screens/common/role_widgets.dart
git commit -m "Add public screens: welcome, home, marketplace, experts, training"
```

```bash
git add lib/presentation/screens/owner/
git commit -m "Add equipment owner screens with equipment CRUD"
```

### 8. Push your branch
```bash
git push -u origin maellene
```
*(After the first time, a plain `git push` is enough.)*

### 9. Open a Pull Request into `main`
- Open the team repo on GitHub and click the yellow **Compare & pull request** button for `maellene`.
- Check that it says **base: `main`** ← **compare: `maellene`**.
- Title: **Add public catalog, equipment owner screens and ERD**
- In the description, write what you added and how to test it.
- Click **Create pull request**. Then tell the group that your PR is ready for review.

### 10. After it is merged
```bash
git checkout main
git pull origin main
git checkout maellene
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
| `rejected ... fetch first` | Run `git pull origin maellene`, then push again. |
| PR says **"This branch has conflicts"** | See *Fixing conflicts* in `TEAM_GIT_GUIDE.md` in the sample repo, or ask murinziben. |
| Committed a wrong file | Don't use `--force`. Ask in the group. |
