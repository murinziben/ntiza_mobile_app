# NTIZA — agricultural equipment & expert marketplace for Rwanda

NTIZA lets Rwandan farmers **find and book tractors, harvesters, pumps and other equipment**,
**consult agricultural experts**, **pay with Mobile Money** and **take short training courses**.
Equipment owners, experts and booking agents have their own dashboards, and an admin approves partners.

Built with **Flutter (Material 3)**, **Riverpod** for state management, **go_router**, and
**Firebase** (Authentication + Cloud Firestore). Runs on Android and iOS only (mobile app).

| | |
|---|---|
| Firebase project | `ntiza-e9af2` |
| State management | Riverpod 2 (`Notifier`, `StreamProvider`, `StateProvider`) |
| Architecture | Clean Architecture: `presentation` → `domain` ← `data` |
| Database | Cloud Firestore (see [`docs/ERD.md`](docs/ERD.md)) |
| Auth methods | E-mail + password (with e-mail verification and password reset) **and** Google |

## Screenshots

Screenshots are stored in [`docs/screenshots`](docs/screenshots). Add yours after running the app:

| Welcome | Marketplace | Booking | Owner dashboard | Admin |
|---|---|---|---|---|
| ![welcome](docs/screenshots/welcome.png) | ![market](docs/screenshots/marketplace.png) | ![booking](docs/screenshots/booking.png) | ![owner](docs/screenshots/owner.png) | ![admin](docs/screenshots/admin.png) |

## Features

| Role | What they can do |
|---|---|
| **Visitor** | Browse equipment, experts and courses; open the equipment detail page |
| **Farmer** | Register, verify e-mail, book equipment or an expert (calendar, duration, price summary), pay by MTN MoMo / Airtel Money (demo), track bookings, cancel / delete history, report a problem, receive notifications |
| **Equipment owner** | Add, edit, delete equipment; change status (Available / Booked / Maintenance); accept, decline and complete requests; earnings chart from real bookings |
| **Expert** | Set weekly availability and fee, accept or decline consultation requests, see earnings |
| **Booking agent** | Manage a list of farmers (add / edit / delete), book equipment on their behalf, see commission |
| **Admin** | Approve or reject partner applications, suspend / reactivate / delete users, resolve disputes, load demo data |
| **Everyone** | Settings: text size, notifications on/off, preferred district (saved with SharedPreferences), edit profile |

### Requirements checklist (course rubric)

| Requirement | Where |
|---|---|
| Advanced state management, no `setState` | Riverpod controllers in `lib/presentation/controllers`, providers in `lib/presentation/providers` |
| Clean Architecture | `lib/domain` (entities, repository interfaces, use cases), `lib/data` (Firebase), `lib/presentation` (screens, widgets, providers) |
| ERD + Firestore | [`docs/ERD.md`](docs/ERD.md), mappers in `lib/data/mappers/firestore_mappers.dart` |
| CRUD | Equipment, bookings, notifications, agent clients, disputes, profile, expert availability |
| Two auth methods | E-mail/password + Google; registration, login, logout, password reset, e-mail verification, session kept across restarts |
| Security rules | [`firestore.rules`](firestore.rules), indexes in [`firestore.indexes.json`](firestore.indexes.json) |
| SharedPreferences (≥ 3) | text size, notifications, preferred district, remembered e-mail, onboarding seen |
| Tests | `test/` — unit, widget and controller tests (`flutter test --coverage`) |

## Project structure

```
lib/
├── main.dart, app.dart            # entry point, MaterialApp.router
├── core/                          # theme, router (with role guards), formatters, errors
├── domain/                        # pure Dart — no Flutter, no Firebase
│   ├── entities/                  #   Equipment, Booking, AppUser, Expert, ...
│   ├── repositories/              #   abstract interfaces
│   ├── usecases/                  #   auth, booking, catalog, agent rules + pricing
│   └── validators.dart            #   input validation
├── data/                          # Firebase implementations of the interfaces
│   ├── mappers/                   #   Firestore map <-> entity
│   └── repositories/              #   Auth, Firestore, SharedPreferences
└── presentation/
    ├── controllers/               #   Riverpod Notifiers (ActionResult pattern)
    ├── providers/                 #   dependency injection + live Firestore streams
    ├── screens/                   #   public, auth, farmer, owner, agent, expert, admin, common
    └── widgets/                   #   reusable UI (cards, buttons, fields, chips)
test/                              # unit, widget and controller tests with in-memory fakes
docs/                              # ERD, report material, demo script
```

**Data flow:** a screen calls a controller (`ref.read(bookingControllerProvider.notifier)`),
the controller calls a use case in the domain layer (validation and business rules), the use case
calls a repository *interface*, and the Firebase implementation in `data` talks to Firestore.
Screens *watch* stream providers, so every change in Firestore appears instantly without a refresh.

## Setup

### 1. Prerequisites
* Flutter 3.24 or newer (tested with 3.47) and an Android emulator or a physical phone
* A Firebase project (already configured: `lib/firebase_options.dart` and `android/app/google-services.json`)

### 2. Firebase console (one time)
1. **Authentication → Sign-in method:** enable **Email/Password** and **Google**
   (set a project support e-mail for Google).
2. **Project settings → Your apps → Android:** add your debug **SHA-1 and SHA-256**
   (`cd android && ./gradlew signingReport`), then download `google-services.json` again.
3. **Firestore Database → Create database** (production mode).
4. **Rules:** paste [`firestore.rules`](firestore.rules) and publish — or `firebase deploy --only firestore:rules`.
5. **Indexes:** `firebase deploy --only firestore:indexes` (the queries sort by `createdAt`).
   If you skip this, the first query logs a link that creates the missing index with one click.
6. **Create the admin:** register a normal account in the app, open **Firestore → users → (your uid)**
   and set `role` = `admin`, `status` = `active`. Log in again, then **More → Load demo data**.

### 3. Run
```bash
flutter pub get
flutter run                 # pick the emulator or the connected phone — not Chrome or desktop
flutter build apk --release # release APK in build/app/outputs/flutter-apk/
```

### 4. Quality checks
```bash
dart format .
flutter analyze
flutter test --coverage      # coverage report: coverage/lcov.info
```

## Security rules in one minute
* Everything is denied unless a rule allows it.
* A user reads and edits only **their own** profile (`name`, `phone`, `district`); roles and approval
  status can never be self-assigned; nobody can create an admin.
* Bookings are visible only to the farmer, the provider, the booking agent and admins; each side may
  change only the fields it is meant to (provider → `status`; farmer → `paidVia` or cancel while pending).
* Equipment is public to read; only an **approved owner** can create it and only for themselves.
* Notifications, agent clients and disputes are private to their owner / admin.

## Known limitations
* Mobile Money payment is **simulated** (a 2-second approval, then the booking is marked paid). A real
  charge needs a Cloud Function and MTN / Airtel merchant credentials.
* Equipment photos are chosen from the machine type; there is no image upload (Firebase Storage) yet.
* Push notifications (FCM) are not wired — notifications appear inside the app.
* The booking counter and notification writes happen on the client; before launch they should move to
  Cloud Functions.
* Dark theme and Kinyarwanda translations are future work.
