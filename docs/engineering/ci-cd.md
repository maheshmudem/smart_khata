# CI/CD

## Pipelines

### `ci.yml` — every pull request and every push to `main`

| Job | Steps | Fails when |
|---|---|---|
| **verify** | `pub get --enforce-lockfile` → regenerate l10n, Drift code and the schema export → format check → `flutter analyze --fatal-infos` → `flutter test --coverage` → coverage gate | Lock file out of date; generated files differ from what is committed; unformatted code; any analyzer note; any failing test; core/domain coverage under 90% |
| **build-android** | Debug APK, then a release APK | Either build fails; the release APK requests `INTERNET` |
| **secrets-scan** | gitleaks over the full history | A key, password or token is committed |

A newer push to the same branch cancels the run in progress.

### `release.yml` — a tag `vX.Y.Z`

1. The tag must equal the `version:` in `pubspec.yaml`.
2. Analyze and test again.
3. Write `android/key.properties` and the keystore from repository secrets. If any secret is missing the job fails; it never ships a debug-signed bundle.
4. `flutter build appbundle --release --obfuscate --split-debug-info`, build number = workflow run number.
5. Delete the signing material.
6. Upload the AAB and symbols as an artifact and attach the AAB to a **draft** GitHub release.

Upload to Google Play is manual for now (internal track first). Automate it once a Play Console app and service account exist.

### Dependabot

Weekly for pub packages, monthly for Gradle and GitHub Actions. Drift and BLoC packages are grouped so they update together.

## One-time setup you need to do on GitHub

These cannot be done from the repository.

1. **Branch protection on `main`** (Settings → Branches → Add rule):
   - Require a pull request before merging; require 1 approval; require review from Code Owners.
   - Require status checks: `Format, analyze, test`, `Android build`, `Secret scan`.
   - Require branches to be up to date; require linear history; block force pushes and deletion.
2. **Environment `production`** (Settings → Environments): add yourself as a required reviewer so a tag cannot release without approval.
3. **Signing secrets** (Settings → Secrets and variables → Actions), after creating the upload keystore:

   ```bash
   keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 \
     -validity 10000 -alias upload
   base64 -w0 upload-keystore.jks     # paste the output as ANDROID_KEYSTORE_BASE64
   ```

   | Secret | Value |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | base64 of `upload-keystore.jks` |
   | `ANDROID_KEYSTORE_PASSWORD` | keystore password |
   | `ANDROID_KEY_ALIAS` | `upload` |
   | `ANDROID_KEY_PASSWORD` | key password |

   Keep the keystore and passwords in a password manager and an offline copy. Losing the upload key means asking Google to reset it; leaking it means anyone can sign as you. Enrol in Play App Signing when you create the app.

## Releasing

1. All release gates in `docs/product/07_Implementation_Backlog.md` §7 are met.
2. Bump `version:` in `pubspec.yaml` (`1.0.0+1` → `1.0.1+1`; the build number is replaced by CI). Merge to `main`.
3. `git tag v1.0.1 && git push origin v1.0.1`.
4. Approve the `production` environment. Download the AAB from the draft release.
5. Upload to the Play internal track → closed testing with pilot merchants → production with a staged rollout.
6. Publish the GitHub release with notes.

Version rule: patch for fixes, minor for features, major for a release that changes stored data in a way old versions cannot read.

## Signing locally

Create `android/key.properties` (ignored by git):

```properties
storeFile=C:/path/to/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Without it, `flutter build apk --release` is debug-signed so it can run on your own phone. Such a build must never be uploaded.

## Rollback and incidents

- A Play release cannot be un-published for users who already updated; halt the staged rollout and ship a fixed build with a higher version.
- **Never ship a build that lowers `schemaVersion`.** A device that already migrated cannot open an older schema. Fix forward.
- A data-loss or wrong-balance report is Critical: stop the rollout first, then investigate.

## Before each Play submission

Recheck the target API requirement (API 36 at the time of writing), the Data safety form against the actual manifest and packages, and the privacy policy link. The release APK's permission list is printed in the `Android build` job log.
