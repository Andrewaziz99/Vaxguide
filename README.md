# VaxGuide

An integrated vaccination guidance app built with Flutter and Firebase to help users find vaccine information, track doses, receive alerts, and contact support in Arabic-first UX.

## Project Overview

VaxGuide is a production-style mobile app that combines:

- trusted vaccine content (search + details)
- personal vaccine history tracking
- push and local reminders
- health alerts and educational articles
- support, feedback, and admin operations in one system

The app follows a clean `UI -> Cubit -> Repository -> Firebase` flow and uses real-time Firestore streams where needed.

## What I Developed

### User Experience

- Built complete auth flows (email/password + Google Sign-In) with session caching.
- Added first-login profile completion before entering the main app.
- Implemented one-time About popup on first login, then persisted `aboutPopupSeen` per user.
- Synced About content from Firestore so the popup and `AboutScreen` always show the same live text.
- Added clickable developer WhatsApp contact from the About page (`aboutDeveloperPhone`) with direct message launch.
- Built custom themed UI (glass effects, branded colors, Arabic typography with Alexandria font).

### Core Product Features

- Implemented vaccine search and filtering across categories/subcategories.
- Built vaccine detail pages with medical sections (importance, schedule, side effects, warnings, etc.).
- Added dose recording flow and personal vaccine history timeline.
- Added educational article feed and article details.
- Added vaccine alert banners and realtime alert consumption.
- Implemented in-app feedback collection and duplicate-submission protection per user.

### Notifications

- Integrated Firebase Cloud Messaging for remote alerts (`vaccine_alerts` topic).
- Built foreground local notification display with custom sound channel.
- Implemented scheduled local dose reminders via timezone-aware notifications.
- Added handling for background/terminated notification open scenarios.

### Admin Panel

- Created role-based admin entry (visible only for admin users).
- Built multi-tab admin panel for managing:
  - vaccines
  - categories and subcategories
  - articles
  - alerts
  - users
  - support tickets
  - About app text
- Added live About text editor (`ManageAboutTab`) backed by Firestore `app_content/about`.

### Backend and Automation

- Built Firebase Cloud Functions for automatic vaccine alert push notifications.
- Built support-ticket email workflow using Nodemailer:
  - new ticket email to admin/support
  - confirmation email to user
  - reply email to user when admin updates ticket
- Added bulk JSON uploader scripts in `data/` for seeding categories, vaccines, articles, and alerts.

## Tech Stack

- **Frontend:** Flutter (Dart), Material UI
- **State Management:** `bloc`, `flutter_bloc`
- **Backend:** Firebase Auth, Cloud Firestore, Cloud Functions, FCM, Remote Config
- **Notifications:** `firebase_messaging`, `flutter_local_notifications`, `timezone`
- **Utilities:** `shared_preferences`, `url_launcher`, `google_sign_in`, `image_picker`

## Firestore Collections Used

- `users`
- `vaccines`
- `vaccine_categories`
- `vaccine_alerts`
- `articles`
- `support_tickets`
- `user_feedback`
- `app_content`

## Project Structure

- `lib/modules/` -> feature screens (Auth, Home, Search, History, Admin, etc.)
- `lib/core/blocs/` -> Cubits and states
- `lib/core/repositories/` -> Firestore access layer
- `functions/` -> Firebase Functions for push/email automation
- `data/` -> JSON data + upload tooling

## Getting Started

### Prerequisites

- Flutter SDK (matching `sdk: ^3.11.0`)
- Firebase project configured for Android/iOS/Web as needed

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run
```

## LinkedIn Post Draft (Ready to Copy)

I am excited to share **VaxGuide**, a Flutter + Firebase app I developed to make vaccine information and follow-up easier for users.

What I built:

- Full authentication flow (Email/Password + Google Sign-In) with profile completion.
- Smart first-login onboarding with an About popup shown once per user.
- Firestore-driven About content synced between popup and About page, plus admin editing.
- Vaccine search, detailed vaccine pages, dose recording, and personal history tracking.
- Real-time vaccine alerts, educational articles, and Arabic-first user experience.
- Push notifications (FCM) + scheduled local dose reminders with custom sound.
- Full admin panel to manage vaccines, categories, articles, alerts, users, support tickets, and app content.
- Support ticket pipeline with Firebase Functions + Nodemailer (admin notification, user confirmation, and reply emails).

Tech: **Flutter, Dart, Firebase Auth, Firestore, Cloud Functions, FCM, Bloc/Cubit**.

#Flutter #Firebase #MobileDevelopment #Dart #HealthTech #SoftwareEngineering #CloudFunctions #FCM
