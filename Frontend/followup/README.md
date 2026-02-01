# FollowUP - Smart Schedule Management App

FollowUP is a cross-platform schedule management app built with Flutter that uses AI technology to intelligently recognize event information from images and text, helping users easily manage their schedules.

## Features

- **AI Chat Assistant** - Create events through natural language conversation with intelligent recognition, supporting real-time streaming responses
- **Image Recognition** - Take photos or upload event posters and flyers, AI automatically extracts event information
- **Text Parsing** - Paste event description text, intelligently recognizes dates, locations, titles, and other key information
- **Calendar Sync** - One-click export to ICS files, sync to Apple Calendar, Google Calendar, and other calendar apps
- **Event Following** - Follow events of interest for quick viewing and management
- **Responsive Design** - Supports mobile and desktop, adapts to different screen sizes
- **Dark Mode** - Supports system-level dark/light mode switching

## Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: Provider
- **HTTP Client**: http
- **Real-time Communication**: SSE (Server-Sent Events) streaming
- **Local Storage**: shared_preferences
- **Image Handling**: image_picker
- **File Operations**: path_provider
- **Web Support**: universal_html
- **Date Formatting**: intl
- **App Info**: package_info_plus
- **Internationalization**: flutter_localizations + ARB files
- **Markdown Rendering**: flutter_markdown

## Project Structure

```
lib/
├── main.dart              # App entry point
├── config.dart            # API configuration
├── l10n/                  # Internationalization
│   ├── app_en.arb         # English translations (template)
│   ├── app_zh.arb         # Chinese translations
│   ├── app_de.arb         # German translations
│   ├── app_localizations.dart      # Generated localization class
│   ├── app_localizations_en.dart   # English localization
│   ├── app_localizations_zh.dart   # Chinese localization
│   └── app_localizations_de.dart   # German localization
├── models/                # Data models
│   ├── event.dart         # Event/schedule model
│   └── user.dart          # User model
├── pages/                 # Pages
│   ├── landing_page.dart  # Product landing page (Hero background)
│   ├── login_page.dart    # Login page
│   ├── home_page.dart     # Home page (retained, currently unused)
│   ├── chat_page.dart     # AI chat page (main interaction entry)
│   ├── input_page.dart    # Input page (text/image recognition)
│   ├── preview_page.dart  # Event details/edit page
│   ├── events_page.dart   # Events list page
│   └── profile_page.dart  # User profile page
├── providers/             # State management
│   ├── auth_provider.dart # Authentication state
│   └── events_provider.dart # Events state
├── services/              # Service layer
│   ├── api_service.dart   # API request wrapper
│   ├── auth_service.dart  # Authentication service
│   ├── chat_service.dart  # Chat service (SSE streaming)
│   └── mock_service.dart  # Mock data service
├── theme/                 # Theme configuration
│   └── app_theme.dart     # App theme (colors, backgrounds, styles)
├── utils/                 # Utilities
│   ├── date_formatter.dart # Date formatting
│   └── validators.dart    # Form validation
└── widgets/               # Reusable components
    ├── error_dialog.dart  # Error dialog
    ├── event_card.dart    # Event card
    ├── image_picker_widget.dart # Image picker
    ├── input_area.dart    # Input area
    └── loading_overlay.dart # Loading overlay

assets/
└── images/
    ├── logo.png           # App logo
    ├── logo_transparent.png # Transparent background logo
    └── main_picture.png   # Hero background image

updatelog.md                # Update log
```

## Requirements

- Flutter SDK >= 3.10.4
- Dart SDK >= 3.10.4
- iOS: Xcode 14.0+
- Android: Android Studio / Gradle 8.0+
- Web: Chrome browser

## Current Version

- **Version**: 1.0.16+1

## Quick Start

### 1. Install Dependencies

```bash
cd Frontend/followup
flutter pub get
```

### 2. Configure Backend URL

The project supports API URL configuration via environment variables, allowing environment switching without code changes.

#### Environment Configuration

| Scenario | Command |
|----------|---------|
| Production (default) | `flutter run -d chrome` |
| Local development | `flutter run -d chrome --dart-define=ENV=dev` |
| Custom URL | `flutter run -d chrome --dart-define=API_BASE_URL=http://your-api.com` |

#### Preset Environments

- **Production** (`ENV=prod`, default): `https://web-production-d2e00.up.railway.app`
- **Development** (`ENV=dev`): `http://localhost:8000`

#### Usage in Code

```dart
import 'config.dart';

// Get current API URL
String url = ApiConfig.baseUrl;

// Check current environment
if (ApiConfig.isDev) {
  print('Development environment');
}

if (ApiConfig.isProd) {
  print('Production environment');
}
```

### 3. Switch Mock Mode

During development, you can use mock data by editing `lib/services/api_service.dart`:

```dart
class ApiService {
  // Whether to use mock data (set to true during development)
  static bool useMock = true;  // Set to false for production
}
```

### 4. Run the App

```bash
# Run web version
flutter run -d chrome

# Run iOS version (requires macOS)
flutter run -d ios

# Run Android version
flutter run -d android

# Run desktop version (macOS)
flutter run -d macos
```

## Build for Release

### Web Version

```bash
# Production build (default)
flutter build web --release

# Development build
flutter build web --release --dart-define=ENV=dev

# Custom backend URL build
flutter build web --release --dart-define=API_BASE_URL=https://your-custom-api.com
```

Build output is located in the `build/web/` directory.

### iOS Version

```bash
# Production
flutter build ios --release

# Development
flutter build ios --release --dart-define=ENV=dev
```

### Android Version

```bash
# Production
flutter build apk --release

# Development
flutter build apk --release --dart-define=ENV=dev

# Or build App Bundle
flutter build appbundle --release
```

## Deployment

### Vercel Deployment

The project is configured with `vercel.json` for Vercel deployment:

1. Build the web version
2. Deploy the `build/web/` directory to Vercel

### Custom Server Deployment

Deploy the files in the `build/web/` directory to any static file server (e.g., Nginx, Apache).

## API Endpoints

The app communicates with the backend via REST API. Main endpoints include:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/login` | POST | User login |
| `/api/chat` | POST | AI chat endpoint (SSE streaming) |
| `/api/parse` | POST | Parse event information (text/image) |
| `/api/events` | GET | Get events list |
| `/api/events` | POST | Create event |
| `/api/events/{id}` | DELETE | Delete event |
| `/api/events/{id}/follow` | PATCH | Toggle follow status |
| `/api/events/{id}/ics` | GET | Download ICS calendar file |

## Route Structure

| Route | Page | Description |
|-------|------|-------------|
| `/` | LandingPage | Product landing page (entry point) |
| `/login` | LoginPage | Login page |
| `/home` | HomePage | Home page (retained, currently no entry) |
| `/chat` | ChatPage | AI chat page (main entry after login) |
| `/input` | InputPage | Input page (accessible only from HomePage) |
| `/preview` | PreviewPage | Event details/edit page |
| `/events` | EventsPage | Events list page |
| `/profile` | ProfilePage | User profile page |

## Page Navigation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  LandingPage (/)  Product Landing Page                          │
│  → /login (Get Started button)                                  │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  LoginPage (/login)  Login Page                                  │
│  → /chat (after successful login)                               │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│  ChatPage (/chat)  AI Chat Page ← Main Interaction Entry        │
│                                                                 │
│  → /events (view events list)                                   │
│  → /profile (user menu → profile)                               │
│  → /preview (view event details)                                │
│  → / (logout)                                                   │
└─────────────────────────────────────────────────────────────────┘
           │                    │                    │
           ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ EventsPage      │  │ ProfilePage     │  │ PreviewPage     │
│ (/events)       │  │ (/profile)      │  │ (/preview)      │
│ Events List     │  │ User Profile    │  │ Event Details   │
│                 │  │                 │  │                 │
│ → /preview      │  │ → /events       │  │ (stay on page)  │
│   (click event) │  │ → /chat         │  │                 │
│                 │  │ → / (logout)    │  │                 │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### Unused Pages

| Page | Route | Status |
|------|-------|--------|
| HomePage | `/home` | Retained, currently no entry point |
| InputPage | `/input` | Accessible only from HomePage |

## User Flow

1. **Splash Screen** - iOS/Android native splash screen displays brand logo
2. **Login/Register** - User logs in (test account supported: test/test123)
3. **AI Chat** - Chat with AI assistant, describe events to create or upload images
4. **Smart Recognition** - AI analyzes intent in real-time, automatically extracts event details (SSE streaming supported)
5. **Preview & Confirm** - User reviews and edits recognition results
6. **Save & Sync** - Save event and export ICS file to calendar
7. **Event Management** - View, follow, or delete events in the events list

## Internationalization (i18n)

The app supports three languages, with English as default:

| Language | Code | File |
|----------|------|------|
| English | `en` | `lib/l10n/app_en.arb` |
| Chinese | `zh` | `lib/l10n/app_zh.arb` |
| German | `de` | `lib/l10n/app_de.arb` |

### Adding New Translations

1. Add new key in `lib/l10n/app_en.arb` (English is the template)
2. Add corresponding translations in `app_zh.arb` and `app_de.arb`
3. Run `flutter gen-l10n` to regenerate localization classes
4. Use in code:

```dart
import '../l10n/app_localizations.dart';

// Use in Widget
final l10n = AppLocalizations.of(context)!;
Text(l10n.welcomeMessage);
```

### Switching Languages

Modify the `locale` parameter in `lib/main.dart`:

```dart
locale: const Locale('zh'), // Switch to Chinese
```

## Development Guide

### Adding New Pages

1. Create new page file in `lib/pages/`
2. Add route in `onGenerateRoute` in `lib/main.dart`

### Adding New State

1. Create new Provider in `lib/providers/`
2. Register in `MultiProvider` in `lib/main.dart`

### Code Standards

The project uses `flutter_lints` for code analysis:

```bash
flutter analyze
```

## License

© 2026 FollowUP. Made with AI.
