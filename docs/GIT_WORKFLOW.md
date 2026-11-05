# Git workflow for the team

The rubric reads your **Git history**: commits spread over time and across members, each pull request
reviewed, the contribution table matching Git statistics, contributions fairly shared, branches for every
member, **no last-minute dump**.

## Branches
```
main                 protected: only merged through pull requests
feature/auth         e.g. member A: login, register, Google, password reset
feature/farmer       member B: marketplace, booking, payment
feature/owner-expert member C: owner + expert dashboards, equipment CRUD
feature/admin-agent  member D: admin, agent, settings (SharedPreferences)
feature/tests-docs   anyone: tests, README, report
```
Create: `git checkout -b feature/auth` → work → `git push -u origin feature/auth` → open a pull request.

## Commit messages
Use short, descriptive, imperative messages, for example:
`Add password reset screen and validation`, `Fix overflow on marketplace in landscape`,
`Test BookingPricing service fee`. One idea per commit; commit at least every working session.

## Pull requests
1. Open a PR into `main` with a description of *what* and *how to test*.
2. A **different** member reviews, leaves at least one real comment (not just "ok") and approves.
3. Squash or merge; delete the branch afterwards.

## Fair split of the existing code
The app already exists in the repository history as a few large commits. From now on, each member must
take ownership of real work packages so the history shows your own contributions. Suggested packages:

| Member | Package | Examples of real tasks |
|---|---|---|
| A | Authentication & settings | review/extend validators, verification flow, SharedPreferences screens, auth tests |
| B | Farmer side | booking flow polish, calendar, payment, My Bookings, widget tests |
| C | Owner & expert side | equipment form, earnings, availability, mapper/use-case tests |
| D | Admin, agent, backend | rules, indexes, dispute flow, seed data, README, report |

Do **only real work** under your own name — graders compare commits with the contribution tracker, and the
report must describe honestly who did what.

## Statistics for the report
```bash
git shortlog -sn --all            # commits per member
git log --author="Name" --stat    # files changed by one member
git log --since="2026-11-01" --pretty="%h %an %ad %s" --date=short
```
Copy these numbers into the contribution table in the report and in the Group Contribution Tracker.

## Important repository settings
* **Commit `android/app/google-services.json`.** It is not secret (it only identifies the Firebase project;
  the rules protect the data). Remove it from `.gitignore`, otherwise reviewers cannot build the app.
* Add the instructor as a collaborator if the repository is private (or make it public).
