# Stock App — Repo, Deploy, and Workflow Guide

This document answers your 8 prompts: real repo location, Cursor changes verification, Firebase config, caching, single source of truth, Android build, deploy matrix, and API URLs.

---

## Prompt 1 — Real Flutter repo vs copy on external drive

### 1.1 Is this folder a copy?

- **Folder:** `/Volumes/Extreme Pro/App gpt/stock_app-main_updated`
- **`.git`:** **Does not exist** (confirmed: `ls -la .git` → "No such file or directory").
- **Conclusion:** This folder is **a copy**, not a git repository. The "not a git repository" error is expected.

### 1.2 Candidate folders (stock_app with pubspec.yaml)

Search results on `/Volumes/Extreme Pro` (and your current workspace):

| Absolute path | .git exists | firebase.json | Notes |
|---------------|-------------|---------------|--------|
| `/Volumes/Extreme Pro/App gpt/stock_app-main_updated` | **No** | Yes | Your current folder — copy only |
| `/Volumes/Extreme Pro/App Original/stock_app-main_updated` | **No** | Not checked | Copy |
| `/Volumes/Extreme Pro/App Original/stock_app-main` | **No** | Not checked | Copy |
| `/Volumes/Extreme Pro/stock_app-main1` | **No** | Not checked | Copy |
| `/Volumes/Extreme Pro/App cursor/stock_app-main` | **No** | Not checked | Copy |

**Finding:** On the external drive, **no** `stock_app` folder was found that has **both** `pubspec.yaml` and `.git`. So the **real** repo (the one connected to GitHub) is either:

- On another machine, or  
- In a path under `$HOME` (e.g. `~/projects/stock_app`), or  
- Only on GitHub (you had been editing on GitHub and never had a full clone locally).

### 1.3 Commands you can run

**Check for .git in current folder:**
```bash
ls -la .git
```

**Search for stock_app folders with pubspec.yaml (HOME, then volume):**
```bash
find "$HOME" -maxdepth 6 -type f -name pubspec.yaml -path "*stock_app*" 2>/dev/null
find "/Volumes/Extreme Pro" -maxdepth 8 -type f -name pubspec.yaml -path "*stock_app*" 2>/dev/null
```

**For each candidate directory, check git and latest commit:**
```bash
cd "<path>"
git status
git log -1 --oneline
```
(If `git` says "not a git repository", that path is a copy.)

**One-liner to list only candidates that have both `.git` and `pubspec.yaml`:**
```bash
find "/Volumes/Extreme Pro" -maxdepth 8 -type f -name pubspec.yaml -path "*stock_app*" 2>/dev/null | while read f; do d=$(dirname "$f"); if [ -d "$d/.git" ]; then echo "$d"; fi; done
```

---

## Prompt 2 — Verify “Cursor changes” in the code you deployed

You built/deployed from: `/Volumes/Extreme Pro/App gpt/stock_app-main_updated`.

### 2.1 Changes present in this folder

| Change | Status | Evidence |
|--------|--------|----------|
| **Removal of “Scan Stocks” FAB from Home** | **Present** | `home_screen.dart` has **no** `floatingActionButton` / `FloatingActionButton`. FABs exist only in `strategies_screen.dart` and `trades_screen.dart`. |
| **Run Scan moved to Strategies** | **Present** | `strategies_screen.dart` has `_buildRunScanCard`, `AppStrings.runScan`, and `controller.runScan()`. |
| **VIX toggle removed from scan dialog** | **Present** | `scan_filters_dialog_content.dart` has **no** "VIX" or "vix" — only program selector, market cap, volume, volatility, price, top N, strict rules, volume spike, allow intraday, ADX, daily loss limit. |
| **program_create_screen.dart exists** | **Present** | File exists at `lib/src/features/strategies/program_create_screen.dart`. |

So in **source code**, all Cursor changes are present. If the **live site** still shows the old UI, the cause is likely **cache** or **deploy from a different folder** (see Prompt 4).

### 2.2 Exact grep commands to re-verify

Run from `/Volumes/Extreme Pro/App gpt/stock_app-main_updated`:

```bash
# 1) No "Scan Stocks" FAB on Home → Home should have no floatingActionButton
grep -n "floatingActionButton\|FloatingActionButton" lib/src/features/home/home_screen.dart
# Expected: no matches. If you see matches, FAB was re-added.

# 2) Run Scan is in Strategies
grep -n "runScan\|Run Scan" lib/src/features/strategies/strategies_screen.dart
# Expected: multiple lines (e.g. _buildRunScanCard, runScan, AppStrings.runScan).

# 3) No VIX in scan dialog
grep -in "vix" lib/src/features/home/widgets/scan_filters_dialog_content.dart
# Expected: no matches.

# 4) program_create_screen exists
test -f lib/src/features/strategies/program_create_screen.dart && echo "EXISTS" || echo "MISSING"
# Expected: EXISTS.
```

---

## Prompt 3 — Firebase hosting project and site

### 3.1 Config in the folder you deploy from

**`.firebaserc`:**
```bash
cat .firebaserc
```
Content: `{"projects":{"default":"stockapp-gpt","prod":"stockapp-gpt"},"targets":{},"etags":{}}`  
→ **Project alias in use:** `stockapp-gpt` (both default and prod).

**`firebase.json`:**
```bash
cat firebase.json
```
Content: hosting `public` is `build/web`, with SPA rewrite to `/index.html`. **No `site` key** → uses the **default** site of project `stockapp-gpt`.

**Current project:**
```bash
firebase use
```
Output: `stockapp-gpt`  
→ You are deploying to project **stockapp-gpt**.

**Sites for this project:**
```bash
firebase hosting:sites:list
```
Output: one site — **Site ID:** `stockapp-gpt`, **URL:** `https://stockapp-gpt.web.app`.

So: **you are deploying to** `stockapp-gpt` → **https://stockapp-gpt.web.app**.  
The **old** site **stockappidane111.web.app** is a **different Firebase project** (or a different site in another project), not the one in this folder’s `.firebaserc`.

### 3.2 Deploy to the new site (current behavior)

```bash
cd "/Volumes/Extreme Pro/App gpt/stock_app-main_updated"
flutter build web
firebase deploy --only hosting
```
This updates **https://stockapp-gpt.web.app** only.

### 3.3 Deploy to the OLD site (stockappidane111.web.app) without breaking the new one

1. **Add the old project** (if not already):
   ```bash
   firebase use --add
   ```
   Select the project that owns **stockappidane111** and give it an alias, e.g. `old` or `stockappidane111`.

2. **Deploy to that project’s hosting** when you want the old URL updated:
   ```bash
   firebase use old   # or whatever alias you chose
   firebase deploy --only hosting
   firebase use stockapp-gpt   # switch back so next deploy goes to new site
   ```
   Your `firebase.json` and `build/web` are unchanged; only the **project** (and thus the site) changes. New site stays untouched until you run `firebase use stockapp-gpt` and deploy again.

---

## Prompt 4 — Why you still see old UI after deploy (caching vs wrong build)

### 4.1 Likely causes

1. **Browser / service worker cache** — browser or SW still serving old JS/assets.
2. **Wrong build folder** — you deployed from a different directory than the one where you made Cursor changes (we confirmed the **current** folder has the new UI in source).

### 4.2 Hard refresh and clear site data

**Chrome hard refresh (same tab):**
- **macOS:** `Cmd + Shift + R`  
- Or: DevTools (F12) → right‑click the refresh button → **Empty Cache and Hard Reload**.

**Clear site data (Chrome):**
1. Open `https://stockapp-gpt.web.app`.
2. Click the lock/info icon in the address bar → **Site settings**.
3. **Clear data** (or use “Cookies and site data” → Clear).
4. Reload.

**Incognito test:**
- New Incognito window (`Cmd + Shift + N`) → open `https://stockapp-gpt.web.app`.  
If the UI is **new** in Incognito but **old** in normal window → cache. If **old in both** → either deploy didn’t update or you’re looking at a different URL (e.g. old site).

### 4.3 Confirm the deployed build actually changed

**Option A — Check `build/web/index.html`:**
- Your current `build/web/index.html` has no build timestamp. To verify deploys in the future, add a visible version or comment before building, e.g. in `web/index.html` (source):
  ```html
  <!-- build: 2025-02-21-v1 -->
  ```
  Then run `flutter build web` and `firebase deploy --only hosting`. After deploy, “View Page Source” on the live site and search for that comment.

**Option B — Add a visible version label in the app:**
- In your main app widget (e.g. in debug/profile or behind a flag), show a small text like “v1.0.2” or “Build 2025-02-21”. Build, deploy, then check the live site (and Incognito). If you see the new label, the deployed build is new.

**Option C — Check file timestamps locally:**
- After `flutter build web`, run:
  ```bash
  ls -la build/web/
  ls -la build/web/main.dart.js
  ```
  Then deploy. If you redeploy without rebuilding, `main.dart.js` on the server should match that file; if you rebuilt, content will change.

---

## Prompt 5 — Single source of truth workflow (don’t lose GitHub edits)

### 5.1 Best practice

- **One** canonical repo (e.g. on GitHub).  
- **Always** work from a **git clone** of that repo.  
- **Pull** before making changes.  
- **Commit + push** after changes.  
- **Deploy** (Firebase, Render, etc.) from that **same** repo (or from CI that builds from that repo).

### 5.2 Convert your current external-drive folder into a safe workflow

**Option A — Clone fresh and copy only what you need (recommended if you’re unsure of history):**

1. Clone the real repo from GitHub to a permanent location (e.g. on internal disk):
   ```bash
   cd ~
   git clone https://github.com/<your-username>/<stock_app-repo>.git stock_app
   cd stock_app
   ```
2. Copy **only** the files you changed in the external copy into the clone (e.g. the Cursor‑touched files: `home_screen.dart`, `scan_filters_dialog_content.dart`, `strategies_screen.dart`, `program_create_screen.dart`, etc.). Avoid overwriting with old versions; prefer comparing with `diff` or a merge tool.
3. From then on, **only** edit in the clone. Use the external folder only as a reference, not for deploy.
4. Commit and push from the clone, then deploy from the clone (see checklist below).

**Option B — Connect current folder to GitHub (only if this folder is the one you want as source of truth):**

1. In your folder:
   ```bash
   cd "/Volumes/Extreme Pro/App gpt/stock_app-main_updated"
   git init
   git remote add origin https://github.com/<your-username>/<repo>.git
   git fetch origin
   git branch -M main
   # If GitHub already has history you want to keep:
   git reset --soft origin/main   # keeps your files, aligns to origin
   # Or: git pull origin main --allow-unrelated-histories  # if you need to merge
   ```
2. Resolve any conflicts, then:
   ```bash
   git add .
   git commit -m "Sync local Cursor changes"
   git push -u origin main
   ```
3. From then on, this folder is the repo; follow the checklist below.

### 5.3 Checklist every time

- [ ] **Pull** before editing: `git pull`
- [ ] Make changes in the **clone** (or the folder that has `.git` and `origin`).
- [ ] **Commit:** `git add .` then `git commit -m "Description"`
- [ ] **Push:** `git push`
- [ ] **Deploy web:** from same folder: `flutter build web` then `firebase deploy --only hosting`
- [ ] **Deploy backend:** push to GitHub (Render deploys from GitHub if configured).
- [ ] Do **not** deploy from a copy that has no `.git` or that isn’t synced with GitHub.

---

## Prompt 6 — Mobile installation path (APK / Diawi, no Android Studio)

### 6.1 Minimal Android build on macOS (no Android Studio)

You need:

- **Android command-line tools** (sdkmanager, etc.)
- **SDK** (platforms, build-tools, platform-tools)
- **ANDROID_HOME** (or **ANDROID_SDK_ROOT**) set so Flutter can find the SDK

### 6.2 Install via Homebrew

**Install command-line tools:**
```bash
brew install --cask android-commandlinetools
```

Typical install location:  
`/opt/homebrew/share/android-commandlinetools` (Apple Silicon) or  
`/usr/local/share/android-commandlinetools` (Intel).  
Use the path that `brew` reports.

**Set ANDROID_HOME and accept licenses (example for Apple Silicon):**
```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
# Or if Homebrew put tools elsewhere, use that as ANDROID_HOME and install SDK there:
# export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"

mkdir -p "$ANDROID_HOME"
# If using Homebrew's cmdline-tools, move or symlink so structure is:
# $ANDROID_HOME/cmdline-tools/latest/
# Then run:
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$ANDROID_HOME" "platform-tools" "platforms;android-34" "build-tools;34.0.0"
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$ANDROID_HOME" --licenses
```

Add to `~/.zshrc`:
```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
```

Then `source ~/.zshrc` or open a new terminal.

**Verify:**
```bash
flutter doctor
```
Fix any remaining SDK path issues so “Android toolchain” is OK.

### 6.3 Build APK and upload to Diawi

```bash
cd "/Volumes/Extreme Pro/App gpt/stock_app-main_updated"   # or your real repo path
flutter build apk --release
```

APK path: `build/app/outputs/flutter-apk/app-release.apk`.

**Upload to Diawi:**
- Open https://diawi.com and drag-and-drop `app-release.apk`, or use their CLI if you use it.
- Share the generated link for installation on the phone.

---

## Prompt 7 — Backend vs frontend responsibility (Render vs Firebase)

### 7.1 Who updates what

- **Flutter Web** (UI, client logic): build and deploy to **Firebase Hosting**. Changing Flutter web code → run `flutter build web` and `firebase deploy --only hosting`.
- **Flutter Mobile** (Android/iOS): changing app code → **new APK/IPA build** and distribute (e.g. Diawi, TestFlight, Play Store).
- **Backend API** (e.g. on Render): changing backend code → **push to GitHub** (Render auto-deploys if connected) or **manual deploy** in Render dashboard.

### 7.2 Matrix: “Change type → where to deploy”

| Change type | Where to deploy / what to do |
|-------------|------------------------------|
| Flutter web (lib/, web/) | Firebase Hosting (`flutter build web` then `firebase deploy --only hosting`) |
| Flutter Android app | Build APK (`flutter build apk --release`), then distribute (e.g. Diawi) |
| Flutter iOS app | Build IPA, then TestFlight/App Store or ad-hoc |
| Backend API (Render) | Push to GitHub (triggers Render deploy) or manual deploy on Render |
| Firebase config (e.g. .firebaserc, firebase.json) | No separate step; used on next `firebase deploy` |
| Environment / API URLs in Flutter | Change in repo (e.g. api_config.dart or env), rebuild web/APK and redeploy |

---

## Prompt 8 — Confirm current URLs used in Flutter build

### 8.1 api_config.dart

In `lib/src/utils/services/api_config.dart`:

- **Production HTTP:** `_prodHttpBaseUrl = 'https://stock-api-1-jhsa.onrender.com/'`  
- **WebSocket:** derived from that URL (https → wss, same host).  
So **web and release mobile builds** use **https://stock-api-1-jhsa.onrender.com** and **wss://stock-api-1-jhsa.onrender.com**. Correct.

- **Local:** `_localHttpBaseUrl = 'http://localhost:8000/'` — used when **not** in release mode (debug/profile). No change needed for production.

### 8.2 Search for old hostnames

**Commands run:**
- `stock-api-qg5u`: **no matches** in repo.
- `localhost:8000`: **only** in `api_config.dart` as `_localHttpBaseUrl` (intentional for local dev). **No fix needed.**
- `0.0.0.0`: **no matches** in repo.

**Conclusion:** No old hostnames to fix. Production builds use `stock-api-1-jhsa.onrender.com`.

---

## Quick reference commands

```bash
# Repo / git (run from repo root)
git status
git log -1 --oneline
git pull && git add . && git commit -m "msg" && git push

# Firebase (from app root)
firebase use
firebase hosting:sites:list
flutter build web && firebase deploy --only hosting

# Verify Cursor changes in source
grep -n "floatingActionButton" lib/src/features/home/home_screen.dart   # expect empty
grep -in "vix" lib/src/features/home/widgets/scan_filters_dialog_content.dart   # expect empty
test -f lib/src/features/strategies/program_create_screen.dart && echo "EXISTS"

# Android APK
export ANDROID_HOME="$HOME/Library/Android/sdk"
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

---

*Generated for the stock_app project. Adjust GitHub URLs and project names to your actual repo and Firebase project.*
