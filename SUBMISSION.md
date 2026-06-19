# App Store Submission

Project-level tooling for submitting SGMRT to the App Store via the App Store Connect (ASC)
API + Xcode CLI. Credentials live in a gitignored `.env` (template: [.env.example](.env.example));
the ASC `.p8` key stays outside the repo at `ASC_PRIVATE_KEY_PATH`.

## App record

- **App name:** SGMRT
- **ASC App ID:** `6781980848`
- **Bundle ID:** `com.alfredang.sgmrt`
- **Team ID:** `GU9WTSTX9M`
- **Platform:** iOS 17+, SwiftUI (universal — iPhone + iPad)
- **Login required:** No (no account-deletion flow needed)

## Scripts

| Script | Purpose |
| --- | --- |
| `scripts/asc_submit.py` | status / set-metadata / review-contact / attach-build / screenshots / submit |
| `scripts/asc_jwt.swift` | Mints the ES256 JWT used by `asc_submit.py` |
| `scripts/make_iphone_screenshot.swift` | Frames an iPad capture as an iPhone 6.5" screenshot |
| `scripts/make_app_icon.swift` | Generates a 1024×1024 app icon |

## Workflow

```bash
set -a; source .env; set +a

# 1. Archive + upload a build (bump CFBundleVersion in project.yml first, then xcodegen generate)
xcodebuild -project SGMRT.xcodeproj -scheme SGMRT -configuration Release \
  -archivePath /tmp/SGMRT.xcarchive archive
xcodebuild -exportArchive -archivePath /tmp/SGMRT.xcarchive \
  -exportPath /tmp/export -exportOptionsPlist ExportOptions.plist
xcrun altool --upload-app -f /tmp/export/SGMRT.ipa -t ios \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"

# 2. Metadata + submit (after build processing reaches VALID, ~5–30 min)
python3 scripts/asc_submit.py status
python3 scripts/asc_submit.py set-metadata
python3 scripts/asc_submit.py review-contact
python3 scripts/asc_submit.py attach-build --build <N>
python3 scripts/asc_submit.py submit
```

## UI-only steps (no public API)

- **App Privacy "nutrition label"** — set once in ASC: *App Privacy → declare data collection
  (SGMRT collects no personal data) → Publish*.
- **Age rating / content rights** declarations.

## Current status

Version 1.0 / build 1 is uploaded (`VALID`) and the version is `WAITING_FOR_REVIEW`.
Re-check anytime with `python3 scripts/asc_submit.py status`.
