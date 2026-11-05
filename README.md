Halati

Halati is a WhatsApp Status Saver application that makes it easy to browse, view, and save statuses from both WhatsApp Messenger and WhatsApp Business in one place.

Designed with simplicity, performance, and a clean user experience in mind, Halati provides seamless switching between WhatsApp versions, a customizable interface, and a well-structured codebase built with modern Flutter development practices.

Features

- Dual WhatsApp Support: Browse and save statuses from both WhatsApp Messenger and WhatsApp Business.
- Seamless Switching: Smoothly switch between the two WhatsApp versions without unnecessary navigation.
- Status Saving: Save your favorite WhatsApp statuses directly to your device.
- Media Support: Browse and view status media, including images, videos, and audio.
- Customizable Themes: Personalize the app with theme customization and light/dark mode support.
- Localization: Multilingual support for a more accessible user experience.
- Clean Architecture: Organized, maintainable, and scalable project structure.
- Responsive UI: A clean interface designed to provide a consistent experience across different screen sizes.

Tech Stack

Technology| Purpose
Flutter| Cross-platform UI development
Dart| Application programming language
GetX| State management and navigation
Clean Architecture| Separation of concerns and maintainability

Architecture

Halati follows Clean Architecture principles to keep business logic independent from the presentation layer and infrastructure.

The project emphasizes:

- Separation of UI and business logic.
- Reusable widgets and shared components.
- Centralized application utilities and helpers.
- Single Responsibility Principle (SRP).
- SOLID principles.
- Clean, readable, and maintainable code.
- Feature-oriented organization.

User Experience

Halati focuses on delivering a smooth and intuitive experience through:

- Simple and modern interface.
- Smooth navigation between WhatsApp versions.
- Consistent design across application screens.
- Theme customization.
- Multilingual interface support.
- Efficient media browsing and viewing.

Project Structure

The project is organized to promote separation of concerns, code reuse, and scalability.

lib/
├── app/
│   ├── bindings/
│   ├── routes/
│   └── ...
│
├── core/
│   ├── constants/
│   ├── helpers/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── ...
│
├── shared/
│   ├── widgets/
│   └── ...
│
├── features/
│   ├── home/
│   ├── media_viewer/
│   ├── settings/
│   └── ...
│
└── main.dart

Note: The structure above illustrates the intended architectural organization. Directory names may vary depending on the actual implementation.

Getting Started

Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android device or emulator

Installation

1. Clone the repository:
   
   git clone https://github.com/luai0yk/halati.git

2. Navigate to the project directory:
   
   cd halati

3. Install dependencies:
   
   flutter pub get

4. Run the application:
   
   flutter run

Requirements

- WhatsApp Messenger and/or WhatsApp Business installed on your device.
- Required storage or media access permissions.
- Compatible Android version.

Contributing

Contributions are welcome!

If you have ideas for improvements, bug fixes, or new features, feel free to contribute.

1. Fork the repository.
2. Create a new branch for your changes.
3. Commit your changes with clear and descriptive messages.
4. Push your branch to your fork.
5. Open a Pull Request describing your changes.

Feel free to open an issue if you encounter a bug or have a suggestion.

Disclaimer

Halati is an independent application and is not affiliated with, endorsed by, or officially connected to WhatsApp or Meta Platforms, Inc.

WhatsApp and WhatsApp Business are trademarks of Meta Platforms, Inc.

Halati accesses locally available status media on the user's device and does not claim ownership of third-party content. Users are responsible for respecting the privacy and intellectual property rights of others.

Author

Luai Kaleessi

- GitHub: "@luai0yk" (https://github.com/luai0yk)

---

<p align="center">
  Made with Flutter
</p>