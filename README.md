# Next Generation Real-Time Chat Application

A fully-featured, real-time peer-to-peer messaging application built with Flutter, Firebase Authentication, and Cloud Firestore. 

## Overview

This project provides a robust foundation for a secure and responsive chat application. It utilizes modern state management practices and leverages Firebase's backend-as-a-service to deliver seamless real-time communication across multiple platforms.

## Core Features

*   **Real-Time Messaging:** Instantaneous message delivery and reception powered by Cloud Firestore.
*   **Secure Authentication:** User signup, login, and password recovery managed by Firebase Authentication.
*   **User Profiles:** Functionality to view and edit user profile information.
*   **Theme Management:** Full support for system, light, and dark mode themes, providing an optimal viewing experience.
*   **Settings Configuration:** Customizable user preferences including appearance, language, notifications, and privacy options.
*   **State Management:** Predictable and scalable state management utilizing Riverpod.

## Technology Stack

*   **Frontend Framework:** Flutter (Dart)
*   **Backend & Database:** Firebase (Cloud Firestore)
*   **Authentication:** Firebase Auth
*   **State Management:** Riverpod (`flutter_riverpod`)
*   **Typography:** Google Fonts (`google_fonts`)
*   **Iconography:** Cupertino Icons and Lucide Icons (`lucide_icons`)

## Project Structure

The project follows a modular structure to ensure maintainability and separation of concerns:

```
lib/
├── models/       # Data representation classes
├── providers/    # Riverpod state providers (e.g., ThemeProvider)
├── screens/      # UI templates and page layouts
│   ├── appearance_screen.dart
│   ├── chat_screen.dart
│   ├── edit_profile_screen.dart
│   ├── forgot_password_screen.dart
│   ├── home_screen.dart
│   ├── language_screen.dart
│   ├── login_screen.dart
│   ├── notifications_screen.dart
│   ├── privacy_screen.dart
│   ├── signup_screen.dart
│   └── user_list_screen.dart
├── services/     # Logic for external interactions (e.g., Firebase)
│   ├── auth_service.dart
│   └── chat_service.dart
└── main.dart     # Application entry point
```

## Getting Started

### Prerequisites

*   Flutter SDK (^3.9.2 or higher)
*   Dart SDK
*   Firebase project configured with Authentication and Cloud Firestore enabled.

### Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Aryyl/Chatapp.git
    cd Chatapp
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration:**
    Ensure you have generated and placed the necessary Firebase configuration files into the project. Use the FlutterFire CLI to configure the project for your target platforms:
    ```bash
    flutterfire configure
    ```
    *Note: The generated `firebase_options.dart` and native configuration files (e.g., `google-services.json`, `GoogleService-Info.plist`) must not be tracked in version control.*

4.  **Run the application:**
    ```bash
    flutter run
    ```

## Security Note

Please be aware that backend configuration files containing API keys and project identifiers should remain excluded from version control. Ensure that `.gitignore` accurately reflects the exclusion of files such as `firebase_options.dart`, `google-services.json`, and `.env`.
