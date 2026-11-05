# Rubric checklist — what to show and what you still have to do

Tick every box before submitting. "Evidence" is where a grader (or you, in the video) can see the item.

## Front-end & back-end implementation (100 pts)

| Criterion (pts) | Evidence in the project | You must still do |
|---|---|---|
| **Widgets & UI (5)** — variety of widgets, 5.5" and 6.7" screens, contrast 4.5:1, tap size | ListView, Cards, Dialogs, BottomSheets, Dismissible, Chips, Switch, calendar grid, DropdownButtonFormField, StatefulShellRoute tabs. Colours in `core/theme/app_colors.dart` were checked for WCAG AA (primary `#15803D` on white = 5.0:1). Buttons are at least 48 dp. | Run on a small and a large emulator and rotate once; screenshot both for the report. |
| **Design match & navigation (10)** — near pixel-perfect, no overflow, no back-stack errors | 34-screen design implemented; role guards in `core/router/app_router.dart`; every scroll view is scrollable in landscape | Compare 5 screens side by side with the Figma PNGs and put them in the report. Rotate every tab once and fix any yellow/black overflow stripe. |
| **Clean architecture (5)** | `lib/domain`, `lib/data`, `lib/presentation`; use cases hold the rules; screens contain no business logic | Explain the data-flow diagram in the video. |
| **State management (10)** | Riverpod `Notifier` controllers + `StreamProvider`s; **no `setState` anywhere** (`grep -R setState lib` returns nothing) | Be ready to answer "why Riverpod?" (see report §4). |
| **Database design (10)** | `docs/ERD.md` + `erd.png`, mappers define each field once, `firestore.rules`, `firestore.indexes.json` | Deploy rules and indexes (README step 4–5). Make sure the ERD in the report is the same image. |
| **CRUD (5)** | Equipment C/R/U/D, bookings C/R/U/D, notifications R/U/D, agent clients C/R/U/D, disputes C/R/U/D, profile R/U, expert availability U | Show each one in the video with the Firebase console open. |
| **Authentication — 2 methods (5)** | E-mail/password + Google, registration, login, logout, password reset, e-mail verification, session persists after restart, validation messages | Enable both providers in the console (README step 1–2). Test Google on a real phone/emulator with Play services. |
| **Widget & unit tests (5)** | `test/` — unit (validators, pricing, use cases, mappers, preferences, router rules), controller and widget tests | Run `flutter test --coverage`, screenshot the passing result and the coverage % for the report. Aim for ≥ 70 %. |
| **SharedPreferences (5)** | text size, notifications, preferred district, remembered e-mail, onboarding seen — all restored on relaunch | Show it in the video: change → close the app → reopen. |
| **Code quality & docs (5)** | README with setup + screenshots, doc comments, small reusable functions | Run `dart format .` and `flutter analyze` → screenshot "No issues found!". Add screenshots to `docs/screenshots`. |
| **Git collaboration (10)** | See `docs/GIT_WORKFLOW.md` | Every member commits real work on a branch, merged by pull request with a review comment. Contribution table in the report must match `git shortlog -sn`. |
| **Report & academic integrity (20)** | `docs/report/` (Word + PDF draft) | Fill every yellow `[INSERT …]`, replace the AI disclosure with your true figures, write the contribution table, export from Word as `Group#_Final_Project_Submission.pdf` (Times New Roman 12 pt body, 14 pt headings). |
| **Video demo (5)** | `docs/DEMO_SCRIPT.md` | Record the **release APK** on a **physical phone**, one continuous take, ≥ 1080p, 10–15 min, every member speaks, no introductions, no slides. |

## Submission-day checklist
- [ ] `flutter analyze` → *No issues found!* (screenshot)
- [ ] `dart format .` run
- [ ] `flutter test --coverage` all green (screenshot + coverage %)
- [ ] `flutter build apk --release` installs and runs on a phone
- [ ] Firebase: Email/Password + Google enabled, rules + indexes deployed, admin user created, demo data loaded
- [ ] `android/app/google-services.json` is **committed** (remove it from `.gitignore`) so reviewers can build
- [ ] GitHub repo is accessible to the reviewer (public, or the instructor is added); README renders
- [ ] Branches + pull requests visible in GitHub; commits spread over the weeks, every member present
- [ ] Contribution tracker copy completed and linked
- [ ] Report PDF named `Group#_Final_Project_Submission.pdf` includes: repo link, demo video link, setup steps, ERD, rules explanation, tests + screenshots, Known Limitations & Future Work, AI disclosure, references
