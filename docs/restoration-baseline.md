# Nervespace restoration baseline

Captured on 2026-07-13 before the local-first restoration began.

## Source state

- The canonical checkout was clean on `main` before generation.
- `main` and `origin/main` both pointed to `e2f55e206b3289e7cab8aad514be0caf4a386d0d` after `git fetch origin` and `git pull --ff-only`.
- The restoration branch is `aize/portfolio-restoration`.

## Tooling

`tuist version` completed successfully and reported `4.79.3`.

## Project generation

`tuist generate --no-open` completed successfully. It generated `Nervespace.xcworkspace` and `Nervespace.xcodeproj`, then resolved the Swift package graph with `xcodebuild`.

The generated `Package.resolved` included these provider packages:

| Package | Version |
| --- | --- |
| Mixpanel | 2.10.4 |
| OneSignal | 5.2.10 |
| Sentry | 8.48.0 |
| Supabase | 2.26.0 |
| Superwall | 4.0.5 |

Superwall also resolved Superscript 0.1.18 as a transitive dependency. Generation did not call any provider API or exercise provider-backed app behavior.

Generation modified the tracked `Nervespace.xcodeproj/project.pbxproj` by 41 insertions and 22 deletions. That generated change is intentionally left uncommitted for comparison and is not part of the baseline commit.

## Destination inspection

`xcodebuild -workspace Nervespace.xcworkspace -scheme Nervespace-Staging -showdestinations` did not complete. It stopped making progress while Xcode was resolving the package graph and fetching the cached Sentry repository, so the command was terminated rather than retried indefinitely.

No destination list was returned. The first available iPhone simulator and the build status therefore remain unverified at this baseline.

## Baseline conclusion

Tuist generation works with the existing provider-heavy manifest. Workspace destination discovery did not finish, and this baseline does not claim that the app builds or tests successfully.
