# NewsApp - Project Structure

## 📁 Folder Layout

```
newsapp/
│
├── assets/                                 # Asset files
│   └── images/                            # Image assets
│       ├── README.md                      # Image requirements guide
│       ├── background.jpg                 # Background image (add this)
│       ├── logo.png                       # App logo (add this)
│       └── news_placeholder.png           # News placeholder (optional)
│
├── lib/                                   # Main source code
│   │
│   ├── main.dart                          # App entry point
│   │
│   ├── app/                               # App-level configuration
│   │   ├── routes.dart                    # Route definitions
│   │   └── theme/                         # App theming
│   │       ├── app_colors.dart            # Color palette
│   │       └── app_theme.dart             # Theme configuration
│   │
│   ├── core/                              # Core functionality
│   │   └── constants/                     # App constants
│   │       ├── app_assets.dart            # Image paths
│   │       └── app_constants.dart         # App-wide constants
│   │
│   ├── features/                          # Feature modules
│   │   │
│   │   ├── auth/                          # Authentication feature
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           ├── splash_screen.dart      # Splash screen (40% opacity bg)
│   │   │           ├── login_screen.dart       # Login screen (40% opacity bg)
│   │   │           └── signup_screen.dart      # Signup screen (40% opacity bg)
│   │   │
│   │   └── marketplace/                   # Marketplace feature
│   │       └── presentation/
│   │           └── pages/
│   │               └── marketplace_screen.dart # Dashboard (100% opacity bg)
│   │
│   └── shared/                            # Shared components
│       └── widgets/
│           └── background_widget.dart     # Reusable background widget
│
├── test/                                  # Unit and widget tests
├── android/                               # Android platform code
├── ios/                                   # iOS platform code
├── web/                                   # Web platform code
├── windows/                               # Windows platform code
├── macos/                                 # macOS platform code
├── linux/                                 # Linux platform code
│
├── pubspec.yaml                           # Flutter dependencies
└── README.md                              # Project documentation
```

## 🎯 Screen Flow

```
Splash Screen (3 seconds)
    ↓
Login Screen
    ↓
    ├─→ Sign Up Screen
    │       ↓
    └─→ Marketplace/Dashboard Screen
```

## 🎨 Background Image Opacity

| Screen | Opacity | Location |
|--------|---------|----------|
| Splash | 40% (0.4) | `splash_screen.dart:22` |
| Login | 40% (0.4) | `login_screen.dart:85` |
| Signup | 40% (0.4) | `signup_screen.dart:79` |
| Marketplace | 100% (1.0) | `marketplace_screen.dart:67` |

All opacity values are controlled via:
- `lib/core/constants/app_constants.dart:17-21`

## 📝 Key Files

### Configuration Files
- **app_assets.dart** - Centralized image path management
- **app_constants.dart** - App constants (opacity, durations, etc.)
- **app_colors.dart** - Color palette
- **app_theme.dart** - Material theme configuration
- **routes.dart** - Navigation routes

### Screen Files
- **splash_screen.dart** - Initial screen with animated logo
- **login_screen.dart** - Email/password login with validation
- **signup_screen.dart** - User registration with validation
- **marketplace_screen.dart** - Main dashboard with news feed

### Shared Widgets
- **background_widget.dart** - Reusable background with opacity control

## 🚀 Getting Started

### 1. Add Images
Add required images to `assets/images/`:
- `background.jpg` (required)
- `logo.png` (required)
- See `assets/images/README.md` for details

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
flutter run
```

## 📱 Features (MVP)

### ✅ Implemented
- [x] Splash screen with animated logo
- [x] Login screen with email/password validation
- [x] Signup screen with form validation
- [x] Marketplace/dashboard with news feed
- [x] Background image with opacity control
- [x] Responsive UI design
- [x] Bottom navigation bar
- [x] Category filtering UI
- [x] Sample news articles

### 🔜 To Be Implemented (Next Phase)
- [ ] API integration for real news data
- [ ] State management (Provider/Riverpod)
- [ ] Local database (Hive/SQLite)
- [ ] Bookmark functionality
- [ ] Search feature
- [ ] Article details page
- [ ] User profile
- [ ] Settings page

## 🎯 MVP Timeline (1 Month)

### Week 1: Backend Integration
- API setup
- State management
- Data models

### Week 2: Core Features
- News feed with real data
- Article details
- Bookmarks

### Week 3: Additional Features
- Search functionality
- Categories
- User preferences

### Week 4: Polish & Testing
- UI refinements
- Bug fixes
- Testing
- Performance optimization

## 🛠️ Tech Stack

- **Framework**: Flutter 3.8+
- **Language**: Dart 3.8+
- **State Management**: To be added (Provider/Riverpod recommended)
- **Local Storage**: To be added (Hive/SharedPreferences)
- **HTTP Client**: To be added (Dio/http)
- **Architecture**: Feature-first with clean separation

## 📚 Code Organization

### Naming Conventions
- **Files**: snake_case (e.g., `login_screen.dart`)
- **Classes**: PascalCase (e.g., `LoginScreen`)
- **Variables**: camelCase (e.g., `emailController`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `SPLASH_DURATION`)

### Import Order
1. Dart/Flutter packages
2. External packages
3. Internal app imports

## 🎨 Design System

### Colors
- Primary: Blue (#1E88E5)
- Accent: Orange (#FF6F00)
- See `app/theme/app_colors.dart` for full palette

### Typography
- Headline Large: 32px, Bold
- Headline Medium: 24px, Bold
- Body Large: 16px, Regular
- Body Medium: 14px, Regular

### Spacing
- Default Padding: 16px
- Border Radius: 12px

## 📄 License

This project is private and not for public distribution.
