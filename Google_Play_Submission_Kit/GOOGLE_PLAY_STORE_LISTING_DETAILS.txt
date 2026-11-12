# Google Play Console Submission Kit & Store Listing Details

**App Name**: Goni Dahir Quran Audio  
**Reciter**: Goni Dahir Idris Maiduguri (القارئ قوني طاهر إدريس مَيْدُغُرِي)  
**Riwayah**: Hafs 'an 'Asim (حَفْص عَنْ عَاصِم)  
**Developer**: FrontalMinds Nigeria  
**Contact Email**: princeykarg@gmail.com  
**Website**: https://frontalminds.com.ng/  

---

## 1. Package Name / Application ID (Starts with `com.`)

### Recommended Package Name:
```text
com.frontalminds.gonidahir.quran
```

### Why this package name is recommended:
1. **Industry Standard**: Android requires reverse-domain notation starting with `com.`. Since the developer organization is **FrontalMinds** (`frontalminds.com.ng`), `com.frontalminds.gonidahir.quran` ensures global uniqueness on the Google Play Store and prevents brand name conflicts.
2. **Canonical & Clean**: It accurately reflects both the publisher (`frontalminds`) and the app (`gonidahir.quran`).

### Alternative Options (Also starting with `com.`):
- `com.gonidahir.quran.audio`
- `com.gonidahir.maiduguri.quran`
- Current legacy placeholder: `com.gwanidahiru.quran.gwani_dahiru_app`

> **Note**: To set this package name before building your production `.aab`, update `applicationId` in `android/app/build.gradle.kts`.

---

## 2. Store Listing Copy (Ready to Copy & Paste)

### App Title (Max 30 characters)
```text
Goni Dahir Quran Audio
```
*(Length: 22 / 30 characters)*

### Short Description (Max 80 characters)
```text
Complete Holy Quran recitation by Goni Dahir Idris Maiduguri (Hafs an Asim).
```
*(Length: 76 / 80 characters)*

### Full Description (Max 4,000 characters)
```text
Listen to the soul-stirring, melodious, and authentic recitation of the Holy Quran by renowned Nigerian Qari, Goni Dahir Idris Maiduguri (القارئ قوني طاهر إدريس مَيْدُغُرِي), recited in the canonical Riwayah of Hafs 'an 'Asim (حَفْص عَنْ عَاصِم).

This application provides a seamless, high-fidelity listening experience for all 60 recorded Surahs—whether you are connected to the internet or completely offline.

✨ KEY FEATURES:

📖 Complete 60 Surah Audio Catalog
• High-definition audio recordings of Goni Dahir Idris Maiduguri.
• Fast, CDN-accelerated streaming with instant byte-range seek and playback.

📥 1-Tap Offline Downloads
• Download any Surah directly to your device for offline listening anytime, anywhere without an active internet connection.
• Non-blocking background downloader with download cancellation and cache management.
• Optional "Download only on Wi-Fi" toggle to preserve mobile data.

🎧 Background & Lock Screen Playback
• Full integration with Android MediaStyle notification controls and lock screen player.
• Control playback (Play, Pause, Skip Next, Skip Previous) without unlocking your phone.
• Seamless auto-pause and auto-resume handling during incoming phone calls.

🔁 Auto-Replay & Continuous Play
• Repeat individual Surahs seamlessly—ideal for Quran memorization (Hifz) and revision.
• Non-repeating intelligent shuffle pool across all available Surahs.

⏱️ Sleep Timer & Playback Speed
• Set automatic sleep timers (15m, 30m, 60m) for bedtime Quran recitation.
• Adjust recitation playback speed (0.75x, 1.0x, 1.25x, 1.5x, 2.0x) according to your learning pace.

🔍 Dual-Language Search (Arabic & Hausa)
• Instant search by Surah name in English or Arabic (with full diacritic and tashkeel normalization).
• Supports vernacular Hausa phonetic search terms (e.g. Kulhuwa, Bakara, Falaqi, Nasi, Mulku, Tabat, etc.).
• Search by Surah number (1, 01, 001).

❤️ Favorites & Storage Management
• Bookmark your favorite Surahs for quick access in a dedicated tab.
• Clear cache easily with dedicated storage metrics showing downloaded megabytes.

🔒 Privacy-First Design
• No account registration or login required.
• No personal data collection or tracking.
• 100% free and dedicated to spreading the recitation of the Holy Quran.

---
Reciter: Goni Dahir Idris Maiduguri (Borno State, Nigeria)
Riwayah: Hafs 'an 'Asim
Developer: FrontalMinds Nigeria
Support & Inquiries: princeykarg@gmail.com
```

---

## 3. Store Listing Graphics & Assets (Included in `logos/` Folder)

All images have been generated and formatted to Google Play's exact pixel specifications:

| Asset | Dimensions | File Location |
|---|---|---|
| **App Icon** | **512 x 512 px** (32-bit PNG) | `logos/app_icon_512x512.png` |
| **Feature Graphic** | **1024 x 500 px** (PNG) | `logos/feature_graphic_1024x500.png` |
| **Original Logo** | **512 x 512 px** (PNG) | `logos/logo_original.png` |

---

## 4. Play Console Policy Declarations & Form Answers

### App Category & Tags:
- **Primary Category**: `Music & Audio` (or `Books & Reference`)
- **Tags**: `Quran`, `Religion`, `Music & Audio`, `Audio Player`

### Target Audience & Content:
- **Target Age Group**: `13 and older` (Recommended to avoid COPPA/Families policy complexity)
- **Appeals to Children**: `No`

### Content Rating (IARC Questionnaire):
- **Category**: Utility / Audio / Reference
- **Violence**: No
- **Sexuality / Nudity**: No
- **Profanity / Crude Language**: No
- **Controlled Substances**: No
- **User-to-User Communication**: No
- **Shares Physical Location**: No
- **Digital Purchases**: No
- **Result**: `Everyone / 3+` (PEGI 3, USK 0)

### Data Safety Form:
- **Does your app collect or share any user data?**: **No**
- **Is all data collected ephemeral?**: N/A (No data collected)
- **Is user account creation required?**: **No**
- **Data Encryption in transit**: Yes (All audio streamed over HTTPS)

### Foreground Service Declaration (`FOREGROUND_SERVICE_MEDIA_PLAYBACK`):
When Google Play asks for the purpose of the Foreground Service, copy and paste this exact explanation:
```text
The app uses FOREGROUND_SERVICE_MEDIA_PLAYBACK to provide uninterrupted continuous playback of Holy Quran audio recitations when the screen is locked, when the display turns off, or when the user navigates away from the app. Users control playback directly via Android MediaStyle system notifications and lock screen media controls.
```

### App Access Declaration:
- Select: **"All functionality is available without special access restrictions"** (no credentials, login, or subscriptions needed).

### Government, Financial, News, Health Declarations:
- Select **"No"** to all.

---

## 5. Privacy Policy URL

Google Play **mandates** a live Privacy Policy URL for all apps using audio foreground services.

- **Recommended Hosted URL**: `https://frontalminds.com.ng/privacy`
- A ready-to-upload HTML file is included in this folder: `privacy_policy.html`. You can upload this directly to your server or host it on GitHub Pages.

---

## 6. How to Build the Production Android App Bundle (`.aab`)

Google Play requires an `.aab` file for all submissions.

Run this command in terminal:
```powershell
flutter build appbundle --release
```

The resulting bundle will be generated at:
```text
build/app/outputs/bundle/release/app-release.aab
```
Upload this file to your Google Play Console under **Production** (or **Closed Testing**).
