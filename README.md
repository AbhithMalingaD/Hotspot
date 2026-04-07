# Hotspot 🚀

### Find Your Co-Working Space Anywhere

Hotspot is a Flutter-based mobile application UI that helps users discover and explore co-working spaces nearby — inspired by platforms like Booking.com, but focused on workspaces.

---

## 🌍 Overview

Hotspot provides a map-based interface to locate co-working spaces around the user, explore workspace options, and view availability details through a clean and intuitive UI.

This project demonstrates frontend architecture, UI/UX design, and mobile application structuring using Flutter.

---

## ⚠️ Project Scope

This repository contains only the **frontend (UI) implementation** of the Hotspot application.

* No backend or server-side integration included
* Data displayed is **mock/static**
* No real-time booking or availability system
* Focused on **UI design and user experience**

---

## ✨ Features

### 🗺️ Map-Based Discovery

* Interactive map interface
* Displays co-working spaces around the user
* Location-based UI simulation

### 🏢 Space Exploration

* View detailed information about each workspace
* Includes:

  * Hot desks
  * Meeting rooms
  * Board rooms
  * Event spaces

### 📊 Availability (UI Simulation)

* Visual representation of seating and room availability
* Designed for future real-time integration

### 📜 Activity History

* Track previously visited co-working spaces
* UI for user activity timeline

### 👤 User Profile

* Profile screen layout
* Displays user-related data and activity

---

## 🛠️ Tech Stack

* Flutter (UI Framework)
* Dart (Programming Language)

---

## 🧱 Architecture Overview

The project follows a modular Flutter structure:

* **Screens** → UI pages (Map, Space, Activity, Profile)
* **Widgets** → Reusable UI components
* **Models** → Data structures (mock data)
* **Services (optional)** → Placeholder for future API integration

---

## 📂 Project Structure

```
lib/
 ├── main.dart
 ├── screens/
 │    ├── map_screen.dart
 │    ├── space_screen.dart
 │    ├── activity_screen.dart
 │    └── profile_screen.dart
 ├── widgets/
 ├── models/
 └── services/
```

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK installed
* Android Studio or VS Code
* Emulator or physical device

### Installation

```bash
git clone https://github.com/AbhithMalingaD/Hotspot.git
cd Hotspot
flutter pub get
flutter run
```

---

## 🔌 Future Enhancements

* Backend integration (REST API / Firebase)
* Real-time availability tracking
* Booking & reservation system
* Payment gateway integration
* Reviews and ratings system
* Advanced filters (price, distance, amenities)

---

## 🎯 Use Case

This application is designed as a **conceptual platform** for:

* Remote workers
* Freelancers
* Digital nomads
* Teams looking for flexible workspaces

---

## 📖 Resources

* https://docs.flutter.dev/get-started/learn-flutter
* https://docs.flutter.dev/get-started/codelab
* https://docs.flutter.dev/reference/learning-resources

---

## 👤 Author

**Abhith Malinga**
GitHub: https://github.com/AbhithMalingaD

---

## 📄 License

This project is licensed under the MIT License.
