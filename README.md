# 🌱 DailyTick – Habit Tracker App

DailyTick is a sleek, animated habit tracker built with Flutter. It helps you build better routines by tracking daily habits, visualizing progress, and celebrating streaks.



## 📸 Screenshots

### 🏠 Home Screen

| Empty State | With Habits |
|-------------|-------------|
| ![Home Empty](/SS/home_empty.jpeg) | ![Home With Habits](/SS/hoem_with_habbit.jpeg) |

### 📊 Dashboard

| Weekly Stats | Streaks Overview |
|--------------|------------------|
| ![Progress 1](/SS/pregress1.jpeg) | ![Progress 2](/SS/progress2.jpeg) |


---

## ✨ Features

- ✅ Add, complete, and delete habits with smooth animations
- 📅 Tracks daily completion using per-day logs
- 📊 Dashboard with weekly stats and streak tracking
- 🔥 Streak insights: current and longest streak per habit
- 🧠 Custom font for branded look (`Poppins`)
- 💾 Persistent local storage using `shared_preferences`
- 🎯 Clean UI with dark theme and intuitive interactions

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.8.1
- Android Studio or VS Code
- Android NDK version `27.0.12077973`

### Installation

```bash
git clone https://github.com/AbdullahRFA/habit_tracker.git
cd dailytick
flutter pub get
flutter run
```

> If you encounter NDK version issues, update your `android/app/build.gradle.kts` with:
> ```kotlin
> ndkVersion = "27.0.12077973"
> ```

---

## 📁 Project Structure

```
lib/
├── main.dart               # Core habit tracker logic
├── dashboard_screen.dart   # Weekly stats & streaks
fonts/
└── Poppins-Regular.ttf     # Custom font
```

---

## 🧪 Demo

| Screen         | Description                      |
|----------------|----------------------------------|
| Habit List     | Add, complete, and delete habits |
| Dashboard      | Weekly stats & streaks           |
| Empty State    | Friendly message with icon       |

---

## 🛠 Tech Stack

- Flutter
- Dart
- Shared Preferences
- Kotlin DSL (Gradle)
- Custom Fonts

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.3
  cupertino_icons: ^1.0.8
```

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you’d like to change.

---

## 👤 Author and Contact

**Abdullah Nazmus Sakib**  
Computer Science & Engineering @ Jahangirnagar University  
Passionate about clean UI, scalable systems, and delightful user experiences.
🔗 [LinkedIn](https://www.linkedin.com/in/abdullah-nazmus-sakib-04024b261/)  
🐙 [GitHub](https://github.com/AbdullahRFA)

---

