#!/usr/bin/env bash
# Checks the merged manifest of a release APK against ADR-005 and ADR-001:
#   * no permission outside an allow-list (so no network permission can slip in),
#   * cloud backup is off (android:allowBackup=false),
#   * the build is not debuggable.
# Usage: tool/check_release_manifest.sh path/to/app-release.apk
# Needs aapt2 (Android SDK build-tools): set AAPT2, or ANDROID_HOME / ANDROID_SDK_ROOT.
set -euo pipefail

apk="${1:?usage: check_release_manifest.sh app-release.apk}"
[ -f "$apk" ] || { echo "FAIL: $apk not found"; exit 2; }

aapt2="${AAPT2:-}"
if [ -z "$aapt2" ]; then
  sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  if [ -n "$sdk" ]; then
    aapt2="$(ls -1 "$sdk"/build-tools/*/aapt2 "$sdk"/build-tools/*/aapt2.exe 2>/dev/null | sort -V | tail -n 1 || true)"
  fi
fi
[ -n "$aapt2" ] && [ -x "$aapt2" ] || { echo "FAIL: aapt2 not found (set AAPT2 or ANDROID_HOME)"; exit 2; }

# Permissions the release build may declare. Anything else fails the check.
# The last one is added by AndroidX for the app itself and is not exported.
allowed_regex='^(android\.permission\.USE_BIOMETRIC|android\.permission\.USE_FINGERPRINT|[A-Za-z0-9_.]+\.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION)$'

fail=0
while IFS= read -r name; do
  [ -z "$name" ] && continue
  if [[ ! "$name" =~ $allowed_regex ]]; then
    echo "FAIL: unexpected permission: $name"
    fail=1
  fi
done < <("$aapt2" dump permissions "$apk" | sed -n "s/^uses-permission: name='\(.*\)'$/\1/p")

manifest="$("$aapt2" dump xmltree --file AndroidManifest.xml "$apk")"

if ! grep -q 'allowBackup.*=false' <<<"$manifest"; then
  echo "FAIL: android:allowBackup is not false"
  fail=1
fi
if grep -q 'debuggable.*=true' <<<"$manifest"; then
  echo "FAIL: the build is debuggable"
  fail=1
fi
if grep -q 'usesCleartextTraffic.*=true' <<<"$manifest"; then
  echo "FAIL: cleartext traffic is allowed"
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "Release manifest check FAILED"
  exit 1
fi
echo "Release manifest check passed: only allowed permissions, backup off, not debuggable."
