# murinziben (leader): How to Push Your Files on Your Branch

| | |
|---|---|
| **Your part** | Foundation: entities, repository interfaces, Firestore mappers, Riverpod providers, router, theme, shared widgets, app entry point, Figma designs, README |
| **Your branch** | `murinziben` |
| **Your files** | 76 files, all inside the **`files/`** folder next to this guide |
| **Push into** | the **team repo**: <https://github.com/murinziben/ntiza_mobile_application> |

**Rules:** only ever push to **your** branch, `murinziben`. Never push to `main` or to anyone else's branch.
Your work reaches `main` through a Pull Request.

## What's in your folder

```
team/murinziben/
├── HOW_TO_PUSH.md     ← this guide
└── files/             ← your files, already in the right folders
```

Everything inside `files/` goes into the **root** of the team repo, keeping the same folders.
For example, `files/lib/...` becomes `lib/...`.

```
README.md
design/mobile/admin/AD1 Admin Overview.png
design/mobile/admin/AD2 Partner Applications.png
design/mobile/admin/AD3 Users.png
design/mobile/admin/AD4 Disputes.png
design/mobile/admin/AD5 More & Reports.png
design/mobile/booking agent/A1 Agent Dashboard.png
design/mobile/booking agent/A2 My Farmers.png
design/mobile/booking agent/A3 Book for Farmer.png
design/mobile/booking agent/A4 Commissions.png
design/mobile/equipment owner/O1 Owner Dashboard.png
design/mobile/equipment owner/O2 My Equipment.png
design/mobile/equipment owner/O3 Add Equipment.png
design/mobile/equipment owner/O4 Booking Requests.png
design/mobile/equipment owner/O5 Earnings.png
design/mobile/expert/E1 Expert Dashboard.png
design/mobile/expert/E2 Consultations.png
design/mobile/expert/E3 Availability.png
design/mobile/expert/E4 Earnings.png
design/mobile/farmer/F1 Farmer Dashboard.png
design/mobile/farmer/F2 Book Equipment.png
design/mobile/farmer/F3 Mobile Money Payment.png
design/mobile/farmer/F4 My Bookings.png
design/mobile/farmer/F5 Booking Detail.png
design/mobile/farmer/F6 Notifications.png
design/mobile/farmer/NTIZA Mobile App.png
design/mobile/fundaction and asset.png
design/mobile/public/01 Welcome.png
design/mobile/public/02 Home.png
design/mobile/public/03 Equipment Marketplace.png
design/mobile/public/04 Equipment Detail.png
design/mobile/public/05 Agricultural Experts.png
design/mobile/public/06 Training & Education.png
design/mobile/public/07 Login.png
design/mobile/public/08 Create Account.png
docs/architecture.mmd
docs/architecture.png
docs/dataflow.mmd
docs/dataflow.png
docs/screenshots/.gitkeep
lib/app.dart
lib/core/errors/app_exception.dart
lib/core/router/app_router.dart
lib/core/theme/app_colors.dart
lib/core/theme/app_theme.dart
lib/core/utils/formatters.dart
lib/data/mappers/firestore_mappers.dart
lib/data/repositories/firebase_errors.dart
lib/domain/constants.dart
lib/domain/entities/agent_client.dart
lib/domain/entities/app_notification.dart
lib/domain/entities/app_settings.dart
lib/domain/entities/app_user.dart
lib/domain/entities/booking.dart
lib/domain/entities/course.dart
lib/domain/entities/dispute.dart
lib/domain/entities/entities.dart
lib/domain/entities/equipment.dart
lib/domain/entities/expert.dart
lib/domain/entities/role.dart
lib/domain/repositories/admin_repository.dart
lib/domain/repositories/auth_repository.dart
lib/domain/repositories/booking_repository.dart
lib/domain/repositories/catalog_repository.dart
lib/domain/repositories/notification_repository.dart
lib/domain/repositories/settings_repository.dart
lib/firebase_options.dart
lib/main.dart
lib/presentation/controllers/action_notifier.dart
lib/presentation/providers/data_providers.dart
lib/presentation/providers/dependencies.dart
lib/presentation/providers/providers.dart
lib/presentation/widgets/ui.dart
test/core/formatters_test.dart
test/core/router_redirect_test.dart
test/helpers/fakes.dart
```

## When you push

**You go first.** The other four wait until your branch is merged into `main`.

1. Push your branch and open the PR (steps below).
2. Ask **Irené** to review it on GitHub (they read it, leave a comment and approve).
3. Merge it, then post **"Foundation is on main"** in the group.

> The app only builds fully once all 5 branches are merged into `main`, because your router and
> providers point to screens and controllers the others are adding. That's expected.

## Step by step

### 1. One-time setup (leader)
- **Push the sample repo** (`ntiza_mobile_app`) with the `team/` folder and these guides, so everyone can download it.
- Invite Irené, Samuel, Maellene and Ridaa to the **sample repo** too (Settings → Collaborators).
- Protect `main` in the **team repo**: **Settings → Branches → Add rule** for `main` → tick **Require a pull request before merging**.

### 1b. Your own Git setup
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
Your files are now in `~/Desktop/sample/team/murinziben/files/`.

### 3. Download the team repo
```bash
cd ~/Desktop
git clone https://github.com/murinziben/ntiza_mobile_application.git team-repo
cd team-repo
```
*(Already cloned? Run `cd ~/Desktop/team-repo` instead.)*

### 4. Go to your branch, starting from the latest `main`
You already have Git set up and both repos on your Desktop: the sample repo is `ntiza_mobile_app` and the team repo
is `ntiza_mobile_application`. So skip steps 2 and 3, and run this in the team repo:
```bash
cd ~/Desktop/ntiza_mobile_application
git checkout main
git pull origin main
git checkout -b murinziben
```

### 5. Copy your files into the team repo
Make sure you're inside `ntiza_mobile_application`, then run:
```bash
cp -R ../ntiza_mobile_app/team/murinziben/files/. .
```
This copies everything from your `files/` folder into the team repo, keeping the folders.
*(Without the terminal: open `ntiza_mobile_app/team/murinziben/files/`, select everything, copy it, and paste it into
the `ntiza_mobile_application` folder. Turn on **View → Hidden items** first so you don't miss hidden files.)*

### 6. Read your code
Open your files in VS Code and read them. You will explain this part in the demo video and in the
presentation, so make sure you understand what each file does. Change or improve anything you want.

### 7. Commit, a few files at a time
Run each block, one after the other. After each `git add`, run `git status`: under
**"Changes to be committed"** you should see only the files of that block.
If anything else appears, **stop and ask in the group**.

```bash
git add lib/core/ lib/firebase_options.dart
git commit -m "Add core theme, router, formatters and error types"
```

```bash
git add lib/domain/entities/ lib/domain/repositories/ lib/domain/constants.dart
git commit -m "Add domain entities and repository interfaces"
```

```bash
git add lib/data/mappers/ lib/data/repositories/firebase_errors.dart
git commit -m "Add Firestore mappers and Firebase error handling"
```

```bash
git add lib/presentation/providers/ lib/presentation/controllers/action_notifier.dart lib/presentation/widgets/ lib/main.dart lib/app.dart
git commit -m "Add Riverpod providers, shared widgets and app entry point"
```

```bash
git add test/helpers/ test/core/
git commit -m "Add test fakes and core tests"
```

```bash
git add design/ docs/
git commit -m "Add Figma designs and architecture diagrams"
```

```bash
git add README.md
git commit -m "Update README with features, setup and architecture"
```

### 8. Push your branch
```bash
git push -u origin murinziben
```
*(After the first time, a plain `git push` is enough.)*

### 9. Open a Pull Request into `main`
- Open the team repo on GitHub and click the yellow **Compare & pull request** button for `murinziben`.
- Check that it says **base: `main`** ← **compare: `murinziben`**.
- Title: **Add app foundation: domain, data mappers, providers, router and theme**
- In the description, write what you added and how to test it.
- Click **Create pull request**. Then tell the group that your PR is ready for review.

### 10. After it is merged
```bash
git checkout main
git pull origin main
git checkout murinziben
git merge main
```
Your branch is now up to date. For your next change (a fix, a test, an improvement), edit your files,
then `git add <the files you changed>`, `git commit -m "..."` and `git push`, and open a new PR.

## If something goes wrong

| Problem | Fix |
|---|---|
| `Repository not found` / `Permission denied` | Accept the invites on GitHub (team repo **and** sample repo), then run `gh auth login` again. |
| `git push` asks for a password | Use `gh auth login`. Your normal GitHub password won't work. |
| `cp: No such file or directory` | You are not in the `ntiza_mobile_application` folder. Run `cd ~/Desktop/ntiza_mobile_application` and try again. |
| `git status` shows files that aren't yours | **Don't commit.** Run `git restore --staged .` and ask in the group. |
| `rejected ... fetch first` | Run `git pull origin murinziben`, then push again. |
| PR says **"This branch has conflicts"** | See *Fixing conflicts* in `TEAM_GIT_GUIDE.md`. |
| Committed a wrong file | Don't use `--force`. Ask in the group. |
