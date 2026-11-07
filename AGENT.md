# AGENT.md — Halati (حالاتي): Engineering Architecture & Development Guide

> **Authoritative Development Manual & Source of Truth**  
> **Target Audience:** AI Coding Agents & Senior Flutter Engineers  
> **Repository:** `luai0yk/status-saver` (Package: `halati`)  
> **Platform Target:** Android Exclusively (API 24+ / targetSdk 34+)  
> **Framework & State Management:** Flutter 3.11+ / GetX 4.7+ / Clean Architecture  
> **App Name:** Halati (English) / حالاتي (Arabic)

---

## 1. Executive Summary & Purpose

This document serves as the permanent architectural guide, code standard, and operational directive for all AI coding agents working on the **Halati (حالاتي)** application. Every future task, feature implementation, refactoring, or bug fix must strictly comply with the patterns, contracts, directory structures, and constraints documented herein.

The application is a focused, high-performance, lightweight Flutter client designed to browse, preview, share, auto-save, and save locally cached **WhatsApp** and **WhatsApp Business** status media (images, videos, and audio notes) on Android devices.

---

## 2. Confirmed Product Invariants & Non-Negotiable Decisions

Before planning or executing any changes, verify compliance with these confirmed product invariants:

1. **Android Only**: All status discovery, storage access, media viewing, and gallery saving are engineered exclusively for Android. iOS does not allow local filesystem access to other apps' sandbox containers; iOS status access is permanently unsupported.
2. **Dual WhatsApp Support (WhatsApp & WhatsApp Business)**:
   - The application natively supports both official WhatsApp editions:
     - **WhatsApp Messenger** (`com.whatsapp`)
     - **WhatsApp Business** (`com.whatsapp.w4b`)
   - Independent SAF folder permissions are maintained for each (`CashKeys.safTreeUri` and `CashKeys.safTreeUriBusiness`).
   - Users seamlessly switch between editions via `WhatsAppTypeSwitch` in the app bar.
   - A configurable default edition preference (`defaultWhatsAppType`) controls which client loads on launch.
   - Third-party modified clones (GBWhatsApp, etc.) remain strictly out of scope.
3. **Android Storage Access Framework (SAF) Exclusively**:
   - Access to WhatsApp status files is achieved solely via user-granted directory tree permissions using `Intent.ACTION_OPEN_DOCUMENT_TREE`.
   - Never request or use `MANAGE_EXTERNAL_STORAGE` (`android.permission.MANAGE_EXTERNAL_STORAGE`).
   - Never rely on raw `File('/storage/emulated/0/...')` paths for WhatsApp media on modern Android. SAF document URIs (`content://...`) are the sole currency of media exchange.
   - Target status paths:
     - WhatsApp (Android 11+): `Android/media/com.whatsapp/WhatsApp/Media/.Statuses`
     - WhatsApp Business (Android 11+): `Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses`
     - Legacy (Android 10 & below): `WhatsApp/Media/.Statuses` and `WhatsApp Business/Media/.Statuses`
4. **Unified Three-Column Media Grid**:
   - Discovered statuses (images, videos, and audio) appear in a unified, three-column responsive grid sorted strictly **newest first** (`lastModified` descending).
   - Clear visual differentiation:
     - **Images**: Crisp thumbnail preview.
     - **Videos**: Center-aligned translucent play badge (`AppIcons.video` / play icon) + bottom duration pill.
     - **Audio**: Custom audio card/waveform graphic with headphone/music indicator (`AppIcons.music` / audio icon) + bottom duration pill.
5. **Three Persistent Navigation Destinations with Horizontal Swipe**:
   - **Statuses (Home)**: Unified status grid, edition switch, permission banner, sync status, and pull-to-refresh.
   - **Saved**: Drift-backed persistent gallery of saved media, filterable by type, with direct deletion and share support.
   - **Settings**: Theme selection (System, Light, Dark), language switcher (English, Arabic), default WhatsApp edition, independent save folder configurations, auto-save toggle, and About Halati.
   - Hosted inside `AppShellPage` with a swipeable `PageView` synchronized bidirectionally with `MyBottomNavigationBar` (`KeepAliveTab` preserving tab state).
6. **Bilingual Support & Full RTL Compliance**:
   - Supported languages: **English (`en`)** and **Arabic (`ar`)**.
   - Bidirectional UI must be strictly enforced using direction-aware styling, localized strings via ARB, and RTL-safe icons (`AppIcons.arrowBack(context)`, `AppIcons.arrowForward(context)`).
   - App Launcher Name is localized via Android resources: **Halati** (`values/strings.xml`) and **حالاتي** (`values-ar/strings.xml`).
7. **Foreground Auto-Save Option & No Background Polling**:
   - No background services, WorkManager periodic tasks, or alarm managers to preserve device battery.
   - Optional, user-configurable **Auto-Save Opened Statuses** setting (`CashKeys.autoSaveOpenedStatuses`): automatically and silently saves any status to gallery and Drift database when opened in the full-screen media viewer without interrupting user interactions.
8. **Structured & Custom Save Locations**:
   - Default save location: `Download/Halati/WhatsApp/` and `Download/Halati/WhatsApp Business/` organized into subdirectories `Halati Images`, `Halati Videos`, and `Halati Audios`.
   - Independent custom destination selection per WhatsApp edition via SAF folder picker, with a one-tap option to restore default locations.
9. **Delete from Anywhere**:
   - Saved media can be deleted directly from the Home grid or the Media Viewer via `DeleteSavedMediaUseCase.deleteByOriginalUri`, instantly updating Drift and invoking Android MediaScanner to synchronize gallery state.

---

## 3. Architecture & Clean Engineering Principles

The project strictly follows **Clean Architecture**, **SOLID principles**, and **Feature-First organization**, layered with **GetX** for state orchestration and dependency injection.

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                      │
│     Widgets, Pages, GetxControllers, Bindings, ViewModels   │
└──────────────────────────────┬──────────────────────────────┘
                               │ depends on
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                         │
│       Entities (Pure Dart), Use Cases, Repository Contracts │
└──────────────────────────────▲──────────────────────────────┘
                               │ implements
                               │
┌──────────────────────────────┴──────────────────────────────┐
│                         DATA LAYER                          │
│   Models, Data Sources (SAF Platform Channel, Drift DB),    │
│                 Repository Implementations                  │
└─────────────────────────────────────────────────────────────┘
```

### 3.1 Strict Layer Responsibilities & Boundaries

#### Domain Layer (`features/<feature>/domain/` & `core/domain/`)
- **Entities**: Pure Dart classes modeling business domain concepts (e.g., `StatusMedia`, `SavedMedia`). Zero dependencies on Flutter, GetX, Android APIs, or UI libraries. Models are immutable (`@immutable` with `const` constructors).
- **Repository Contracts**: Abstract interfaces specifying what data operations exist (e.g., `StatusRepository`, `SavedMediaRepository`), returning typed `Future<Result<T, Failure>>` or `Stream<T>`.
- **Use Cases**: Single-responsibility classes implementing specific application business logic (e.g., `GetStatusesUseCase`, `SaveMediaUseCase`, `DeleteSavedMediaUseCase`, `SyncSavedMediaUseCase`, `CheckSafAccessUseCase`).

#### Data Layer (`features/<feature>/data/`)
- **Models**: Data transfer representations extending domain entities or providing serialization (`StatusMediaModel`, `SavedMediaModel`, `MediaViewerItem`).
- **Data Sources**:
  - `SafNativeDataSource`: MethodChannel bridge handling native Android SAF calls (`checkDirectoryAccess`, `discoverStatuses`, `saveToMediaStore`, `deleteFromMediaStore`, etc.).
  - `SavedMediaLocalDataSource`: Drift/SQLite database operations for persistent records.
- **Repositories (Implementations)**: Concrete implementations of domain repository interfaces. Catches raw platform exceptions and maps them into strongly typed domain `Failure` instances.

#### Presentation Layer (`features/<feature>/presentation/` or `view/` / `controller/`)
- **Pages & Widgets**: Pure UI. Never execute database queries, invoke platform channels directly, decode files, or hold business logic.
- **GetxControllers**: Manage presentation state, listen to reactive variables (`Rx`), handle UI lifecycle, and execute Use Cases. Controllers coordinate state but delegate all business decisions to Use Cases.
- **Bindings**: Configure dependency injection per route/page using `Get.lazyPut()` or `Get.put()`.

### 3.2 Error Handling & Functional Results

Never allow unhandled exceptions or generic `catch (e)` blocks to swallow errors silently. Standardize on the `Result<T, Failure>` pattern:

```dart
sealed class Result<S, F extends Failure> {
  const Result();
}

class Success<S, F extends Failure> extends Result<S, F> {
  final S value;
  const Success(this.value);
}

class FailureResult<S, F extends Failure> extends Result<S, F> {
  final F failure;
  const FailureResult(this.failure);
}
```

#### Core Domain Failure Hierarchy
- `SafPermissionDeniedFailure`: User dismissed or denied the SAF directory picker.
- `SafFolderInvalidFailure`: Selected folder is not the expected `.Statuses` folder.
- `SafAccessRevokedFailure`: Stored SAF Uri permission was revoked or expired.
- `MediaReadFailure`: Failed to read bytes or metadata from SAF document URI.
- `ThumbnailGenerationFailure`: Native Android failure creating preview thumbnail.
- `MediaStoreSaveFailure`: Failed to write media into Android MediaStore.
- `DatabaseFailure`: SQLite / Drift persistence failure.

---

## 4. State Management with GetX: Strict Guidelines

GetX is mandatory throughout the application. Agents must adhere to the following rules:

### 4.1 Reactive Variables & Controllers
- Use specific reactive primitives: `final RxList<StatusMedia> statuses = <StatusMedia>[].obs;`, `final RxBool isLoading = false.obs;`, `final Rx<WhatsAppType> selectedType = WhatsAppType.whatsapp.obs;`.
- In views, wrap **only the minimal widget** requiring updates in `Obx(() => ...)`. Never wrap an entire `Scaffold` or `ListView` in `Obx` if only a small child icon or badge is reactive.
- Use `GetBuilder` with unique IDs (e.g., `SettingsController.themeId`, `SettingsController.whatsappSettingId`) when discrete, batch updates are preferable over continuous streams.

### 4.2 Dependency Injection via Bindings
- All controllers, use cases, and repositories must be bound using `Bindings` and loaded with `GetPage(..., binding: HomeBinding())`.
- Global services (such as `CashService` and `SettingsController`) are registered permanently in `main.dart` with `permanent: true`.
- Never instantiate controllers inside `build()` methods or use `Get.put()` inside stateless/stateful widget builds.

### 4.3 Navigation
- Use named routes defined in `AppRoutes` (`AppRoutes.shell`, `AppRoutes.viewer`, `AppRoutes.about`, `AppRoutes.licenses`).
- Perform route transitions via `Get.toNamed(...)`.
- Use `AppNavigator.key` and existing UI helpers (`BottomSheetHelper`, `DialogHelper`, `SnackbarHelper`, `ToastHelper`) for modal overlays.

---

## 5. Mandatory Reuse of Existing Codebase Assets

The repository contains a rich set of foundational utilities, themes, services, and shared widgets. **AI agents are strictly forbidden from creating redundant, duplicate implementations.**

### 5.1 Core Infrastructure (`lib/core/`)

| Path / File | Purpose | Key Symbols / Classes | Usage Instruction |
|---|---|---|---|
| `core/constants/app_icons.dart` | Unified Iconsax-based icon dictionary with RTL awareness | `AppIcons.home`, `AppIcons.arrowBack(context)`, `AppIcons.arrowForward(context)`, `AppIcons.whatsapp`, `AppIcons.download`, `AppIcons.delete` | Always use `AppIcons` instead of `Icons.*` |
| `core/constants/app_constants.dart` | Global constants & typography configuration | `AppConstants.fontFamily` (`NotoSansArabic`), input max lengths | Use for typography and global length constants |
| `core/constants/app_durations.dart` | Animation duration tokens | `AppDurations.fast`, `AppDurations.medium`, `AppDurations.slow` | Use for transitions, animations, and dialogs |
| `core/constants/app_assets.dart` | Static image and SVG asset references | `AppAssets.appIcon` | Reference static app assets |
| `core/enums/whatsapp_type.dart` | WhatsApp client enumeration | `WhatsAppType.whatsapp`, `WhatsAppType.business`, `isBusiness`, `packageName`, `folderName` | Use whenever referencing client editions |
| `core/platform/saf_channel.dart` | MethodChannel constants | `SafChannel.channelName` (`com.luai0yk.halati/saf`), method constants | Reference when interacting with native SAF bridge |
| `core/services/cash/cash_service.dart` | Centralized `SharedPreferences` GetX service | `CashService`, `contains()`, `getString()`, `setString()`, `getBool()`, `setBool()` | Inject via `Get.find<CashService>()` |
| `core/services/cash/cash_keys.dart` | Key constants for `CashService` | `CashKeys.themeMode`, `CashKeys.safTreeUri`, `CashKeys.safTreeUriBusiness`, `CashKeys.autoSaveOpenedStatuses`, `CashKeys.defaultWhatsAppType` | Central repository for preference keys |
| `core/theme/material_theme.dart` | Theme generator with responsive typography | `MaterialTheme`, `responsiveTextTheme(context)`, `light()`, `dark()` | Standard theme definition |
| `core/utils/extensions/context_extension.dart` | Context shortcuts for colors, text, and localization | `context.colorScheme`, `context.textTheme`, `context.l10n`, `context.isDark` | Use in every widget for clean theme access |
| `core/utils/extensions/responsive_values.dart` | Standardized padding, radius, and spacing tokens | `context.insetsAllM`, `context.spaceS`, `context.spaceM`, `context.radiusL` | Use for layout margins, insets, and spacings |
| `core/utils/extensions/responsive_size.dart` | Responsive dimension scaling | `context.setSize()`, `context.setWidth()` | Use for responsive icon sizes and dynamic dimensions |
| `core/utils/helpers/ui/bottom_sheet_helper.dart` | Reusable bottom sheet display helper | `BottomSheetHelper.show(...)` | Display all modal sheets |
| `core/utils/helpers/ui/dialog_helper.dart` | Reusable dialog display helper | `DialogHelper.show(...)`, `DialogHelper.confirm(...)` | Display confirmation and alert dialogs |
| `core/utils/helpers/ui/status_delete_helper.dart` | Unified delete confirmation & execution | `StatusDeleteHelper.confirmAndDelete(...)` | Always invoke for status deletion flows |
| `core/utils/helpers/ui/toast_helper.dart` | Toast notification helper | `ToastHelper.show(...)` | Show non-blocking transient toasts |
| `core/utils/helpers/ui/snackbar_helper.dart` | Clean snackbar presentation helper | `SnackbarHelper.show(...)` | Show informative feedback snackbars |

### 5.2 Shared Widgets Catalog (`lib/shared/widgets/`)

| Directory | Available Components | Best Practice Usage |
|---|---|---|
| `appbars/` | `MyAppBar`, `MySliverAppBar` | Standard app bars and collapsing slivers. |
| `buttons/` | `MyButton`, `MyIconButton`, `WhatsAppTypeSwitch`, `MyFloatingButton`, `MyPopupMenu`, `MySegmentButton` | Use `WhatsAppTypeSwitch` for edition toggles; `MyButton` for actions. |
| `cards/` | `MyCard`, `MySectionCard` | Use `MyCard.filled` for containers; `MySectionCard` for grouped settings. |
| `chips/` | `MediaFilterBar`, `AnimatedChip` | Use `MediaFilterBar` for filtering by media type (`All`, `Images`, `Videos`, `Audio`). |
| `images/` | `ImageViewerPage`, `MyImage` | Use `MyImage` for cached and local assets. |
| `misc/` | `MyBottomNavigationBar`, `MyEmptyState`, `MyIcon`, `MyProgressIndicator`, `MyToast`, `MyDotIndicator` | Reusable UI feedback and navigation bar. |
| `sheets/` | `MyBottomSheet` | Wrap content inside `MyBottomSheet` before invoking `BottomSheetHelper.show`. |
| `tiles/` | `MyListTile`, `MyActionTile`, `MySwitchTile`, `MyRadioTile` | Use for all settings options, rows, and folder configurations. |
| `lists/` | `SelectableList`, `SelectableChipList` | Use for single or multiple selection dialogs and sheets. |

---

## 6. Current Project Organization

```text
lib/
├── core/                               # Foundational infrastructure
│   ├── constants/                      # AppAssets, AppConstants, AppDurations, AppIcons
│   ├── database/                       # Drift database (AppDatabase, SavedMediaTable)
│   ├── enums/                          # WhatsAppType, MediaType
│   ├── errors/                         # Domain Failures & Exception types
│   ├── l10n/                           # ARB files & generated AppLocalizations
│   ├── platform/                       # SafChannel contracts & constants
│   ├── routes/                         # AppRoutes, AppPages
│   ├── services/                       # CashService (SharedPreferences)
│   ├── theme/                          # MaterialTheme, LightTheme, DarkTheme
│   └── utils/                          # Extensions, validators, UI helpers
│
├── shared/                             # Shared presentation components
│   ├── controller/                     # Shared controllers (ImagePickerController)
│   └── widgets/                        # MyAppBar, MyBottomNavigationBar, MyCard, MyListTile, etc.
│
├── features/                           # Feature-first modules
│   ├── app_shell/                      # Main container with swipeable PageView & 3-tab navigation
│   │   ├── bindings/                   # AppShellBinding
│   │   ├── controller/                 # AppShellController (tab index & page synchronization)
│   │   └── view/                       # AppShellPage & _KeepAliveTab
│   │
│   ├── home/                           # WhatsApp Status Gallery
│   │   ├── data/
│   │   │   ├── datasources/            # SafNativeDataSource
│   │   │   ├── models/                 # StatusMediaModel
│   │   │   └── repositories/           # StatusRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/               # StatusMedia
│   │   │   ├── repositories/           # StatusRepository
│   │   │   └── usecases/               # GetStatusesUseCase, RequestSafAccessUseCase, etc.
│   │   └── presentation/
│   │       ├── bindings/               # HomeBinding
│   │       ├── controllers/            # HomeController
│   │       ├── pages/                  # HomePage
│   │       └── widgets/                # StatusGridItem, SafPermissionBanner
│   │
│   ├── saved/                          # Saved Media Gallery
│   │   ├── data/
│   │   │   ├── datasources/            # SavedMediaLocalDataSource (Drift)
│   │   │   ├── models/                 # SavedMediaModel
│   │   │   └── repositories/           # SavedMediaRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/               # SavedMedia
│   │   │   ├── repositories/           # SavedMediaRepository
│   │   │   └── usecases/               # GetSavedMediaUseCase, DeleteSavedMediaUseCase, SyncSavedMediaUseCase
│   │   └── presentation/
│   │       ├── bindings/               # SavedBinding
│   │       ├── controllers/            # SavedController
│   │       ├── pages/                  # SavedPage
│   │       └── widgets/                # SavedGridItem
│   │
│   ├── viewer/                         # Full-screen Media Viewers
│   │   ├── data/
│   │   │   └── models/                 # MediaViewerItem
│   │   └── presentation/
│   │       ├── controllers/            # MediaViewerController
│   │       ├── pages/                  # MediaViewerPage
│   │       └── widgets/                # ImageViewerContent, VideoViewerContent, AudioViewerContent,
│   │                                   # MediaViewerAppBar, MediaViewerFilmstrip
│   │
│   └── settings/                       # Settings & App Information
│       ├── controller/                 # SettingsController, LicensesController
│       ├── data/                       # LicensesService
│       └── view/                       # SettingsPage, AboutPage, LicensesPage
│           └── widgets/                # LicenseDetailsSheet
│
└── main.dart                           # App initialization & entrypoint
```

---

## 7. Android Platform & Storage Access Framework (SAF) Architecture

### 7.1 Understanding Modern Android Storage Constraints
Starting with Android 11 (API 30) through Android 15, Scoped Storage is strictly enforced. Direct filesystem access via raw `java.io.File` paths to external app sandboxes is blocked.
- Standard WhatsApp status location: `Android/media/com.whatsapp/WhatsApp/Media/.Statuses`
- WhatsApp Business status location: `Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses`
- `ACTION_OPEN_DOCUMENT_TREE` is the sole compliant mechanism to obtain user authorization.

### 7.2 Native Android SAF Architecture (Kotlin)
All native storage operations reside in `android/app/src/main/kotlin/com/luai0yk/halati/` under the `saf/` package (`SafHandler.kt`).

#### 1. Persisting Directory Permissions per Client
Native code persists granted tree URI permissions immediately via:
```kotlin
val takeFlags: Int = intent.flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
contentResolver.takePersistableUriPermission(treeUri, takeFlags)
```
Permissions are cached in `CashService` separately under `CashKeys.safTreeUri` (WhatsApp) and `CashKeys.safTreeUriBusiness` (WhatsApp Business).

#### 2. MethodChannel Specification: `com.luai0yk.halati/saf`

| Method Name | Arguments | Return Type | Description |
|---|---|---|---|
| `checkDirectoryAccess` | `{ uri: String? }` | `Map<String, Any>` (`granted`, `accessible`) | Verifies if persistable URI permission is active and directory exists. |
| `checkSaveFolderAccess` | `{ uri: String? }` | `Map<String, Any>` (`granted`, `accessible`) | Validates custom destination save folder permission. |
| `requestDirectorySelection` | `{ initialUriHint: String?, whatsappType: String? }` | `String?` (URI string) | Launches `ACTION_OPEN_DOCUMENT_TREE` with an initial folder hint. |
| `requestCustomSaveFolder` | `{ initialUriHint: String? }` | `Map<String, Any>?` (`uri`, `path`) | Launches directory picker for custom save location. |
| `releaseDirectoryAccess` | `{ uri: String }` | `Boolean` | Releases persisted URI permission. |
| `discoverStatuses` | `{ treeUri: String }` | `List<Map<String, Any>>` | Enumerate files using `DocumentsContract.buildChildDocumentsUriUsingTree`. |
| `getThumbnail` | `{ documentUri: String, width: Int, height: Int }` | `String?` (Disk cache path) | Generates thumbnail via `ThumbnailUtils` / `DocumentsContract` and caches on disk. |
| `getMediaMetadata` | `{ documentUri: String }` | `Map<String, Any>` | Extracts duration, dimensions, and MIME type via `MediaMetadataRetriever`. |
| `saveToMediaStore` | `{ documentUri: String, mediaType: String, fileName: String, customUri: String?, whatsappType: String? }` | `Map<String, Any>` | Copies SAF stream into structured gallery folder and triggers MediaScanner. |
| `getFullMediaFile` | `{ documentUri: String, fileName: String }` | `String?` (Cache file path) | Caches full file locally for robust playback or external sharing. |
| `deleteFromMediaStore` | `{ mediaStoreUri: String }` | `Boolean` | Deletes media file from Android storage and refreshes MediaStore. |
| `checkMissingFiles` | `{ mediaStoreUris: List<String> }` | `List<String>` | Reconciles missing files deleted outside the application. |

---

## 8. Media Pipeline & Unified Grid Specifications

### 8.1 Media Classification & WhatsApp Audio Handling
Discovered files are classified into three domain categories:

```dart
enum MediaType {
  image,
  video,
  audio,
}
```

1. **Images (`MediaType.image`)**: `.jpg`, `.jpeg`, `.png`, `.webp`.
2. **Videos (`MediaType.video`)**: `.mp4`, `.3gp`, `.mkv`.
3. **Audio / Voice Statuses (`MediaType.audio`)**:
   - Recorded as `.opus` (often inside OGG or MP4 containers), `.aac`, or `.m4a`.
   - Audio files lack video tracks; they bypass video decoding and use custom audio cards with waveform styling.

### 8.2 Unified 3-Column Grid Layout
The Home screen displays all media in a unified three-column responsive grid:
- `GridView.builder` with `crossAxisCount: 3`, `spacing: 6.0`.
- Strictly sorted newest first (`lastModified` descending).
- **Cards**:
  - **Image**: Cached thumbnail preview with smooth fade-in.
  - **Video**: Video thumbnail, center play badge (`AppIcons.video`), and bottom duration pill.
  - **Audio**: `MyCard.filled` with gradient theme styling, audio waveform icon (`AppIcons.music`), and duration pill.

### 8.3 High-Performance Thumbnail Generation & Caching Strategy
- Asynchronous metadata enumeration returning headers immediately.
- Disk-cached thumbnails in `context.cacheDir/status_thumbnails/<md5>.jpg`.
- Concurrency throttled to 3 parallel native workers.
- Rendered with `cacheWidth: 400` to prevent memory bloat.

---

## 9. Dedicated Media Viewer Specification (`features/viewer/`)

Tapping an item in the grid navigates to `MediaViewerPage`:
- **Unified Swiping**: Users swipe horizontally between statuses smoothly using `PageView.builder`.
- **Media Viewer Filmstrip (`MediaViewerFilmstrip`)**: Bottom thumbnail filmstrip showing neighboring statuses for rapid navigation.
- **Auto-Save on View**: When enabled in Settings (`autoSaveOpenedStatuses`), the controller silently saves the active status in the background upon display.
- **Media Content**:
  - **Image (`ImageViewerContent`)**: Interactive pinch-to-zoom and pan via `PhotoView`.
  - **Video (`VideoViewerContent`)**: Hardware-accelerated playback with play/pause overlay, seek bar, time indicator, and auto-hiding controls.
  - **Audio (`AudioViewerContent`)**: Visual waveform player with play/pause, seek scrubber, and elapsed/remaining timers.
- **Action Controls (`MediaViewerAppBar`)**:
  - Save to gallery (with saved indicator state).
  - Share status media (`ShareHelper.shareFile`).
  - Delete saved status (`StatusDeleteHelper.confirmAndDelete`).

---

## 10. Gallery Saving & Drift Persistence

### 10.1 Structured Save Directory Format
Media saved to the user's device is saved in organized directories:
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
If the user designates a custom folder via Settings, files are saved directly into that custom tree while retaining the subfolder structure.

### 10.2 Drift (SQLite) Persistence for Saved Media
The application tracks all saved records in `AppDatabase` (schema version 2):

```dart
class SavedMediaTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get originalDocumentUri => text()();
  TextColumn get mediaStoreUri => text()();
  TextColumn get relativePath => text()();
  TextColumn get fileName => text()();
  TextColumn get mediaType => text()(); // 'image', 'video', 'audio'
  TextColumn get mimeType => text()();
  IntColumn get fileSize => integer()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get savedAt => dateTime()();
  DateTimeColumn get sourceCreatedAt => dateTime()();
  TextColumn get whatsAppType => text().withDefault(const Constant('whatsapp'))();
}
```

### 10.3 Instant Media Scanning & Reconciliation
- Saved files trigger `MediaScannerConnection.scanFile` natively to ensure immediate appearance in Google Photos and third-party gallery apps.
- On loading the Saved tab, `checkMissingFiles` prunes any database records whose underlying physical files were deleted externally.

---

## 11. Persistent Navigation & Application UI

### 11.1 AppShell Architecture (`features/app_shell/`)
- `AppShellPage` coordinates a horizontal `PageView` synchronized with `MyBottomNavigationBar`.
- Tab transitions use animation locking (`isAnimating`) in `AppShellController` to prevent race conditions during rapid taps.
- Child tabs are wrapped in `_KeepAliveTab` (`AutomaticKeepAliveClientMixin`) to guarantee scroll positions and loaded media lists persist across tab switches.

### 11.2 Design System & Aesthetics
- **Material 3**: Leverage `MaterialTheme` (`core/theme/material_theme.dart`).
- **Colors**: Strictly use semantic theme roles (`context.colorScheme.surface`, `context.colorScheme.primary`, etc.). Never hardcode raw hex values or color literals.
- **Typography**: Strictly use `context.textTheme` with the bundled `NotoSansArabic` font family.
- **Icons**: Strictly use `AppIcons` from `core/constants/app_icons.dart`. Arrow icons (`AppIcons.arrowForward(context)`) are used only when needed for navigation or open actions.

---

## 12. Localization & RTL Guidelines

The application supports **English (`en`)** and **Arabic (`ar`)** out of the box using Flutter ARB toolchains configured in `l10n.yaml`:

- **Template ARB**: `lib/core/l10n/arb/app_en.arb`
- **Arabic ARB**: `lib/core/l10n/arb/app_ar.arb`
- **Generated Code**: `lib/core/l10n/app_localizations.dart`

### Key Terminology
- App Name: **Halati** (English) / **حالاتي** (Arabic).
- "About Halati" / "حول حالاتي"
- Dual WhatsApp labels: `whatsapp` ("WhatsApp" / "واتساب"), `whatsappBusiness` ("WhatsApp Business" / "واتساب للأعمال").
- Always use `EdgeInsetsDirectional`, `AlignmentDirectional`, and RTL-aware icons (`AppIcons.arrowBack(context)`).

---

## 13. Quality Standards & Testing Strategy

### 13.1 Code Quality Commandments
- **100% Sound Null Safety**: Never use force-unwrap `!` without an explicit preceding null check.
- **Immutability**: Domain entities must be immutable (`@immutable` with `const` constructors).
- **No Direct Platform Access**: Views and controllers must never invoke `MethodChannel` directly. Platform channels belong exclusively inside Data Sources.
- **Analysis Compliance**: All code must pass `flutter analyze` with zero errors and zero warnings.

### 13.2 Testing Layers
- **Unit Tests (`test/unit/`)**: Test Use Cases, Controller logic, Drift persistence, and data models.
- **Widget Tests (`test/widget/`)**: Verify widget trees and user interactions.
- Run tests via `flutter test`.

---

## 14. Mandatory Agent Operating Instructions (Rules of Engagement)

Every AI coding agent operating on this repository must abide by the following directives:

1. **Read `AGENT.md` First**: Always consult this document before initiating any architectural change or creating new files.
2. **Reuse Existing Resources**: Never create redundant widgets, app bars, cards, icon constants, dialog helpers, or preference services when an existing component in `core/` or `shared/` can be reused.
3. **Keep Views Free of Logic**: Never place `MethodChannel` invocations, database calls, or complex business logic inside Flutter widgets or views.
4. **Order Widget Props Consistently**:
   1. Identifiers / Keys
   2. Leading widgets / Icons (`leadingIcon`)
   3. Titles and labels (`title`, `labelText`, `hintText`)
   4. Subtitles & directionality (`subtitle`, `subtitleDirection`)
   5. Trailing widgets / arrow icons (`trailing`, `trailingIcon`)
   6. Styling / layout (`borderRadius`, `maxLines`, `padding`, `color`)
   7. Event handlers / callbacks (`onTap`, `onPressed`, `onChanged`)
5. **Arrow Icon Usage in List Tiles**: Use forward chevron arrows (`AppIcons.arrowForward(context)`) **only when needed** (for navigation, external links, or picker dialogs); omit them for value displays, toggle switches, or direct actions.
6. **No Scope Creep**: Implement only the explicitly requested feature or refactoring.
7. **Verify Analysis and Tests**: After every modification, run static analysis and tests to ensure the codebase remains clean and regression-free:
   ```bash
   flutter analyze
   flutter test
   ```
8. **Document Architectural Shifts**: If a new product decision or technical constraint alters an invariant, update `AGENT.md` immediately to reflect the revised source of truth.
