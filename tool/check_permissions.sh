#!/usr/bin/env bash
# Fails if a built APK requests a permission that is not in
# android/permissions-allowlist.txt.
#
#   tool/check_permissions.sh build/app/outputs/flutter-apk/app-release.apk
set -euo pipefail

apk="${1:?path to an APK}"
allowlist="android/permissions-allowlist.txt"
sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
aapt2="$(find "$sdk/build-tools" -name 'aapt2*' -type f | sort | tail -1)"

requested="$("$aapt2" dump permissions "$apk"   | sed -n "s/^uses-permission: name='\(.*\)'.*/\1/p" | sort -u)"
allowed="$(grep -v '^#' "$allowlist" | sed '/^[[:space:]]*$/d' | sort -u)"

echo "Requested permissions:"
echo "$requested"

extra="$(comm -23 <(echo "$requested") <(echo "$allowed"))"
if [ -n "$extra" ]; then
  echo "::error::The APK requests permissions that are not allowed:"
  echo "$extra"
  echo "V1 is offline-only and asks for as little as it can (CLAUDE.md rule 14)."
  exit 1
fi
echo "All requested permissions are on the allowlist."
