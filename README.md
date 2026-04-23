# 💰 Saku Aman App
> A simple, smart, and personal expense tracker — built out of frustration with overly complicated finance apps.

---

## 🧠 Background

I used to track my expenses manually in my **phone's Notes app** — simple, but no visualizations, no insights, and nothing to warn me when I was starting to overspend.

Most finance apps on the market are **way too complex** and overwhelming for everyday needs. All I needed was one thing: **knowing where my money goes**, with a clean and easy-to-understand interface.

So I built it myself.

---

## 🎯 App Goals

- Log daily expenses quickly (under 10 seconds)
- Visualize spending patterns by category
- Automatically detect overspending habits — including excessive gaming expenses 🎮
- Provide actionable insights, not just raw numbers

---

## ✨ Key Features

### 📥 Expense Input
Add transactions with amount, category, and an optional note. Clean form design that's fast to fill out.

### 🏠 Home Screen
View today's, this week's, and this month's total spending. Recent transaction list with swipe-to-delete.

### 📊 Statistics
- Pie chart of spending by category
- Breakdown with visual progress bars
- Filter by today / this week / this month

### 🧠 Insight System *(Core Feature)*
An automatic detection system that analyzes spending patterns and triggers warnings, including:

| Insight | Condition |
|---|---|
| ⚠️ Too Many Transactions | More than 5 transactions in a single day |
| 📈 Spending Increased | This week's spending is >20% higher than last week |
| 📉 Spending Decreased | This week's spending is >20% lower than last week |
| 🏷️ Top Spending Category | One category accounts for >50% of total spending |
| 🎮 Game Addict Detected | Gaming expenses >30% of total, or >3 gaming transactions |
| 📅 Most Expensive Day | Detects the day with the highest spending |
| ✅ Finances Under Control | All conditions are within normal range |

### 🔔 Notifications
Insight warnings are automatically pushed as notifications to your phone.

### 🌙 Dark / Light Mode
Supports auto-detection from system settings, plus manual toggle from within the app.

---

## 🧱 Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Main cross-platform framework (Android & iOS) |
| **Dart** | Programming language |
| **SQLite** (`sqflite`) | Local offline database — all data stored on device |
| **fl_chart** | Data visualization: pie charts & progress bars |
| **flutter_local_notifications** | Push insight notifications to phone |
| **path** | Helper for database storage location |

---

## 🚀 How to Run

### Prerequisites
- Flutter SDK >= 3.0.0
- Android Studio / Xcode (for emulator)

### Steps

```bash
# Clone the repo
git clone https://github.com/Jemsdiggory/saku-aman-app.git
cd saku-aman-app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build APK (Android)

```bash
flutter build apk --debug
```

APK file located at: `build/app/outputs/flutter-apk/app-debug.apk`

### Build iOS (Mac only)

```bash
cd ios
pod install
cd ..
flutter build ios
```

---

## 👤 Developer

**Jems** — built as a portfolio project and a personal solution.

> *"Rather than waiting for the perfect app, I'd rather build my own that fits my needs."*

---

## 📄 License

This project is for personal and portfolio use.
