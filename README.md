# Unveil App

Unveil is a Flutter-based mobile application designed to help users discover and get notified about parties and events happening in their vicinity.

## 🚀 Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase Account](https://firebase.google.com/) and a new project set up.
- An IDE like [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with the Flutter plugin.

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/tim-contact/unveil_app.git
    cd unveil_app
    ```

2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Firebase Setup:**
    - Follow the instructions to add Firebase to your Flutter app for both Android and iOS: [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup)
    - Make sure to add your `google-services.json` file to `android/app/` and `GoogleService-Info.plist` to `ios/Runner/`.
    - Enable Firestore, Firebase Authentication (with Google Sign-In), and Firebase Cloud Messaging in your Firebase console.

4.  **Run the app:**
    ```sh
    flutter run
    ```

## ✨ Features

-   **Event Discovery:** Find parties and events happening near you.
-   **Real-time Notifications:** Get push notifications for new events in your area.
-   **User Authentication:** Sign up and log in using Google Sign-In.
-   **Event Details:** View detailed information about each event.
-   **Favorites:** Save events you are interested in.
-   **Profile Management:** Manage your user profile.

## 🛠️ Technologies Used

-   **Frontend:** [Flutter](https://flutter.dev/)
-   **Backend & Database:** [Firebase](https://firebase.google.com/)
    -   [Cloud Firestore](https://firebase.google.com/docs/firestore) - For storing event and user data.
    -   [Firebase Authentication](https://firebase.google.com/docs/auth) - For user authentication.
    -   [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging) - For push notifications.
-   **State Management:** [Provider](https://pub.dev/packages/provider)
-   **Location Services:**
    -   [geolocator](https://pub.dev/packages/geolocator)
    -   [geocoding](https://pub.dev/packages/geocoding)
-   **UI:**
    -   [google_fonts](https://pub.dev/packages/google_fonts)
    -   [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter)

## 📂 Project Structure

The `lib` directory contains the core source code of the application, structured as follows:

```
lib/
├── models/         # Data models for the app (Event, User).
├── pages/          # UI for each page/screen.
├── providers/      # State management using Provider.
├── services/       # Backend services (Firebase, Location, etc.).
├── shared/         # Shared widgets and utilities.
├── main.dart       # The main entry point of the application.
└── routes.dart     # Navigation routes.
```

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.
