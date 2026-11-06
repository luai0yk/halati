# Halati (حالاتي) — WhatsApp Status Saver

<p align="center">
  <img src="assets/images/app_icon.png" alt="Halati Logo" width="100" />
</p>

<p align="center">
  A clean, modern, and high-performance WhatsApp Status Saver for Android built with Flutter & Clean Architecture.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Android-Scoped%20Storage%20(SAF)-brightgreen?style=for-the-badge&logo=android" alt="Android SAF" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="License" />
</p>

---

## 🌟 Overview

**Halati** is an open-source WhatsApp status manager that allows users to discover, view, automatically save, and organize media statuses from both **WhatsApp Messenger** and **WhatsApp Business** seamlessly in one place.

Built to comply fully with modern Android scoped storage requirements via the **Storage Access Framework (SAF)**, Halati delivers smooth performance without requiring deprecated broad storage permissions.

---

## ✨ Features

- **Dual WhatsApp Support**: Effortlessly toggle between WhatsApp Messenger and WhatsApp Business.
- **Swipe Tab Navigation**: Seamless horizontal swiping between **Statuses**, **Saved**, and **Settings** tabs with state preservation.
- **Media Support**: Full support for viewing and playing high-resolution **images**, **videos**, and **audio** statuses.
- **One-Click & In-Viewer Save**: Download statuses directly from the grid or within the full-screen media viewer.
- **Delete from Anywhere**: Delete saved statuses directly from the Home grid or the media viewer with an intuitive confirmation dialog.
- **Auto-Save Opened Statuses**: Optional setting to automatically save statuses upon opening without blocking viewer interactions.
- **Custom Save Folders**:
  - Independent storage paths for WhatsApp and WhatsApp Business.
  - Granular folder selection with Android SAF.
  - Automatic organization into structured subdirectories:
    ```text
    Download/
    └── Halati/
        ├── WhatsApp/
        │   ├── Halati Videos/
        │   ├── Halati Images/
        │   └── Halati Audios/
        └── WhatsApp Business/
            ├── Halati Videos/
            ├── Halati Images/
            └── Halati Audios/
    ```
  - Easy one-tap option to restore default locations.
- **Offline Persistence**: Fast local caching and database tracking using **Drift (SQLite)**.
- **Localization (i18n)**: Native **Arabic** (with RTL layout support) and **English** localization.
- **Theme Modes**: Native system-based, Light, and Dark themes adhering to Material 3 guidelines.

---

## 🛠️ Tech Stack & Architecture

| Technology | Purpose |
| :--- | :--- |
| **Flutter & Dart** | Cross-platform UI toolkit and core language |
| **GetX** | State management, dependency injection, and micro-navigation |
| **Drift (SQLite)** | Reactive local database for tracking saved media metadata |
| **Storage Access Framework (SAF)** | Native Kotlin MethodChannel handling scoped storage permissions and file streams |
| **Video Player & Photo View** | Media inspection, zoom, and playback |

### Architecture Principles

The application strictly follows **Clean Architecture** and a feature-first folder structure:

- **Presentation Layer**: UI widgets and GetX Controllers decoupled from direct data queries.
- **Domain Layer**: Independent business entities and use cases (e.g., `SaveMediaUseCase`, `DeleteSavedMediaUseCase`, `GetStatusesUseCase`).
- **Data Layer**: Repositories, Drift DAOs, and native SAF platform channel data sources.
- **Shared & Core**: Reusable design system tokens, custom UI widgets, and application helpers.

```text
lib/
├── core/
│   ├── database/         # Drift database schema & DAOs
│   ├── l10n/             # ARB files & generated localization classes
│   ├── platform/         # SAF channel method constants
│   ├── services/         # Key-value persistent preferences (CashService)
│   ├── theme/            # Light, dark & Material 3 extended palettes
│   └── utils/            # Shared UI dialogs, formatters & extensions
├── features/
│   ├── app_shell/        # Main shell hosting swipeable PageView & bottom nav
│   ├── home/             # Status discovery, filtering, and saving
│   ├── saved/            # Saved status library, media management & deletion
│   ├── settings/         # Save folder config, auto-save toggle, themes & info
│   └── viewer/           # Full-screen media viewer with filmstrip & auto-save
└── shared/
    └── widgets/          # Reusable cards, buttons, switches & dialogs
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.11.5` or later
- Dart SDK `^3.11.5`
- Android Studio / VS Code with Flutter extension
- Android device or emulator running Android 8.0 (API 26) or newer with WhatsApp or WhatsApp Business installed

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/luai0yk/halati.git
   cd halati
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (Localizations & Drift):**
   ```bash
   flutter gen-l10n
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

5. **Run tests & static analysis:**
   ```bash
   flutter analyze
   flutter test
   ```

---

## 📱 Permissions & Storage Access

Halati conforms to **Android Scoped Storage** policies:
1. When opening WhatsApp or WhatsApp Business for the first time, Halati prompts you to select the respective `.Statuses` folder via Android's document picker.
2. Halati takes a persistable read permission so you don't need to grant access every time you open the app.
3. Media is saved to public `Download/Halati/` directories or your chosen custom folder using MediaStore or SAF without requiring `MANAGE_EXTERNAL_STORAGE` or legacy permissions.

---

## 🤝 Contributing

Contributions are always welcome!

1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## ⚠️ Disclaimer

Halati is an independent application developed for personal utility and is **not** affiliated with, endorsed by, or officially associated with WhatsApp Inc. or Meta Platforms, Inc.

"WhatsApp" and "WhatsApp Business" are trademarks of Meta Platforms, Inc. Halati only accesses locally cached media present on the user's device with explicit user-granted permissions.

---

## 👤 Author

**Luai Kaleessi**
- GitHub: [@luai0yk](https://github.com/luai0yk)

---

<p align="center">
  Crafted with care using Flutter 💙
</p>
