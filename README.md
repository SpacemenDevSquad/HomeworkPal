# HomeworkPal

**A free, private homework and activity planner for iPhone and iPad.**

HomeworkPal helps high school and college students keep track of homework, projects, and extracurricular commitments in one clean, simple place. No account, no ads, no tracking, just your assignments, organized by when they're due.

<!--
  ============================================================
  APP STORE — replace the placeholders below once HomeworkPal is live.
  ============================================================
-->

## Download

> 🚧 **Coming soon to the App Store.**

<!-- Replace APP_STORE_URL with the app's App Store link, e.g. https://apps.apple.com/app/idXXXXXXXXXX -->
<!-- Official badge artwork: https://developer.apple.com/app-store/marketing/guidelines/ -->
[![Download on the App Store](docs/images/app-store-badge.svg)](APP_STORE_URL)

## Screenshots

<!-- Add App Store screenshots to docs/images/ and update the file names below. -->

| Upcoming | Calendar | Activities | Settings |
|:---:|:---:|:---:|:---:|
| ![Upcoming](docs/images/screenshot-upcoming.png) | ![Calendar](docs/images/screenshot-calendar.png) | ![Activities](docs/images/screenshot-activities.png) | ![Settings](docs/images/screenshot-settings.png) |

---

## Features

- **Upcoming:** see everything that's due, grouped into Overdue, Today, Tomorrow, This Week, and Later, and check work off as you finish it.
- **Calendar:** a week-at-a-glance view with a timeline of each day's assignments. Busy days are flagged so crowded weeks are easy to spot.
- **Classes & activities:** organize work by class or extracurricular, each with its own color and optional location.
- **Add to Apple Calendar:** put any due date in your calendar with Apple's own Add Event screen. HomeworkPal never needs access to your calendar.
- **iCloud Sync:** keep your planner up to date on all your Apple devices through your own private iCloud, with no account to create.
- **Private by design:** your data stays on your device (and in your iCloud, if you choose). No ads, no analytics, no servers.

## Privacy

HomeworkPal doesn't collect any personal information. Read the full [Privacy Policy](PRIVACYPOLICY.md).

---

## Building from source

### Requirements

- Xcode with the iOS 27 SDK
- iOS 27 or later (iPhone and iPad)
- An Apple Developer Program membership, for iCloud Sync

### Getting started

1. Clone the repository:
   ```sh
   git clone https://github.com/SpacemenDevSquad/HomeworkPal.git
   ```
2. Open `HomeworkPal.xcodeproj` in Xcode.
3. In **Signing & Capabilities**, select your own development team.
4. To use iCloud Sync, change the iCloud container from `iCloud.com.peterbrumbach.HomeworkPal` to one registered to your team, and update `SwiftDataPlannerService.cloudKitContainerIdentifier` to match.
5. Build and run (⌘R). Run the tests with ⌘U.

### Project structure

The app follows MVVM and is organized by feature:

```
HomeworkPal/
├── App/            App entry point and tab bar
├── Features/       Dashboard, Calendar, Activities, Assignments, Settings
│                   (each with Views, ViewModels, and Models)
├── Core/           Persistence (SwiftData + CloudKit) and services
├── Shared/         Reusable components, models, and design tokens
└── Resources/      Assets, strings, and the privacy manifest
HomeworkPalTests/   Swift Testing unit tests, mirroring the app's structure
```

### Built with

- **SwiftUI** for the interface, with Liquid Glass
- **SwiftData** for on-device storage, mirrored to **CloudKit** for iCloud Sync
- **EventKitUI** for adding due dates to Apple Calendar
- **Swift Testing** for unit tests

Coding standards for contributors are in [`Documents/CLAUDE.md`](Documents/CLAUDE.md).

---

## Contributing

HomeworkPal is open source, and contributions are welcome. Please open an [issue](https://github.com/SpacemenDevSquad/HomeworkPal/issues) to report a bug or suggest a feature before starting on a pull request.

## License

<!-- Choose a license (for example MIT or Apache 2.0), add a LICENSE file, and update this section. -->
License to be decided.

---

Made by [SpacemenDevSquad](https://github.com/SpacemenDevSquad).
