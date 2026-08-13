# 👔 Employee Attendance System

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24+-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.5+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-orange.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

A cross-platform Employee Attendance System built with **Flutter** and **ASP.NET Core**, following **Clean Architecture** principles. Track employee attendance via QR code scanning, GPS validation, and real-time admin dashboards.

---

## 📱 Features

### Employee Mobile App (Flutter)
- 🔐 **JWT Authentication** — Secure login/register with token refresh
- 📷 **QR Code Scanning** — Mark attendance by scanning site-specific QR codes
- 📍 **GPS Location Capture** — Validate employee location against work site geofence
- 📱 **Device Fingerprinting** — Capture device info for audit trails
- 📊 **Attendance History** — View past records with pull-to-refresh
- 👤 **Profile Management** — Edit profile and upload avatar
- 🌐 **Offline Support** — Queue attendance when offline, sync when connected
- 🔔 **Push Notifications** — Get notified of schedule changes
- 🔒 **Biometric Authentication** — Fingerprint / Face ID login

### Admin Dashboard (Flutter Web)
- 🗺️ **Live Tracking Map** — Real-time employee location on Google Maps
- 📈 **Analytics & KPIs** — Dashboard with charts and statistics
- 👥 **Employee Management** — CRUD operations with search and filters
- 🏗️ **Site Management** — Create sites, generate QR codes, set geofences
- 📋 **Attendance Reports** — Filtered reports with Excel/PDF export
- 🖨️ **QR Code Generation** — Print site-specific QR codes

### Backend (ASP.NET Core)
- 🛡️ **Identity & JWT** — ASP.NET Identity with role-based access control
- 🗄️ **Entity Framework Core** — Code-first database migrations
- 📡 **RESTful API** — Clean, versioned API endpoints
- 🧪 **Unit & Integration Tests** — Comprehensive test coverage
- 🐳 **Docker Support** — Containerized deployment ready

---

## 🏗️ Architecture

This project follows **Clean Architecture** and **SOLID Principles** with a **Feature-First** folder structure.

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (UI, Widgets, Riverpod Providers, Screens, State)          │
├─────────────────────────────────────────────────────────────┤
│                    DOMAIN LAYER                              │
│  (Entities, Repository Interfaces, Use Cases)               │
├─────────────────────────────────────────────────────────────┤
│                      DATA LAYER                              │
│  (Models, DTOs, Repository Implementations, Data Sources)   │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Decisions

| Principle | Implementation |
|-----------|---------------|
| **Separation of Concerns** | Data, Domain, and Presentation layers are strictly separated |
| **Dependency Inversion** | Domain depends on abstractions (interfaces), not implementations |
| **Single Responsibility** | Each Use Case handles exactly one business action |
| **Immutability** | State is immutable using Freezed code generation |
| **Dependency Injection** | Riverpod providers inject dependencies top-down |

---

## 🛠️ Tech Stack

### Mobile & Web Frontend
| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Riverpod** | Reactive state management & DI |
| **Dio** | HTTP client with interceptors |
| **GoRouter** | Declarative routing |
| **Flutter ScreenUtil** | Responsive design |
| **Freezed** | Immutable data classes |
| **Mobile Scanner** | QR code scanning |
| **Geolocator** | GPS location services |
| **Flutter Secure Storage** | Encrypted local storage |
| **fl_chart** | Data visualization |
| **Google Maps Flutter** | Map integration |

### Backend
| Technology | Purpose |
|------------|---------|
| **ASP.NET Core 8** | Web API framework |
| **Entity Framework Core** | ORM & database migrations |
| **ASP.NET Identity** | Authentication & authorization |
| **JWT Bearer** | Token-based authentication |
| **MediatR** | CQRS & mediator pattern |
| **AutoMapper** | Object mapping |
| **FluentValidation** | Input validation |
| **Serilog** | Structured logging |
| **SQL Server / PostgreSQL** | Relational database |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp configuration
├── core/
│   ├── constants/                     # App-wide constants
│   ├── network/
│   │   └── dio_client.dart            # Dio singleton & interceptors
│   ├── router/
│   │   └── app_router.dart            # GoRouter configuration
│   ├── storage/
│   │   └── secure_storage.dart        # Encrypted key-value storage
│   ├── theme/
│   │   └── app_theme.dart             # ThemeData & color scheme
│   └── widgets/                       # Reusable UI components
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── login_request_model.dart
│   │   │   │   └── login_response_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── check_auth_status_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── auth_state.dart
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           ├── splash_screen.dart
│   │           ├── login_screen.dart
│   │           └── register_screen.dart
│   │
│   ├── attendance/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── mock_qr_service.dart
│   │   │   └── models/
│   │   │       └── qr_validation_result.dart
│   │   └── presentation/
│   │       └── screens/
│   │           ├── qr_scanner_screen.dart
│   │           └── attendance_confirmation_screen.dart
│   │
│   ├── home/
│   │   └── presentation/
│   │       └── screens/
│   │           └── home_screen.dart
│   │
│   └── admin/
│       └── ...
│
└── generated/                         # Freezed generated files
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>= 3.24.0`
- [Dart SDK](https://dart.dev/get-dart) `>= 3.5.0`
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) (for emulators)
- [Git](https://git-scm.com/)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/employee-attendance-system.git
cd employee-attendance-system

# 2. Install dependencies
flutter pub get

# 3. Generate code (Freezed, JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

### Running on Different Platforms

```bash
# Android
flutter run

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

---

## 🔐 Environment Configuration

Create a `.env` file in the root directory:

```env
# API Configuration
API_BASE_URL=https://your-api-url.com/api
API_TIMEOUT=30000

# Feature Flags
ENABLE_BIOMETRIC=true
ENABLE_OFFLINE_MODE=true

# Maps (Admin Dashboard)
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code follows our style guidelines and includes appropriate tests.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Reso Coder](https://resocoder.com) for Clean Architecture tutorials
- [Riverpod](https://riverpod.dev) for excellent state management
- [Dio](https://pub.dev/packages/dio) for powerful HTTP client

---

## 📬 Contact

For questions or support, please open an issue on GitHub or contact the maintainers.

**Built with ❤️ and Flutter.**
