# Nervespace

Nervespace is a SwiftUI iOS app for short movement and recovery routines. It includes guided routines, multi-day plans, reminders, progress tracking, and account sync in a Tuist workspace.

## What it is

This repo contains the full app code for Nervespace. The project is split into the main app target plus smaller framework targets for shared UI and helpers, auth and sync, notifications, analytics, and crash reporting.

## What problem it solves

I wanted a routine app that was quick to open, easy to follow, and able to keep progress in sync across devices without adding a social layer. The app is built around that, with simple onboarding, clear navigation, history, and optional sign-in.

## What I built

- SwiftUI screens for onboarding, home, explore, plan detail, routine detail, progress, history, and account settings
- A Tuist-based workspace with `App`, `SharedKit`, `SupabaseKit`, `NotifKit`, `AnalyticsKit`, and `CrashlyticsKit`
- Local progress storage with sync hooks into Supabase
- Subscription and paywall wiring with Superwall
- Push notifications through OneSignal, analytics through Mixpanel, and crash reporting through Sentry

## Stack

- SwiftUI
- Tuist
- Supabase
- Superwall
- OneSignal
- Mixpanel
- Sentry

## Screenshots or demo

![Nervespace app icon](docs/nervespace-icon.png)
![Bundled routine artwork](docs/routine-evening-calm.jpg)

The repo includes app assets and the full codebase. Exported App Store screenshots are not checked in yet.

## Local setup

1. Install Xcode 15 or newer.
2. Install Tuist.
3. From the repo root, run `tuist install` and `tuist generate`.
4. Open `Nervespace.xcworkspace` or `Nervespace.xcodeproj`.
5. Update the plist files in `Targets/*/Config` if you want to run against your own Supabase, Mixpanel, OneSignal, and Sentry projects.
6. Build the `Nervespace` scheme or the `Nervespace-Staging` scheme if you want the bundled StoreKit config.

## Current status

Active iOS app repo with the main app code, production assets, and local setup notes in one place.
