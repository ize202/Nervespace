# Nervespace restoration baseline

Captured on 2026-07-13 before the local-first restoration began.

## Source state

- The canonical checkout was clean on `main` before generation.
- `main` and `origin/main` both pointed to `e2f55e206b3289e7cab8aad514be0caf4a386d0d` after `git fetch origin` and `git pull --ff-only`.
- The restoration branch is `aize/portfolio-restoration`.

## Tooling

`tuist version` completed successfully and reported `4.79.3`.

## Project generation

`tuist generate --no-open` reported generating `Nervespace.xcworkspace` and `Nervespace.xcodeproj`. The tracked `Nervespace.xcodeproj/project.pbxproj` changed, which confirms that project generation wrote output.

Dependency resolution is not proven. The Tuist log ended while fetching `swift-crypto`, and the existing generated `Package.resolved` did not change during the command. That existing file lists these provider packages:

| Package | Version |
| --- | --- |
| Mixpanel | 2.10.4 |
| OneSignal | 5.2.10 |
| Sentry | 8.48.0 |
| Supabase | 2.26.0 |
| Superwall | 4.0.5 |

The existing file also lists Superscript 0.1.18 as a transitive Superwall dependency. The baseline command did not call any provider API or exercise provider-backed app behavior.

Generation modified the tracked `Nervespace.xcodeproj/project.pbxproj` by 41 insertions and 22 deletions. That generated change is intentionally left uncommitted for comparison and is not part of the baseline commit.

## Destination inspection

`xcodebuild -workspace Nervespace.xcworkspace -scheme Nervespace-Staging -showdestinations` did not complete. It stopped making progress while Xcode was resolving the package graph and fetching the cached Sentry repository, so the command was terminated rather than retried indefinitely.

No destination list was returned, so an Xcode workspace destination remains unverified at this baseline.

As a fallback device inventory, `xcrun simctl list devices available` completed successfully. Its first available iPhone was `iPhone 17 Pro` on iOS 26.5 (`6CF43628-6661-4CBD-A8D6-CC24E0B31780`), in the shutdown state. This inventory does not prove that the generated workspace can build for that destination.

## Baseline conclusion

Tuist wrote generated project output from the existing provider-heavy manifest, but package resolution remains unproven. Workspace destination discovery did not finish, and this baseline does not claim that the app builds or tests successfully.

## Restoration verification

The restored project is now provider-free and local-first. `Project.swift` has no
external packages, and `scripts/check-provider-free` scans the active source,
manifest, and project configuration for references to the removed provider
SDKs.

Run the canonical local check from the repository root:

```sh
./scripts/verify
```

The verifier requires Tuist 4.79.3, regenerates the workspace, runs the provider
guard, selects the first available iPhone from the newest installed iOS runtime,
runs all four test targets through `Nervespace-Staging`, and performs a generic
iOS Simulator build. The same command is the only repository command run by CI.

The first complete harness run finished 40 tests with zero failures or skips on
an iPhone 17 Pro simulator running iOS 26.5, then completed the generic simulator
build. That result is local evidence, not evidence that the GitHub Actions
workflow has run.

Generated Xcode projects and workspaces were later removed from version control
after target-parity inspection and two clean verifier runs. They are generated
on demand and ignored, so a successful verification run leaves the source tree
clean.
