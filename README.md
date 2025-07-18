# 🌱 SPROUT - Smart Plant Solution App

**SPROUT** is a smart plant care mobile application built with Flutter that empowers users to monitor light and soil conditions, identify plants, and receive personalized care tips. Designed for plant enthusiasts and beginners alike, SPROUT uses real-time data, intelligent recommendations, and an intuitive UI to make plant care simple and engaging.

---

## 📱 Features

- 🌞 **Light Meter**  
  Real-time ambient light sensor with lux-based plant recommendations.

- 💧 **Soil Moisture Monitor**  
  Displays current soil moisture using animated circular progress and provides watering tips and suitable plants.

- 📷 **Plant Identifier**  
  Upload or capture plant images to identify species using the Plant ID API, with detailed care instructions and fun facts.

- 📚 **Plant Collection**  
  Save identified or recommended plants to your personal collection.

- 🪴 **Care Tips & Recommendations**  
  Dynamic suggestions for watering, lighting, soil type, toxicity, and cultural significance.

---

## 🔧 Tech Stack

- **Flutter** – Cross-platform mobile app development
- **Dart** – Core programming language
- **Firebase Realtime Database** – Live data syncing and storage for tips & plant info
- **Plant ID API** – AI-based plant image recognition
- **Custom Widgets** – Modular components like `MyButton`, `MyTextField`, `SquareTile`
- **Packages Used**:
  - `light_sensor` – Reads ambient light levels
  - `image_picker` – Captures or selects plant images
  - `http` – Makes API calls
  - `firebase_core` & `firebase_database` – Firebase integration
  - `path_provider`, `flutter_spinkit`, etc. – UI and file handling enhancements

---

## 🚀 Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/yourusername/sprout.git
cd sprout
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

- Follow [FlutterFire documentation](https://firebase.flutter.dev/docs/overview/)
- Place your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the appropriate directories.

### 4. Run the app

```bash
flutter run
```
