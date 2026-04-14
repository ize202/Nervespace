# Nervespace

Nervespace is a SwiftUI iOS app for short movement and recovery routines. It packages guided routines, multi-day plans, reminders, progress tracking, and account sync in a modular Tuist workspace.

## What it is

This repo holds the full app code for Nervespace. The project is split into a main app target plus smaller framework targets for shared UI/helpers, auth and sync, notifications, analytics, and crash reporting.

## What problem it solves

I wanted a phone-first routine app that made it easy to start a short session, keep progress moving, and sync that progress across devices without building a heavy social layer. The code is organized around that goal: quick onboarding, clear browse flows, lightweight history, and optional sign-in.

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

The repo includes production assets and the full app code. Exported App Store screenshots are not checked in yet.

## Local setup

1. Install Xcode 15 or newer.
2. Install Tuist.
3. From the repo root, run `tuist install` and `tuist generate`.
4. Open `Nervespace.xcworkspace` or `Nervespace.xcodeproj`.
5. Update the plist files in `Targets/*/Config` if you want to run against your own Supabase, Mixpanel, OneSignal, and Sentry projects.
6. Build the `Nervespace` scheme or the `Nervespace-Staging` scheme if you want the bundled StoreKit config.

## Current status

Active iOS product repo. The main cleanup still underway is repository hygiene around generated files and exported developer state.
