# AGENT.md — WhatsApp Status Saver: Engineering Architecture & Development Guide

> **Authoritative Development Manual & Source of Truth**  
> **Target Audience:** AI Coding Agents & Senior Flutter Engineers  
> **Repository:** `luai0yk/status-saver`  
> **Platform Target:** Android Exclusively (API 24+ / targetSdk 34+)  
> **Framework & State Management:** Flutter 3.11+ / GetX 4.7+ / Clean Architecture

---

## 1. Executive Summary & Purpose

This document serves as the permanent architectural guide, code standard, and operational directive for all AI coding agents working on the **WhatsApp Status Saver** application. Every future task, feature implementation, refactoring, or bug fix must strictly comply with the patterns, contracts, directory structures, and constraints documented herein.

The application is a focused, high-performance, lightweight Flutter client designed to browse, preview, share, and save locally cached WhatsApp status media (images, videos, and audio notes) on Android devices.

---

## 2. Confirmed Product Invariants & Non-Negotiable Decisions

Before planning or executing any changes, verify compliance with these confirmed product invariants:

1. **Android Only**: All status discovery, storage access, media viewing, and gallery saving are engineered exclusively for Android. iOS does not allow local filesystem access to other apps' sandbox containers; iOS status access is permanently unsupported.
2. **Standard WhatsApp Only**: The application targets exclusively the official WhatsApp package (`com.whatsapp`). WhatsApp Business (`com.whatsapp.w4b`), GBWhatsApp, or any unofficial clones are out of scope.
3. **Android Storage Access Framework (SAF) Exclusively**:
   - Access to WhatsApp status files is achieved solely via user-granted directory tree permissions using `Intent.ACTION_OPEN_DOCUMENT_TREE`.
   - Never request or use `MANAGE_EXTERNAL_STORAGE` (`android.permission.MANAGE_EXTERNAL_STORAGE`).
   - Never rely on raw `File('/storage/emulated/0/...')` paths for WhatsApp media on modern Android. SAF document URIs (`content://...`) are the sole currency of media exchange.
4. **Unified Three-Column Media Grid**:
   - Discovered statuses (images, videos, and audio) must appear in a unified, three-column responsive grid sorted strictly **newest first** (`lastModified` descending).
   - Clear visual differentiation:
     - **Images**: Crisp thumbnail preview.
     - **Videos**: Center-aligned translucent play badge (`AppIcons.video` / play icon) + bottom duration pill.
     - **Audio**: Custom audio card/waveform graphic with headphone/music indicator (`AppIcons.music` / audio icon) + bottom duration pill.
5. **Three Persistent Navigation Destinations**:
   - **Home**: Unified status grid, permission banner, sync status, and refresh capability.
   - **Saved**: Drift-backed persistent gallery of saved media, filterable by type.
   - **Settings**: Theme selection (System, Light, Dark), language switcher (English, Arabic), SAF folder configuration, and application info.
6. **Bilingual Support & Full RTL Compliance**:
   - Supported languages: **English (`en`)** and **Arabic (`ar`)**.
   - Bidirectional UI must be strictly enforced using direction-aware styling, localized strings via ARB, and RTL-safe icons (`AppIcons.arrowBack(context)`).
7. **No Automatic Background Saving or Polling**:
   - The initial version relies strictly on user-initiated refresh or foreground view activation. No background services, WorkManager periodic tasks, or alarm managers.

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
- **Entities**: Pure Dart classes modeling business domain concepts (e.g., `StatusMedia`, `SavedMediaRecord`). Must have **zero dependencies** on Flutter, GetX, Android APIs, or external UI/storage libraries. Models are immutable (`@immutable` with `const` constructors).
- **Repository Contracts**: Abstract interfaces specifying what data operations exist (e.g., `StatusRepository`, `SavedMediaRepository`), returning typed `Future<Result<T, Failure>>` or `Stream<T>`.
- **Use Cases**: Single-responsibility classes implementing specific application business logic (e.g., `GetDiscoveredStatusesUseCase`, `SaveStatusToGalleryUseCase`, `CheckSafAccessUseCase`).

#### Data Layer (`features/<feature>/data/`)
- **Models**: Data transfer representations extending domain entities or providing serialization (`fromJson`, `toJson`, `fromSafMap`, `toDriftCompanion`).
- **Data Sources**:
  - `SafNativeDataSource`: MethodChannel bridge handling native Android SAF calls (`checkAccess`, `requestDirectory`, `listStatuses`, `saveMedia`).
  - `SavedMediaLocalDataSource`: Drift/SQLite database operations for persistent records.
  - `SafThumbnailDataSource`: Disk-cached thumbnail retrieval and native extraction.
- **Repositories (Implementations)**: Concrete implementations of domain repository interfaces. Catches raw platform exceptions and maps them into strongly typed domain `Failure` instances.

#### Presentation Layer (`features/<feature>/presentation/` or existing `view/` / `controller/`)
- **Pages & Widgets**: Pure UI. Must **never** execute database queries, invoke platform channels directly, decode files, or hold business logic.
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
- `SafFolderInvalidFailure`: Selected folder is not the WhatsApp `.Statuses` folder.
- `SafAccessRevokedFailure`: Stored SAF Uri permission was revoked or expired.
- `MediaReadFailure`: Failed to read bytes or metadata from SAF document URI.
- `ThumbnailGenerationFailure`: Native Android failure creating preview thumbnail.
- `MediaStoreSaveFailure`: Failed to write media into Android MediaStore.
- `DatabaseFailure`: SQLite / Drift persistence failure.

---

## 4. State Management with GetX: Strict Guidelines

GetX is mandatory throughout the application. Agents must adhere to the following rules:

### 4.1 Reactive Variables & Controllers
- Use specific reactive primitives: `final RxList<StatusMedia> statuses = <StatusMedia>[].obs;`, `final RxBool isLoading = false.obs;`, `final Rxn<String> error = Rxn<String>();`.
- In views, wrap **only the minimal widget** requiring updates in `Obx(() => ...)`. Never wrap an entire `Scaffold` or `ListView` in `Obx` if only a small child icon or badge is reactive.
- Use `GetBuilder` with unique IDs (e.g., `update(['status_grid'])`) when discrete, batch updates are preferable over continuous reactive streams (as demonstrated in `SettingsController`).

### 4.2 Dependency Injection via Bindings
- All controllers, use cases, and repositories must be bound using `Bindings` and loaded with `GetPage(..., binding: HomeBinding())`.
- Global services (such as `CashService` and `SettingsController`) are registered permanently in `main.dart` with `permanent: true`.
- Never instantiate controllers inside `build()` methods or use `Get.put()` inside stateless/stateful widget builds.

### 4.3 Navigation
- Use named routes defined in `AppRoutes` and registered in `AppPages`.
- Perform route transitions via `Get.toNamed(AppRoutes.viewer, arguments: media)`.
- Use `AppNavigator.key` and existing UI helpers (`BottomSheetHelper`, `DialogHelper`, `SnackbarHelper`, `ToastHelper`) for modal overlays.

---

## 5. Mandatory Reuse of Existing Codebase Assets

The repository already contains a rich, polished set of foundational utilities, themes, services, and shared widgets. **AI agents are strictly forbidden from creating redundant, duplicate implementations.**

Before writing any new component, inspect this catalog:

### 5.1 Core Infrastructure (`lib/core/`)

| Path / File | Purpose | Key Symbols / Classes | Usage Instruction |
|---|---|---|---|
| `core/constants/app_icons.dart` | Unified Iconsax-based icon dictionary with RTL awareness | `AppIcons.home`, `AppIcons.arrowBack(context)`, `AppIcons.video`, `AppIcons.refresh`, `AppIcons.share`, `AppIcons.delete`, `AppIcons.add` | Always use `AppIcons` instead of `Icons.*` |
| `core/constants/app_constants.dart` | Global constants & typography configuration | `AppConstants.fontFamily` (`NotoSansArabic`), input max lengths | Use for typography and global length constants |
| `core/constants/app_durations.dart` | Animation duration tokens | `AppDurations.fast`, `AppDurations.medium`, `AppDurations.slow` | Use for transitions, animations, and dialogs |
| `core/constants/app_assets.dart` | Static image and SVG asset references | `AppAssets` | Add any local image asset paths here |
| `core/services/cash/cash_service.dart` | Centralized `SharedPreferences` GetX service | `CashService`, `contains()`, `getString()`, `setString()`, `getModel()` | Inject via `Get.find<CashService>()` for lightweight storage |
| `core/services/cash/cash_keys.dart` | Key constants for `CashService` | `CashKeys.themeMode`, `CashKeys.languageCode`, `CashKeys.safTreeUri` | Add all persistent preference keys here |
| `core/theme/material_theme.dart` | Theme generator with responsive typography | `MaterialTheme`, `responsiveTextTheme(context)`, `light()`, `dark()` | Standard theme definition |
| `core/theme/extended_colors.dart` | Extended color system tokens | `ExtendedColors` | Access specialized theme color roles |
| `core/utils/extensions/context_extension.dart` | Context shortcuts for colors, text, and localization | `context.colorScheme`, `context.textTheme`, `context.l10n`, `context.isDark` | Use in every widget for clean theme access |
| `core/utils/extensions/responsive_values.dart` | Standardized padding, radius, and spacing tokens | `context.insetsAllM`, `context.spaceS`, `context.spaceM`, `context.radiusL` | Use for layout margins, insets, and spacings |
| `core/utils/extensions/responsive_size.dart` | Responsive dimension scaling | `context.setSize()`, `context.setWidth()` | Use for responsive icon sizes and dynamic widths |
| `core/utils/helpers/ui/app_navigator.dart` | Global navigation key & context-free access | `AppNavigator.key`, `AppNavigator.context` | Use when context is unavailable in controllers |
| `core/utils/helpers/ui/bottom_sheet_helper.dart` | Reusable bottom sheet display helper | `BottomSheetHelper.show(...)` | Display all modal sheets through this helper |
| `core/utils/helpers/ui/dialog_helper.dart` | Reusable dialog display helper | `DialogHelper.show(...)`, `DialogHelper.confirm(...)` | Display all confirmation and alert dialogs |
| `core/utils/helpers/ui/snackbar_helper.dart` | Clean snackbar presentation helper | `SnackbarHelper.show(...)` | Show informative feedback snackbars |
| `core/utils/helpers/ui/toast_helper.dart` | Toast notification helper | `ToastHelper.show(...)` | Show non-blocking transient toasts |
| `core/utils/helpers/misc/settings_helper.dart` | Settings and locale translation helpers | `SettingsHelper.currentTheme`, `SettingsHelper.currentLocale` | Query active theme and locale |
| `core/utils/helpers/misc/share_helper.dart` | Wrapper around `share_plus` | `ShareHelper.shareFile(...)`, `ShareHelper.shareText(...)` | Use for sharing status images and videos |

### 5.2 Shared Widgets Catalog (`lib/shared/widgets/`)

| Directory | Available Components | Best Practice Usage |
|---|---|---|
| `appbars/` | `MyAppBar`, `MySliverAppBar` | Use `MyAppBar` for standard screens; `MySliverAppBar` for collapsing headers. |
| `buttons/` | `MyButton`, `MyIconButton`, `MyFavoriteButton`, `MyFloatingButton`, `MyPopupMenu`, `MySegmentButton` | Use `MyButton` for primary/secondary actions; `MyIconButton` for appbar icons. |
| `cards/` | `MyCard`, `MySectionCard` | Use `MyCard.filled` / `MyCard.outlined` for container styling; `MySectionCard` for grouped lists. |
| `images/` | `ImageViewerPage`, `MyImage` | **Reuse `ImageViewerPage`** for full-screen photo viewing with zoom (`photo_view`). Use `MyImage` for cached and asset rendering. |
| `misc/` | `MyBottomNavigationBar`, `MyEmptyState`, `MyIcon`, `MyProgressIndicator`, `MySnackbar`, `MyToast`, `MyDotIndicator` | Use `MyBottomNavigationBar` for bottom navigation; `MyEmptyState` for empty status or permission screens; `MyProgressIndicator` for spinners. |
| `dialogs/` | `MyDialog`, `MyProgressDialog` | Use `MyDialog` for custom modal layouts. |
| `sheets/` | `MyBottomSheet` | Wrap content inside `MyBottomSheet` before invoking `BottomSheetHelper.show`. |
| `tiles/` | `MyListTile`, `MyActionTile`, `MySwitchTile`, `MyRadioTile`, `MyExpansionTile` | Use for all settings options, media info rows, and interactive rows. |
| `lists/` | `SelectableList`, `SelectableChipList` | Use for single or multiple selection dialogs and filtering chips. |
| `animations/` | `MyAnimatedVisibility`, `MyAnimatedFadeSwitcher`, `MyAnimatedScaleSwitcher` | Use for micro-animations and smooth state switches. |

---

## 6. Target Project Organization

The repository shall transition smoothly from its initial state to the target Clean Architecture structure without breaking existing routes or configuration:

```text
lib/
├── core/                               # Existing foundational infrastructure
│   ├── constants/                      # AppAssets, AppConstants, AppDurations, AppIcons
│   ├── database/                       # Drift database definitions & tables (New)
│   ├── errors/                         # Domain Failures & Exception types (New)
│   ├── l10n/                           # ARB, AppLocales, AppLocaleConfig, AppLocalizations
│   ├── platform/                       # Platform channel contracts & constants (New)
│   ├── routes/                         # AppRoutes, AppPages
│   ├── services/                       # CashService (SharedPreferences)
│   ├── theme/                          # MaterialTheme, LightTheme, DarkTheme
│   └── utils/                          # Extensions, helpers (UI, misc)
│
├── shared/                             # Existing shared presentation components
│   ├── controller/                     # Shared controllers (ImagePicker, SegmentButton)
│   └── widgets/                        # MyAppBar, MyBottomNavigationBar, ImageViewerPage, etc.
│
├── features/                           # Feature-first modules
│   ├── app_shell/                      # Main container with persistent 3-tab navigation
│   │   ├── bindings/                   # AppShellBinding
│   │   ├── controller/                 # AppShellController (tab index & state)
│   │   └── view/                       # AppShellPage (replaces demo UI with persistent shell)
│   │
│   ├── home/                           # WhatsApp Status Gallery
│   │   ├── data/
│   │   │   ├── datasources/            # SafNativeDataSource, SafThumbnailDataSource
│   │   │   ├── models/                 # StatusMediaModel
│   │   │   └── repositories/           # StatusRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/               # StatusMedia (Image, Video, Audio)
│   │   │   ├── repositories/           # StatusRepository
│   │   │   └── usecases/               # GetStatusesUseCase, RequestSafPermissionUseCase
│   │   └── presentation/
│   │       ├── bindings/               # HomeBinding
│   │       ├── controllers/            # HomeController
│   │       ├── pages/                  # HomePage
│   │       └── widgets/                # StatusGridItem, AudioStatusCard, VideoBadge, SafPermissionBanner
│   │
│   ├── saved/                          # Saved Media Gallery
│   │   ├── data/
│   │   │   ├── datasources/            # SavedMediaLocalDataSource (Drift)
│   │   │   ├── models/                 # SavedMediaModel
│   │   │   └── repositories/           # SavedMediaRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/               # SavedMediaRecord
│   │   │   ├── repositories/           # SavedMediaRepository
│   │   │   └── usecases/               # GetSavedMediaUseCase, DeleteSavedMediaUseCase
│   │   └── presentation/
│   │       ├── bindings/               # SavedBinding
│   │       ├── controllers/            # SavedController
│   │       ├── pages/                  # SavedPage
│   │       └── widgets/                # SavedGridItem, SavedFilterChips
│   │
│   ├── viewer/                         # Full-screen Media Viewers
│   │   ├── presentation/
│   │   │   ├── bindings/               # ViewerBinding
│   │   │   ├── controllers/            # ImageViewerController, VideoViewerController, AudioViewerController
│   │   │   ├── pages/                  # StatusImageViewerPage, StatusVideoViewerPage, StatusAudioViewerPage
│   │   │   └── widgets/                # VideoControlsOverlay, AudioWaveformVisualizer, ViewerActionBar
│   │
│   └── settings/                       # Existing Settings module (retained & extended)
│       ├── controller/                 # SettingsController
│       └── view/                       # SettingsPage
│
└── main.dart                           # App initialization & entrypoint
```

---

## 7. Android Platform & Storage Access Framework (SAF) Architecture

### 7.1 Understanding Modern Android Storage Constraints
Starting with Android 11 (API 30) and continuing through Android 14/15, Android enforces Scoped Storage. Direct filesystem access to WhatsApp's media folders via raw `java.io.File` paths is strictly blocked. Furthermore:
- Standard WhatsApp status location on Android 11+:  
  `Android/media/com.whatsapp/WhatsApp/Media/.Statuses`
- Legacy location on Android 10 and below:  
  `WhatsApp/Media/.Statuses`
- `ACTION_OPEN_DOCUMENT_TREE` is the official, compliant Android mechanism to obtain user authorization to read files from this folder.

### 7.2 Native Android SAF Architecture (Kotlin)
All native storage operations reside in `android/app/src/main/kotlin/com/luai0yk/status_saver/` under a dedicated `saf/` package.

#### 1. Persisting Directory Permissions
When the user grants folder access through `ACTION_OPEN_DOCUMENT_TREE`, the native activity must take persistable URI permissions immediately:
```kotlin
val takeFlags: Int = intent.flags and (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
contentResolver.takePersistableUriPermission(treeUri, takeFlags)
```
The tree URI string (e.g., `content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2F.Statuses`) is returned to Flutter and cached in `CashService` under `CashKeys.safTreeUri`.

#### 2. Directory Validation
Before accepting a user-selected folder, the native layer must validate:
- Is the selected document tree path pointing to WhatsApp statuses?
- Does it contain or correspond to `.Statuses`?
- If the user selected the root storage or an unrelated directory, reject it with an explanatory error code: `INVALID_DIRECTORY_SELECTED`.

#### 3. MethodChannel Specification: `com.luai0yk.status_saver/saf`

| Method Name | Arguments | Return Type | Description |
|---|---|---|---|
| `checkDirectoryAccess` | `{ uri: String? }` | `Map<String, Any>` (`granted: Boolean`, `accessible: Boolean`) | Verifies if persistable URI permission is active and directory exists. |
| `requestDirectorySelection` | `{ initialUriHint: String? }` | `String?` (URI string) | Launches `ACTION_OPEN_DOCUMENT_TREE` with an initial folder hint. |
| `releaseDirectoryAccess` | `{ uri: String }` | `Boolean` | Releases persisted URI permission. |
| `discoverStatuses` | `{ treeUri: String }` | `List<Map<String, Any>>` | Queries `DocumentsContract.buildChildDocumentsUriUsingTree` to enumerate files. |
| `getThumbnail` | `{ documentUri: String, width: Int, height: Int }` | `String?` (Absolute disk cache file path) | Generates thumbnail via Android `ThumbnailUtils` / `DocumentsContract.getDocumentThumbnail` and caches it on disk. |
| `getMediaMetadata` | `{ documentUri: String }` | `Map<String, Any>` (`durationMs: Long`, `width: Int`, `height: Int`, `mimeType: String`) | Extracts duration and resolution via `MediaMetadataRetriever`. |
| `saveToMediaStore` | `{ documentUri: String, mediaType: String, fileName: String }` | `Map<String, Any>` (`savedUri: String`, `relativePath: String`) | Copies SAF stream into Android MediaStore (`Pictures/StatusSaver`, `Movies/StatusSaver`, or `Music/StatusSaver`). |

#### 4. Offloading to Dispatchers.IO
All native file listing, thumbnail decoding, metadata extraction, and stream copying must run inside Kotlin Coroutines on `Dispatchers.IO` to ensure the Flutter UI thread never stutters.

---

## 8. Media Pipeline & Unified Grid Specifications

### 8.1 Media Classification & WhatsApp Audio Handling

Discovered files must be classified into three distinct domain categories based on MIME type and file extension:

```dart
enum MediaType {
  image,
  video,
  audio,
}
```

1. **Images (`MediaType.image`)**:
   - MIME: `image/jpeg`, `image/png`, `image/webp`.
   - Extensions: `.jpg`, `.jpeg`, `.png`, `.webp`.
2. **Videos (`MediaType.video`)**:
   - MIME: `video/mp4`, `video/3gp`, `video/mkv`.
   - Extensions: `.mp4`, `.3gp`.
3. **Audio / Voice Statuses (`MediaType.audio`)**:
   - **Crucial Technical Nuance**: WhatsApp voice statuses are recorded and stored as `.opus` audio files (often inside an OGG or MP4 container) or `.aac` / `.m4a`.
   - MIME types encountered: `audio/ogg; codecs=opus`, `audio/opus`, `audio/aac`, `audio/mp4`, `audio/amr`.
   - Audio files lack visual video tracks; attempting to decode them as video crashes standard video decoders.
   - Files classified as `MediaType.audio` must bypass video thumbnail generation and use the audio visual treatment.

### 8.2 Unified 3-Column Grid Layout
The Home screen displays all media in a unified three-column grid:
- Grid layout: `GridView.builder` with `SliverGridDelegateWithFixedCrossAxisCount`:
  - `crossAxisCount: 3`
  - `crossAxisSpacing: 6.0`
  - `mainAxisSpacing: 6.0`
  - `childAspectRatio: 1.0` (square cells) or `4 / 5` (modern card aspect).
- **Sort Order**: Strictly newest first based on `lastModified` timestamp descending.

#### Visual Card Treatments
- **Image Item**:
  - Displays thumbnail image cached on disk.
  - Smooth fade-in on load (`MyAnimatedFadeSwitcher`).
- **Video Item**:
  - Displays video thumbnail.
  - Centered semi-transparent dark circle (`50%` opacity) with white play icon (`AppIcons.video`).
  - Bottom-right corner duration pill (e.g., `0:15`) in semi-transparent black.
- **Audio Item**:
  - Does not attempt image thumbnail decoding.
  - Renders a styled theme card: `MyCard.filled` with subtle gradient or theme color tint (`context.colorScheme.surfaceContainerHigh`).
  - Centered music / audio wave icon (`AppIcons.music` or custom waveform illustration).
  - Bottom duration pill (e.g., `0:28`).

### 8.3 High-Performance Thumbnail Generation & Caching Strategy
Loading full-resolution photos or videos directly into grid cells will cause severe memory bloat and frame drops.
1. **Asynchronous Generation**: When `discoverStatuses` runs, return document URIs, file names, sizes, and timestamps immediately without waiting for thumbnails.
2. **Disk-Cached Thumbnails**:
   - The native layer creates a private cache folder: `context.cacheDir.resolve("status_thumbnails")`.
   - For an item at `documentUri`, calculate a stable MD5 hash of the URI string as the cache file name: `<md5>.jpg`.
   - If `<md5>.jpg` already exists on disk, return its path immediately.
   - If not, decode a scaled thumbnail (max dimension 400px), compress to JPEG (`80%` quality), save to disk, and return the path.
3. **Concurrency Throttling**:
   - Limit concurrent native thumbnail generation workers to **3 parallel threads** to prevent memory pressure when fast-scrolling.
4. **Flutter Presentation**:
   - Use `Image.file(File(cachedPath), cacheWidth: 400, fit: BoxFit.cover)` with error handling fallback (`AppIcons.imageNotSupported`).

---

## 9. Dedicated Media Viewers Specification

When a user taps an item in the unified grid, navigate to the dedicated viewer based on `MediaType`:

### 9.1 Image Viewer
- **Reuse and Extend Existing Component**: Integrate `ImageViewerPage` (`lib/shared/widgets/images/image_viewer_page.dart`), which is already built with `photo_view`.
- **Features**:
  - Full-screen pinch-to-zoom and pan.
  - Immersive system overlay toggle on tap (hide/show app bars).
  - Top app bar with back button (`AppIcons.arrowBack(context)`), status timestamp, and file size.
  - Bottom action bar:
    - **Save to Gallery** (`MyButton` with `AppIcons.add` / download icon).
    - **Share** (`MyIconButton` with `AppIcons.share`, calling `ShareHelper.shareFile`).
    - **Delete / Dismiss**.

### 9.2 Video Viewer
- **Technology**: `video_player` (ExoPlayer under the hood on Android).
- **SAF Streaming Support**:
  - ExoPlayer natively supports playing SAF `content://` URIs directly.
  - Pass the SAF document URI string directly to `VideoPlayerController.contentUri(Uri.parse(documentUri))`.
- **Features & UI Controls**:
  - Fullscreen video playback with aspect ratio preservation.
  - Play/pause toggle overlay with smooth fade animation.
  - Scrubber progress bar with buffered range and current/total duration (`mm:ss`).
  - Mute/unmute toggle.
  - Auto-hide controls after 3 seconds of inactivity.
- **Strict Lifecycle Management**:
  - Initialize the controller inside `VideoViewerController.onInit()`.
  - Pause and call `controller.dispose()` inside `VideoViewerController.onClose()`. Never leak video decoders or audio focus.

### 9.3 Audio Viewer
- **Technology**: Dedicated Flutter audio playback package (e.g., `audioplayers` or `just_audio`).
- **SAF Audio Playback**:
  - Stream audio directly via `content://` URI or via a temporary cached file bridge if the codec requires seekable random access.
- **Visual Design**:
  - Clean, dedicated audio listening screen.
  - Centerpiece: Large rotating disc animation, glowing sound wave icon, or dynamic waveform visualizer.
  - Metadata display: Date and time posted, file format (`Opus / OGG Audio`), duration.
  - Interactive playback controls: Play/pause button (`MyIconButton` with large size), 5-second rewind and forward buttons, seek slider with elapsed/remaining time.
- **Lifecycle**:
  - Ensure the player stops immediately when navigating away or switching tabs.

---

## 10. Gallery Saving & MediaStore Architecture

### 10.1 Scoped Storage Gallery Saving (Android MediaStore)
Saving media to the user's public gallery must use the Android MediaStore API, ensuring compatibility across Android 10, 11, 12, 13, 14, and 15 without requesting broad storage permissions.

#### MediaStore Target Collections

| Media Type | MediaStore Collection | Destination Directory | MIME Type |
|---|---|---|---|
| Image | `MediaStore.Images.Media.EXTERNAL_CONTENT_URI` | `Pictures/StatusSaver` | `image/jpeg` or source MIME |
| Video | `MediaStore.Video.Media.EXTERNAL_CONTENT_URI` | `Movies/StatusSaver` | `video/mp4` |
| Audio | `MediaStore.Audio.Media.EXTERNAL_CONTENT_URI` | `Music/StatusSaver` | `audio/ogg` or `audio/opus` |

#### Two-Phase Insertion Pattern
To prevent corrupted or zero-byte files appearing in the gallery if an operation is interrupted:
1. Insert a new record into `ContentResolver` with `IS_PENDING = 1`.
2. Open native input stream from the source SAF `documentUri` and output stream to the new MediaStore URI.
3. Copy bytes in chunks (64 KB buffer).
4. On complete copy, update the MediaStore record: `IS_PENDING = 0`.
5. If copying fails or throws `IOException`, delete the pending URI immediately and clean up.

### 10.2 Drift (SQLite) Persistence for Saved Media
The application must track all saved media in a local **Drift** SQLite database.

#### Drift Table Definition: `SavedMediaTable`
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
}
```

#### Reconciling Saved Media
- When the **Saved** tab is opened, read the reactive stream from Drift.
- Perform a light background reconciliation: check if the `mediaStoreUri` still exists via `ContentResolver.openFileDescriptor(uri, "r")`. If the user deleted the media from Google Photos or gallery, prune or flag the record in Drift.

---

## 11. Persistent Navigation & Application UI

### 11.1 Shell Architecture (`features/app_shell/`)
The main interface consists of `MyBottomNavigationBar` hosting three persistent destinations:
1. **Home (`index 0`)**: Status grid, SAF permission request card, sync status, pull-to-refresh.
2. **Saved (`index 1`)**: Saved media grid, filter chips (All, Images, Videos, Audio), multi-select share/delete.
3. **Settings (`index 2`)**: Theme picker, language selector, SAF folder re-selection/validation, app information.

#### Preserving Navigation State
Use `IndexedStack` or a `PageView` with `NeverScrollableScrollPhysics` coupled with `AutomaticKeepAliveClientMixin` on child pages to guarantee scroll positions and loaded media lists are not destroyed when switching tabs.

### 11.2 Design System & Aesthetics
- **Material 3 Foundation**: Leverage the existing `MaterialTheme` (`lib/core/theme/material_theme.dart`).
- **Colors**: Never hardcode colors (`Colors.white`, `Colors.black`, `Colors.grey`). Always use `context.colorScheme.surface`, `context.colorScheme.onSurface`, `context.colorScheme.primary`, etc.
- **Typography**: Strictly use `context.textTheme` with the bundled `NotoSansArabic` font family.
- **Spacing**: Use `context.spaceS`, `context.spaceM`, `context.spaceL`, and `context.insetsAllM` from `responsive_values.dart`.
- **Icons**: Strictly use `AppIcons` from `core/constants/app_icons.dart`.

---

## 12. Localization & RTL Guidelines

The application supports **English (`en`)** and **Arabic (`ar`)** out of the box using Flutter's standard ARB toolchain configured in `l10n.yaml`:

```yaml
arb-dir: lib/core/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/core/l10n
```

### 12.1 Adding New Strings
Every new UI string must be added to both `lib/core/l10n/arb/app_en.arb` and `lib/core/l10n/arb/app_ar.arb`.

#### Required Keys for Status Saver
- `statuses`: "Statuses" / "الحالات"
- `saved`: "Saved" / "المحفوظات"
- `images`: "Images" / "الصور"
- `videos`: "Videos" / "الفيديوهات"
- `audio`: "Audio" / "الصوتيات"
- `grantPermission`: "Grant Permission" / "منح الإذن"
- `safPermissionTitle`: "WhatsApp Status Folder Access" / "الوصول إلى مجلد حالات واتساب"
- `safPermissionExplanation`: "To view and save WhatsApp statuses, please select the WhatsApp Statuses folder." / "لعرض وحفظ حالات واتساب، يرجى اختيار مجلد حالات واتساب."
- `selectFolder`: "Select Folder" / "اختيار المجلد"
- `savedSuccessfully`: "Saved to Gallery" / "تم الحفظ في المعرض"
- `saveFailed`: "Failed to save media" / "فشل حفظ الوسائط"
- `noStatusesFound`: "No statuses available" / "لا توجد حالات متاحة"
- `noStatusesSubtitle`: "View statuses in WhatsApp first to make them appear here." / "شاهد الحالات في واتساب أولاً لتظهر هنا."
- `noSavedMedia`: "No saved media yet" / "لا توجد وسائط محفوظة بعد"
- `share`: "Share" / "مشاركة"
- `save`: "Save" / "حفظ"
- `delete`: "Delete" / "حذف"

### 12.2 RTL Rules
- Use `AppIcons.arrowBack(context)` and `AppIcons.arrowForward(context)` for navigational arrows.
- Use `EdgeInsetsDirectional` instead of `EdgeInsets.only(left: ..., right: ...)`.
- Use `AlignmentDirectional` instead of `Alignment.centerLeft` / `Alignment.centerRight`.

---

## 13. Performance, Memory & Resource Management

WhatsApp status folders may contain hundreds of high-resolution images and long video files. Strictly enforce these performance safeguards:

1. **Virtualization**: Always use `GridView.builder` and `ListView.builder`. Never use non-builder collections for media lists.
2. **Decoupled Discovery from Decoding**: Media discovery must read only directory entry headers (`documentUri`, `name`, `size`, `lastModified`). Never read bytes or decode bitmaps during discovery.
3. **Strict Thumbnail Decoding Limits**: Set `cacheWidth: 400` on thumbnail `Image` widgets to ensure the Flutter engine allocates only a small memory buffer per grid tile.
4. **No Player Instantiation in Grids**: Under no circumstances should an instance of `VideoPlayerController` or audio player be initialized inside a grid cell item. Players belong strictly in dedicated full-screen viewers.
5. **Immediate Player Disposal**: When navigating away from a video or audio viewer, controllers must be paused, stopped, and disposed immediately.
6. **Scoped Reactivity**: Keep `Obx` widgets tightly scoped to small text/icon widgets. Do not trigger full grid rebuilds when an individual item's save status changes.

---

## 14. Quality Standards & Testing Strategy

### 14.1 Code Quality Commandments
- **Null Safety**: 100% sound null safety. Never use the force-unwrap operator `!` unless guarded by an explicit null check in the preceding statement.
- **Immutability**: Domain entities and state classes must be immutable (`@immutable`).
- **No Direct Platform Access**: Views and controllers must never invoke `MethodChannel` directly. Platform channels live exclusively inside Data Sources.
- **Analysis Compliance**: All code must pass `flutter analyze` with zero errors and zero warnings according to `analysis_options.yaml`.

### 14.2 Testing Layers
1. **Unit Tests (`test/unit/`)**:
   - Test Use Cases by mocking Domain Repositories with mockito / mocktail.
   - Test Data Source mapping logic (e.g., parsing native SAF maps into `StatusMediaModel`).
2. **Widget Tests (`test/widget/`)**:
   - Test UI components with mocked GetX controllers.
   - Use test harnesses that initialize `CashService` with `SharedPreferences.setMockInitialValues({})` (as established in `test/widget_test.dart`).
3. **Platform Channel Mocking**:
   - In Flutter unit and widget tests, intercept native calls:
     ```dart
     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
         .setMockMethodCallHandler(channel, (MethodCall methodCall) async { ... });
     ```

---

## 15. Phased Implementation Roadmap & Milestones

Future agents must execute work strictly along these sequential milestones. Each milestone has clear acceptance criteria that must be verified before proceeding:

### Phase 1: Architecture Foundation & Drift Database Setup
- Add Drift, SQLite dependencies, and audio playback package (`just_audio` / `audioplayers`) to `pubspec.yaml`.
- Set up `core/database/` with `SavedMediaTable` and generate Drift database code.
- Create core domain error/failure hierarchy in `core/errors/`.
- **Acceptance Criteria**: `flutter analyze` and `flutter test` pass with zero errors. Drift database compiles cleanly.

### Phase 2: Android SAF Native Bridge & Permission PoC
- Implement `SafNativeDataSource` on Flutter side and Kotlin SAF handler in `android/app/src/main/kotlin/`.
- Implement `checkDirectoryAccess`, `requestDirectorySelection`, and `releaseDirectoryAccess`.
- Create `SafPermissionBanner` widget in `features/home/presentation/widgets/`.
- **Acceptance Criteria**: On a physical or emulated Android device, triggering the folder selection successfully launches `ACTION_OPEN_DOCUMENT_TREE`, persists permission, and saves the tree URI in `CashService`.

### Phase 3: Media Discovery, Metadata & Audio/Video Classification
- Implement native `discoverStatuses` returning document metadata.
- Implement classification logic separating `image`, `video`, and `audio` (identifying `.opus` / `.aac` audio statuses).
- Create `StatusRepository` and `GetStatusesUseCase`.
- **Acceptance Criteria**: Status files in the selected folder are enumerated, classified into image/video/audio, and sorted newest first in Dart models.

### Phase 4: Unified 3-Column Grid & High-Performance Thumbnail Caching
- Implement native thumbnail extraction with disk caching (`status_thumbnails/`).
- Build `HomePage` with `GridView.builder` (3 columns).
- Implement video play badge overlay and audio visual card treatment.
- Implement pull-to-refresh.
- **Acceptance Criteria**: Grid scrolls at 60/120 fps without frame drops. Videos show play badges and duration; audio shows waveform/music badges; images show thumbnails.

### Phase 5: Dedicated Media Viewers (Image, Video, Audio)
- **Image**: Integrate with `ImageViewerPage` (`photo_view`), adding save and share actions.
- **Video**: Build `StatusVideoViewerPage` with `video_player` streaming from SAF content URI, custom playback controls, and lifecycle disposal.
- **Audio**: Build `StatusAudioViewerPage` with audio waveform/player card, seek bar, play/pause, and lifecycle disposal.
- **Acceptance Criteria**: All three media types open smoothly in full-screen, play/zoom correctly, and dispose all resources on back navigation.

### Phase 6: MediaStore Saving & Drift-Backed Saved Tab
- Implement native `saveToMediaStore` copying SAF files to `Pictures/StatusSaver`, `Movies/StatusSaver`, `Music/StatusSaver`.
- Insert saved records into Drift SQLite database.
- Build `SavedPage` with media type filter chips (`All`, `Images`, `Videos`, `Audio`), multi-select share, and delete.
- Implement reconciliation with MediaStore on Saved tab load.
- **Acceptance Criteria**: Saving an item saves it to the device gallery, adds a row to Drift, and immediately displays it in the Saved tab.

### Phase 7: App Shell Unification, Settings & Localization Polish
- Update `AppShellPage` to host `HomePage`, `SavedPage`, and `SettingsPage` using `IndexedStack` and `MyBottomNavigationBar`.
- Add all localization strings to `app_en.arb` and `app_ar.arb`.
- Validate RTL layout across all screens.
- Add SAF folder path status & re-selection tile in `SettingsPage`.
- **Acceptance Criteria**: Tab state is preserved when switching between Home, Saved, and Settings. Language and theme toggles update instantly across all screens.

### Phase 8: Performance Profiling, Memory Audit & Automated Testing
- Profile memory allocations using Flutter DevTools (inspect image cache & player heap).
- Write comprehensive unit tests for Use Cases and Repositories.
- Write widget tests for Home, Saved, and Viewer screens.
- **Acceptance Criteria**: Zero memory leaks after repeated viewer open/close cycles; 80%+ test coverage across domain use cases.

---

## 16. Technical Uncertainties & Proof-of-Concept Requirements

The following platform risks require dedicated proof-of-concept (PoC) validation on real Android hardware before wide feature rollout:

1. **Android 11–14 SAF Restrictions on Specific OEM Builds**:
   - While vanilla Android allows `ACTION_OPEN_DOCUMENT_TREE` on `Android/media/com.whatsapp`, certain OEM variations (notably Xiaomi HyperOS/MIUI and Samsung OneUI) occasionally restrict user selection of subfolders inside `Android/media/`.
   - *PoC Requirement*: Validate `ACTION_OPEN_DOCUMENT_TREE` with initial URI hint across Google Pixel, Samsung Galaxy, and Xiaomi devices.
2. **Direct SAF Content URI Streaming to ExoPlayer**:
   - `video_player` on Android wraps ExoPlayer. While ExoPlayer supports `content://` URIs, some devices enforce strict file descriptor boundaries that can cause seek failures on non-seekable streams.
   - *PoC Requirement*: Verify that passing `content://` URIs directly to `VideoPlayerController.contentUri()` supports full seeking and duration retrieval without requiring a proxy file copy.
3. **Audio Status Codec Playback (`.opus` in OGG container)**:
   - WhatsApp voice status files are typically Opus-encoded. The chosen Flutter audio package (`just_audio` or `audioplayers`) must decode Opus files directly on Android API 24+.
   - *PoC Requirement*: Confirm playback, pause, and seek behavior on raw WhatsApp `.opus` status files.

---

## 17. Mandatory Agent Operating Instructions (Rules of Engagement)

Every AI coding agent operating on this repository must abide by the following directives:

1. **Read `AGENT.md` First**: Always consult this document before initiating any architectural change or creating new files.
2. **Reuse Existing Resources**: Never create a new button, app bar, card, icon constant, dialog helper, or preference service without first verifying if an existing component in `core/` or `shared/` can be reused.
3. **Keep Views Free of Logic**: Never place `MethodChannel` invocations, database calls, or complex business logic inside Flutter widgets or views.
4. **Enforce GetX Hygiene**: Never instantiate controllers manually inside widget build methods; use bindings and `Get.find()`.
5. **No Scope Creep**: Implement only the explicitly requested feature or milestone. Do not reorganize unaffected modules or introduce unrequested third-party packages.
6. **Verify Analysis and Tests**: After every modification, run static analysis and tests to ensure the codebase remains clean, warning-free, and regression-free:
   ```bash
   flutter analyze
   flutter test
   ```
7. **Document Architectural Shifts**: If a technical constraint forces an architectural deviation (such as a workaround for an Android OEM restriction), update `AGENT.md` immediately with the rationale and revised contract.
