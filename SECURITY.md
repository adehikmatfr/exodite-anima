# Security policy

exodite-anima keeps a private journal on the device. Security problems matter here, so please report them privately first.

## Reporting a vulnerability

Use GitHub's private reporting: open the **Security** tab of this repository and choose **Report a vulnerability**. This sends the report only to the maintainer.

Please do not open a public issue or pull request that describes a vulnerability before it is fixed.

Helpful details: what you did, what you expected, what happened, the app version and Android version, and (if you can) a minimal way to reproduce it. Use made-up journal text; never send real journal content.

## What to expect

This is a small project maintained by one person, so there is no fixed response time. Reports are read, and a confirmed problem is fixed before it is discussed publicly. Reporters are credited in the release notes if they wish.

## Scope

In scope: the app in `app/` (encryption and key handling, lock and screen privacy, export and import files, anything that could make content leave the phone).

Out of scope: problems that need a rooted or already-compromised phone, the loss of a journal because the passcode was forgotten (the app has no recovery by design), and vulnerabilities in third-party packages that are not reachable from the app (report those upstream).

## Supported versions

Only the latest release is supported. No version has been released yet.
