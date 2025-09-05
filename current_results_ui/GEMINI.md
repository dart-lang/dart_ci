# Gemini Project Context

This file provides essential context about the `current_results_ui` project for the Gemini CLI.

## Project Overview

This is a Flutter web application designed to display the current continuous integration (CI) test results for the Dart project. It fetches and shows data from the Current Results API.

The application is deployed as a hosted web app on Firebase and uses Google Cloud Build for automated builds and deployments.

### Key Technologies

*   **Framework:** Flutter (Web)
*   **Backend/Hosting:** Firebase (Authentication, Firestore, Hosting)
*   **CI/CD:** Google Cloud Build
*   **Language:** Dart

## Development Workflow

After making any code changes, the following steps should be performed to ensure code quality and consistency:

1.  **Format Code:** Ensure consistent code style across the project.
    ```sh
    dart format .
    ```

2.  **Analyze Code:** Check for errors, warnings, and lints.
    ```sh
    flutter analyze
    ```

3.  **Run Tests:** Verify that all existing functionality is working as expected.
    ```sh
    flutter test
    ```

## Building and Running

### 1. Get Dependencies

First, ensure all project dependencies are downloaded and up-to-date.

```sh
flutter pub get
```

### 2. Run the Application

To run the application locally in a Chrome browser, use the following command:

```sh
flutter run -d chrome --wasm
```

### 3. Generate Mocks

The project uses `mockito` for testing, which requires code generation via `build_runner`. To generate the necessary mock files, run:

```sh
dart run build_runner build --delete-conflicting-outputs
```

### 4. Deployment (Automated)

Deployment is handled automatically by Google Cloud Build, as configured in `cloudbuild.yaml`. Pushes to the repository likely trigger a build and deploy the web app to Firebase Hosting. Manual deployment is not recommended but can be triggered via the `gcloud` CLI as described in the `README.md`.

## Development Conventions

*   **Copyright Headers:** All new Dart source files (`.dart`) must include the following copyright header at the top of the file. The year should always be the current year (e.g., 2025 for work done in 2025, 2026 for work done in 2026, and so on).

    ```dart
    // Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
    // for details. All rights reserved. Use of this source code is governed by a
    // BSD-style license that can be found in the LICENSE file.
    ```

*   **Linting:** The project follows the recommended linting rules from the `package:flutter_lints/flutter.yaml` package. Custom rules and exclusions are defined in `analysis_options.yaml`.
*   **Firebase Integration:** The app is tightly integrated with Firebase. Configuration for hosting, emulators, and project details are located in `firebase.json` and `lib/firebase_options.dart`.
*   **Routing:** The application uses path-based URL routing (`usePathUrlStrategy()`) to handle different views, such as displaying results for a specific CL (changelist) and patchset.
*   **State Management:** The project appears to use the `provider` package for state management, as seen in `lib/main.dart`.
