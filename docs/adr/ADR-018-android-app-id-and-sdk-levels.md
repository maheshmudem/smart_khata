# ADR-018 — App ID, platforms and Android configuration

**Status:** Accepted (foundation build, 15 Nov 2026). minSdk to be confirmed against pilot devices.

## Decision

| Item | Value | Reason |
|---|---|---|
| Application ID / namespace | `com.maheshmudem.smartkhata` | Chosen by the product owner. Cannot change after the first Play upload |
| Platforms in the repo | `android/`, `ios/` | V1 ships on Android only. `ios/` is kept untouched for a later launch; web and desktop folders were removed |
| `minSdk` | 24 (Android 7.0) | Flutter 3.44's floor; covers low-cost phones common among the target merchants. Confirm with real pilot devices (open decision 4) |
| `targetSdk` | 36 | Google Play requirement for new apps at the time of writing; recheck at each submission |
| `android:allowBackup` | `false`, plus `dataExtractionRules` and `fullBackupContent` that exclude everything | The OS must not copy unencrypted financial records to Google Drive or to another device. The only backup is the encrypted export the owner makes (architecture §12) |
| `INTERNET` permission | Absent from the release manifest | V1 is offline-only. Debug and profile builds keep it for Flutter tooling. CI fails if a release APK requests it |
| Release build | R8 minify and resource shrinking on; `--obfuscate --split-debug-info` in the release workflow | Smaller APK; symbols are kept as a build artifact |
| Signing | `android/key.properties` (git-ignored) or CI secrets | Without it a local release build is debug-signed and must not be uploaded; the release workflow refuses to run without secrets |
| Flavors | None | One local app, no backend environments |

## Consequences

- Reinstalling the app or moving to a new phone starts empty unless the owner restores an exported backup. The UI must say so plainly (FR-SET-005, FR-BKP-009).
- The iOS bundle identifier is still the template value and must be set before any iOS work.
