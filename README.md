# Nervespace

<img src="docs/nervespace-icon.png" alt="Nervespace app icon" width="96">

## Overview

Nervespace is a local-first SwiftUI app for short movement, stretching, breathing, and recovery routines. It is designed around one quick loop: choose a routine, follow the timed exercises, and see the completed activity in progress and history.

This public build stores activity on the device. Account sync and production services are not part of it.

## Screenshots

| Home | Active session | Local history |
| --- | --- | --- |
| <img src="docs/screenshots/home.png" alt="Nervespace home screen" width="260"> | <img src="docs/screenshots/routine-session.png" alt="Nervespace timed routine session" width="260"> | <img src="docs/screenshots/progress-history.png" alt="Nervespace local routine history" width="260"> |

## Demo

[Watch the 28-second app demo](docs/demo/nervespace-demo.mp4) · [Read the capture notes](docs/demo/README.md)

The clip follows a routine from selection through a saved local history entry.

## Current feature set

- First-launch onboarding
- 20 bundled exercises, 11 routines, and 4 plan collections
- Home, quick-routine, plan, category, and body-area browsing
- Routine bookmarks and per-exercise duration controls
- Timed sessions with pause, previous, next, and exercise details
- Completion history, daily minutes, a configurable daily goal, and streak tracking
- A repeating local reminder using iOS notifications

## Architecture

Tuist 4.79.3 generates the Xcode workspace from `Project.swift`. The runtime code is split into three targets:

```text
Nervespace
├── App            SwiftUI screens and iOS adapters
├── SharedKit      Bundled content, shared models, and reusable UI
└── LocalDataKit   Completion storage, migration, and progress rules
```

The app has no external package dependencies. Tests are separated into `AppTests`, `SharedKitTests`, `LocalDataKitTests`, and `NervespaceUITests`.

## Local data model

Each completed routine is stored as a `RoutineCompletion` with an ID, routine ID, duration in minutes, and completion date. Completions are written atomically to:

```text
Application Support/Nervespace/routine_completions.json
```

The persistence layer keeps writes sorted, reads the earlier JSON shape for migration, and omits deleted legacy entries. Daily-goal, bookmark, and reminder settings use `UserDefaults`. Progress calculations use a calendar-aware 4:00 a.m. activity-day boundary so late-night sessions stay with the intended day.

## Setup

Requirements:

- Xcode with an iOS Simulator
- Tuist 4.79.3

From the repository root:

```sh
tuist generate --no-open
open Nervespace.xcworkspace
```

Select the `Nervespace-Staging` scheme and an iPhone simulator.

## Verification

Run the canonical repository check:

```sh
./scripts/verify
```

It checks the exact Tuist version, generates the workspace, scans the manifest and active targets for removed private-provider references, selects an available iPhone from the newest installed iOS runtime, runs all four test targets, and builds for a generic iOS Simulator.

The latest local run completed 40 tests with zero failures or skips, followed by a successful generic simulator build. The verifier is the correctness evidence; the screenshots and demo are presentation evidence only.

## Limitations

- The app provides no account-based sync or app-managed cross-device backup.
- Reminders are local notifications and require permission. They are not remote push messages.
- Routines, plans, exercises, and artwork are bundled with the app rather than managed remotely.
- The current evidence covers an iPhone Simulator. A real-device build, public-main CI run, and App Store release are not claimed here.
- The app currently uses a fixed dark appearance.
- Nervespace is a routine tracker, not medical guidance.
