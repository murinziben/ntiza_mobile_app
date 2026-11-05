# Demo video script (10–15 minutes, one continuous take)

**Rules from the rubric:** release APK on a **physical phone** · screen recording ≥ 1080p, crisp audio · **no
slides, no introductions** · no cuts or speed-ups · every member speaks about a feature · phone *and* Firebase
console both legible (put the console on a laptop browser, or use a split screen / second camera shot).

Tip: record the phone with `scrcpy` or the phone's screen recorder, and show the Firebase console on the
laptop. Prepare accounts beforehand: one farmer, one owner (approved), the admin. Keep the demo data loaded.
Practice once; you cannot cut.

| Time | Who | What to do | Rubric action |
|---|---|---|---|
| 0:00 | Member 1 | Force-stop the app, open it from the launcher (**cold start**). Welcome screen → "Continue as guest" → browse marketplace, open an equipment detail, experts, training. Rotate the phone once on the marketplace. | 1 cold start, 3 screens + rotate |
| 1:30 | Member 1 | **Register** a new farmer (show the inline validation: leave fields empty, bad e-mail, short password → polite messages) → verification screen → open the e-mail, tap the link → "I have verified" → farmer home. **Log out → log in** again. Show *Forgot password?* sending the reset e-mail. | 2 register → logout → login, 7 validation error |
| 4:00 | Member 2 | **Google sign-in** on a second account (complete-profile screen). Show Firebase **Authentication → Users** listing both methods. | second auth method |
| 5:00 | Member 2 | Farmer: **Create** a booking (calendar, duration, price summary → pay with MoMo demo). In Firestore console show the new `bookings/NTZ-…` document. **Read:** My Bookings and booking detail. **Update:** cancel a pending booking (console shows status change). **Delete:** delete a completed/cancelled booking from history (document disappears). | 4 CRUD with console visible |
| 8:00 | Member 3 | Switch to owner: **add** equipment (appears in console and marketplace at once), **edit** the price, **change status** to Maintenance, **delete** it (try with an open booking first to show the friendly error). Accept a booking request → farmer's notification arrives. | CRUD, 5 state update touching two widgets |
| 10:30 | Member 3 | Notification list: mark read, swipe to delete; the bell badge on the dashboard updates (two widgets, one state). | 5 state update touching two widgets |
| 11:30 | Member 4 | **Settings:** change text size and preferred district, switch notifications off → **close the app completely and reopen** → show the settings and the marketplace filter persisted. Explain SharedPreferences. | 6 SharedPreferences persisted |
| 12:30 | Member 4 | Admin: approve a pending owner, suspend a user, resolve a dispute, show security by trying a forbidden action (e.g. farmer opening `/admin` redirects back). Show `firestore.rules` for 20 s. | rules / roles |
| 14:00 | Any | Visit remaining screens quickly (agent, expert dashboards). Finish. | 3 every screen |

If a group has fewer than four people, merge the rows; if more, split the rows so everyone speaks.

## Before pressing record
- [ ] Phone battery > 70 %, Do-Not-Disturb on, brightness high, stable Wi-Fi
- [ ] Firebase console open on Firestore data tab, with the collection you will touch visible
- [ ] Accounts and demo data prepared; the app force-stopped
- [ ] Microphone test; no fan hum or echo
