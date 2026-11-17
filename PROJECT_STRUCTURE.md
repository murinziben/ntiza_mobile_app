# Project Structure: Who Pushes Which File

The full NTIZA app, with the **contributor who pushes each file** written beside it.

- The **name beside each file** is the contributor who pushes it.
- `[Name] (whole folder)` beside a folder means the whole folder, and everything in it, belongs to that person.
- **on main** means the file is already on `main` (the project setup). Nobody pushes it again.
- Folders are listed first, then files, each in A–Z order.

## Contributors

| Push order | Contributor | Branch | Part of the app | Files | Folder & guide |
|---|---|---|---|---|---|
| 1 | **murinziben** (leader) | `murinziben` | Foundation: entities, repository interfaces, Firestore mappers, providers, router, theme, shared widgets, Figma designs | 76 | [team/murinziben/](team/murinziben/HOW_TO_PUSH.md) |
| 2 | **ISHAMI Irené** | `ishami` | Authentication, settings (SharedPreferences), edit profile, notifications | 20 | [team/ishami/](team/ishami/HOW_TO_PUSH.md) |
| 2 | **Kabera Nshuti Samuel** | `samuel` | Farmer: book equipment or an expert, pricing, payment, my bookings | 16 | [team/samuel/](team/samuel/HOW_TO_PUSH.md) |
| 2 | **Maellene** | `maellene` | Public screens (home, marketplace, experts, training), equipment owner, ERD | 19 | [team/maellene/](team/maellene/HOW_TO_PUSH.md) |
| 2 | **Ridaa** | `ridaa` | Admin, booking agent, expert, Firestore security rules, seed tool | 14 | [team/ridaa/](team/ridaa/HOW_TO_PUSH.md) |

Every file belongs to exactly one person, and nobody's files overlap.
murinziben pushes first. The other four push after that branch is merged into `main`, all at the same time.

## What each person owns

| Contributor | Folders and files |
|---|---|
| **on main** (already pushed) | `android/`<br>`assets/`<br>`ios/`<br>`.gitignore`<br>`.metadata`<br>`analysis_options.yaml`<br>`pubspec.lock`<br>`pubspec.yaml` |
| **murinziben** | `design/`<br>`docs/architecture.mmd`, `docs/architecture.png`<br>`docs/dataflow.mmd`, `docs/dataflow.png`<br>`docs/screenshots/`<br>`lib/app.dart`<br>`lib/core/`<br>`lib/data/mappers/`<br>`lib/data/repositories/firebase_errors.dart`<br>`lib/domain/constants.dart`<br>`lib/domain/entities/`<br>`lib/domain/repositories/`<br>`lib/firebase_options.dart`<br>`lib/main.dart`<br>`lib/presentation/controllers/action_notifier.dart`<br>`lib/presentation/providers/`<br>`lib/presentation/widgets/`<br>`test/core/`<br>`test/helpers/`<br>`README.md` |
| **Irené** | `lib/data/repositories/firebase_auth_repository.dart`<br>`lib/data/repositories/firestore_notification_repository.dart`<br>`lib/data/repositories/prefs_settings_repository.dart`<br>`lib/domain/usecases/auth_usecases.dart`<br>`lib/domain/validators.dart`<br>`lib/presentation/controllers/auth_controller.dart`<br>`lib/presentation/controllers/settings_controller.dart`<br>`lib/presentation/screens/auth/`<br>`lib/presentation/screens/common/edit_profile_screen.dart`<br>`lib/presentation/screens/common/notifications_screen.dart`<br>`lib/presentation/screens/common/settings_screen.dart`<br>`test/data/settings_repository_test.dart`<br>`test/domain/validators_test.dart`<br>`test/presentation/widgets_test.dart` |
| **Samuel** | `lib/data/repositories/firestore_booking_repository.dart`<br>`lib/domain/usecases/booking_usecases.dart`<br>`lib/domain/usecases/pricing.dart`<br>`lib/presentation/controllers/booking_controller.dart`<br>`lib/presentation/screens/farmer/`<br>`test/domain/pricing_test.dart`<br>`test/domain/usecases_test.dart` |
| **Maellene** | `docs/ERD.md`, `docs/erd.mmd`, `docs/erd.png`<br>`lib/data/repositories/firestore_catalog_repository.dart`<br>`lib/data/sample_data.dart`<br>`lib/domain/usecases/catalog_usecases.dart`<br>`lib/presentation/controllers/catalog_controller.dart`<br>`lib/presentation/screens/common/role_widgets.dart`<br>`lib/presentation/screens/owner/`<br>`lib/presentation/screens/public/`<br>`test/data/mappers_test.dart` |
| **Ridaa** | `lib/data/repositories/firestore_admin_repository.dart`<br>`lib/domain/usecases/agent_usecases.dart`<br>`lib/presentation/controllers/admin_controller.dart`<br>`lib/presentation/screens/admin/`<br>`lib/presentation/screens/agent/`<br>`lib/presentation/screens/expert/`<br>`test/presentation/controllers_test.dart`<br>`tools/`<br>`firebase.json`<br>`firestore.indexes.json`<br>`firestore.rules` |

## Full file tree

```
ntiza_mobile_application/
├── android/ ............................................... [on main]  (whole folder, 20 files)
├── assets/ ................................................ [on main]  (whole folder)
│   └── images/ ............................................ [on main]  (whole folder)
│       ├── course_agribusiness.jpg ........................ on main
│       ├── course_irrigation.jpg .......................... on main
│       ├── course_livestock.jpg ........................... on main
│       ├── course_soil.jpg ................................ on main
│       ├── harvester.jpg .................................. on main
│       ├── hero_villagers.jpg ............................. on main
│       ├── planter.jpg .................................... on main
│       ├── pump.jpg ....................................... on main
│       ├── tiller.jpg ..................................... on main
│       └── tractor.jpg .................................... on main
├── design/ ................................................ [murinziben]  (whole folder, 34 files)
├── docs/
│   ├── screenshots/ ....................................... [murinziben]  (whole folder)
│   │   └── .gitkeep ....................................... murinziben
│   ├── architecture.mmd ................................... murinziben
│   ├── architecture.png ................................... murinziben
│   ├── dataflow.mmd ....................................... murinziben
│   ├── dataflow.png ....................................... murinziben
│   ├── ERD.md ............................................. Maellene
│   ├── erd.mmd ............................................ Maellene
│   └── erd.png ............................................ Maellene
├── ios/ ................................................... [on main]  (whole folder, 40 files)
├── lib/
│   ├── core/ .............................................. [murinziben]  (whole folder)
│   │   ├── errors/ ........................................ [murinziben]  (whole folder)
│   │   │   └── app_exception.dart ......................... murinziben
│   │   ├── router/ ........................................ [murinziben]  (whole folder)
│   │   │   └── app_router.dart ............................ murinziben
│   │   ├── theme/ ......................................... [murinziben]  (whole folder)
│   │   │   ├── app_colors.dart ............................ murinziben
│   │   │   └── app_theme.dart ............................. murinziben
│   │   └── utils/ ......................................... [murinziben]  (whole folder)
│   │       └── formatters.dart ............................ murinziben
│   ├── data/
│   │   ├── mappers/ ....................................... [murinziben]  (whole folder)
│   │   │   └── firestore_mappers.dart ..................... murinziben
│   │   ├── repositories/
│   │   │   ├── firebase_auth_repository.dart .............. Irené
│   │   │   ├── firebase_errors.dart ....................... murinziben
│   │   │   ├── firestore_admin_repository.dart ............ Ridaa
│   │   │   ├── firestore_booking_repository.dart .......... Samuel
│   │   │   ├── firestore_catalog_repository.dart .......... Maellene
│   │   │   ├── firestore_notification_repository.dart ..... Irené
│   │   │   └── prefs_settings_repository.dart ............. Irené
│   │   └── sample_data.dart ............................... Maellene
│   ├── domain/
│   │   ├── entities/ ...................................... [murinziben]  (whole folder)
│   │   │   ├── agent_client.dart .......................... murinziben
│   │   │   ├── app_notification.dart ...................... murinziben
│   │   │   ├── app_settings.dart .......................... murinziben
│   │   │   ├── app_user.dart .............................. murinziben
│   │   │   ├── booking.dart ............................... murinziben
│   │   │   ├── course.dart ................................ murinziben
│   │   │   ├── dispute.dart ............................... murinziben
│   │   │   ├── entities.dart .............................. murinziben
│   │   │   ├── equipment.dart ............................. murinziben
│   │   │   ├── expert.dart ................................ murinziben
│   │   │   └── role.dart .................................. murinziben
│   │   ├── repositories/ .................................. [murinziben]  (whole folder)
│   │   │   ├── admin_repository.dart ...................... murinziben
│   │   │   ├── auth_repository.dart ....................... murinziben
│   │   │   ├── booking_repository.dart .................... murinziben
│   │   │   ├── catalog_repository.dart .................... murinziben
│   │   │   ├── notification_repository.dart ............... murinziben
│   │   │   └── settings_repository.dart ................... murinziben
│   │   ├── usecases/
│   │   │   ├── agent_usecases.dart ........................ Ridaa
│   │   │   ├── auth_usecases.dart ......................... Irené
│   │   │   ├── booking_usecases.dart ...................... Samuel
│   │   │   ├── catalog_usecases.dart ...................... Maellene
│   │   │   └── pricing.dart ............................... Samuel
│   │   ├── constants.dart ................................. murinziben
│   │   └── validators.dart ................................ Irené
│   ├── presentation/
│   │   ├── controllers/
│   │   │   ├── action_notifier.dart ....................... murinziben
│   │   │   ├── admin_controller.dart ...................... Ridaa
│   │   │   ├── auth_controller.dart ....................... Irené
│   │   │   ├── booking_controller.dart .................... Samuel
│   │   │   ├── catalog_controller.dart .................... Maellene
│   │   │   └── settings_controller.dart ................... Irené
│   │   ├── providers/ ..................................... [murinziben]  (whole folder)
│   │   │   ├── data_providers.dart ........................ murinziben
│   │   │   ├── dependencies.dart .......................... murinziben
│   │   │   └── providers.dart ............................. murinziben
│   │   ├── screens/
│   │   │   ├── admin/ ..................................... [Ridaa]  (whole folder)
│   │   │   │   └── admin_screens.dart ..................... Ridaa
│   │   │   ├── agent/ ..................................... [Ridaa]  (whole folder)
│   │   │   │   └── agent_screens.dart ..................... Ridaa
│   │   │   ├── auth/ ...................................... [Irené]  (whole folder)
│   │   │   │   ├── account_status_screen.dart ............. Irené
│   │   │   │   ├── complete_profile_screen.dart ........... Irené
│   │   │   │   ├── forgot_password_screen.dart ............ Irené
│   │   │   │   ├── guest_account_screen.dart .............. Irené
│   │   │   │   ├── login_screen.dart ...................... Irené
│   │   │   │   ├── register_screen.dart ................... Irené
│   │   │   │   └── verify_email_screen.dart ............... Irené
│   │   │   ├── common/
│   │   │   │   ├── edit_profile_screen.dart ............... Irené
│   │   │   │   ├── notifications_screen.dart .............. Irené
│   │   │   │   ├── role_widgets.dart ...................... Maellene
│   │   │   │   └── settings_screen.dart ................... Irené
│   │   │   ├── expert/ .................................... [Ridaa]  (whole folder)
│   │   │   │   └── expert_screens.dart .................... Ridaa
│   │   │   ├── farmer/ .................................... [Samuel]  (whole folder)
│   │   │   │   ├── book_equipment_screen.dart ............. Samuel
│   │   │   │   ├── book_expert_screen.dart ................ Samuel
│   │   │   │   ├── booking_detail_screen.dart ............. Samuel
│   │   │   │   ├── booking_row.dart ....................... Samuel
│   │   │   │   ├── calendar_card.dart ..................... Samuel
│   │   │   │   ├── farmer_dashboard.dart .................. Samuel
│   │   │   │   ├── farmer_profile_screen.dart ............. Samuel
│   │   │   │   ├── farmer_shell.dart ...................... Samuel
│   │   │   │   ├── my_bookings_screen.dart ................ Samuel
│   │   │   │   └── payment_screen.dart .................... Samuel
│   │   │   ├── owner/ ..................................... [Maellene]  (whole folder)
│   │   │   │   ├── owner_screens.dart ..................... Maellene
│   │   │   │   └── provider_helpers.dart .................. Maellene
│   │   │   └── public/ .................................... [Maellene]  (whole folder)
│   │   │       ├── equipment_detail_screen.dart ........... Maellene
│   │   │       ├── experts_screen.dart .................... Maellene
│   │   │       ├── home_screen.dart ....................... Maellene
│   │   │       ├── marketplace_screen.dart ................ Maellene
│   │   │       ├── public_shell.dart ...................... Maellene
│   │   │       ├── training_screen.dart ................... Maellene
│   │   │       ├── welcome_screen.dart .................... Maellene
│   │   │       └── widgets.dart ........................... Maellene
│   │   └── widgets/ ....................................... [murinziben]  (whole folder)
│   │       └── ui.dart .................................... murinziben
│   ├── app.dart ........................................... murinziben
│   ├── firebase_options.dart .............................. murinziben
│   └── main.dart .......................................... murinziben
├── test/
│   ├── core/ .............................................. [murinziben]  (whole folder)
│   │   ├── formatters_test.dart ........................... murinziben
│   │   └── router_redirect_test.dart ...................... murinziben
│   ├── data/
│   │   ├── mappers_test.dart .............................. Maellene
│   │   └── settings_repository_test.dart .................. Irené
│   ├── domain/
│   │   ├── pricing_test.dart .............................. Samuel
│   │   ├── usecases_test.dart ............................. Samuel
│   │   └── validators_test.dart ........................... Irené
│   ├── helpers/ ........................................... [murinziben]  (whole folder)
│   │   └── fakes.dart ..................................... murinziben
│   └── presentation/
│       ├── controllers_test.dart .......................... Ridaa
│       └── widgets_test.dart .............................. Irené
├── tools/ ................................................. [Ridaa]  (whole folder)
│   ├── package-lock.json .................................. Ridaa
│   ├── package.json ....................................... Ridaa
│   ├── README.md .......................................... Ridaa
│   └── seed.js ............................................ Ridaa
├── .gitignore ............................................. on main
├── .metadata .............................................. on main
├── analysis_options.yaml .................................. on main
├── firebase.json .......................................... Ridaa
├── firestore.indexes.json ................................. Ridaa
├── firestore.rules ........................................ Ridaa
├── pubspec.lock ........................................... on main
├── pubspec.yaml ........................................... on main
└── README.md .............................................. murinziben
```
