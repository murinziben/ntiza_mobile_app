# Kabera Nshuti Samuel: How to Push Your Files on Your Branch

| | |
|---|---|
| **Your part** | Farmer side: dashboard, book equipment or an expert (calendar, price summary), Mobile Money payment, my bookings, booking detail |
| **Your branch** | `samuel` |
| **Your files** | 16 files, all inside the **`files/`** folder next to this guide |
| **Push into** | the **team repo**: <https://github.com/murinziben/ntiza_mobile_application> |

**Rules:** only ever push to **your** branch, `samuel`. Never push to `main` or to anyone else's branch.
Your work reaches `main` through a Pull Request.

## What's in your folder

```
team/samuel/
├── HOW_TO_PUSH.md     ← this guide
└── files/             ← your files, already in the right folders
```

Everything inside `files/` goes into the **root** of the team repo, keeping the same folders.
For example, `files/lib/...` becomes `lib/...`.

```
lib/data/repositories/firestore_booking_repository.dart
lib/domain/usecases/booking_usecases.dart
lib/domain/usecases/pricing.dart
lib/presentation/controllers/booking_controller.dart
lib/presentation/screens/farmer/book_equipment_screen.dart
lib/presentation/screens/farmer/book_expert_screen.dart
lib/presentation/screens/farmer/booking_detail_screen.dart
lib/presentation/screens/farmer/booking_row.dart
lib/presentation/screens/farmer/calendar_card.dart
lib/presentation/screens/farmer/farmer_dashboard.dart
lib/presentation/screens/farmer/farmer_profile_screen.dart
lib/presentation/screens/farmer/farmer_shell.dart
lib/presentation/screens/farmer/my_bookings_screen.dart
lib/presentation/screens/farmer/payment_screen.dart
test/domain/pricing_test.dart
test/domain/usecases_test.dart
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
Your files are now in `~/Desktop/sample/team/samuel/files/`.

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
git checkout -b samuel
```
*(If your branch already exists, run `git checkout samuel` and then `git merge main` instead.)*

### 5. Copy your files into the team repo
Make sure you're inside `team-repo`, then run:
```bash
cp -R ../sample/team/samuel/files/. .
```
This copies everything from your `files/` folder into the team repo, keeping the folders.
*(Without the terminal: open `sample/team/samuel/files/`, select everything, copy it, and paste it into
the `team-repo` folder. Turn on **View → Hidden items** first so you don't miss hidden files.)*

### 6. Read your code
Open your files in VS Code and read them. You will explain this part in the demo video and in the
presentation, so make sure you understand what each file does. Change or improve anything you want.

### 7. Commit, a few files at a time
Run each block, one after the other. After each `git add`, run `git status`: under
**"Changes to be committed"** you should see only the files of that block.
If anything else appears, **stop and ask in the group**.

```bash
git add lib/domain/usecases/pricing.dart lib/domain/usecases/booking_usecases.dart test/domain/pricing_test.dart test/domain/usecases_test.dart
git commit -m "Add booking pricing and booking use cases with tests"
```

```bash
git add lib/data/repositories/firestore_booking_repository.dart lib/presentation/controllers/booking_controller.dart
git commit -m "Add Firestore booking repository and booking controller"
```

```bash
git add lib/presentation/screens/farmer/
git commit -m "Add farmer dashboard, booking, payment and booking detail screens"
```

### 8. Push your branch
```bash
git push -u origin samuel
```
*(After the first time, a plain `git push` is enough.)*

### 9. Open a Pull Request into `main`
- Open the team repo on GitHub and click the yellow **Compare & pull request** button for `samuel`.
- Check that it says **base: `main`** ← **compare: `samuel`**.
- Title: **Add farmer booking and payment**
- In the description, write what you added and how to test it.
- Click **Create pull request**. Then tell the group that your PR is ready for review.

### 10. After it is merged
```bash
git checkout main
git pull origin main
git checkout samuel
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
| `rejected ... fetch first` | Run `git pull origin samuel`, then push again. |
| PR says **"This branch has conflicts"** | See *Fixing conflicts* in `TEAM_GIT_GUIDE.md` in the sample repo, or ask murinziben. |
| Committed a wrong file | Don't use `--force`. Ask in the group. |
