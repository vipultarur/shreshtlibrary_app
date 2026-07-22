# Google Play Store Release Guide

This guide details all necessary steps to build, sign, and publish the **Shresht Library Student App** (`com.tarurinfotech.shreshtlibrary`) to the Google Play Store.

---

## Prerequisites

1. **Google Play Developer Account**: A registered Google Play Console account ($25 one-time registration fee).
2. **Java Development Kit (JDK)**: `keytool` is included with JDK 17 / Android Studio.
3. **Flutter SDK**: Ensure `flutter doctor` confirms Android toolchain readiness.

---

## Step 1: Generate Release Keystore

The Google Play Store requires every app bundle (`.aab`) to be digitally signed with a private signing key.

### Windows (PowerShell or Command Prompt)
Run the following command in your terminal (replace passwords and alias as desired):

```powershell
keytool -genkey -v -keystore android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> [!CAUTION]
> **Store your `.jks` file and passwords securely!** If you lose your keystore file or passwords, you will NOT be able to push app updates to Google Play unless Play Key Signing reset is requested.

---

## Step 2: Configure `key.properties`

1. Create a copy of `android/key.properties.example` and name it `android/key.properties`:

   ```bash
   cp android/key.properties.example android/key.properties
   ```

2. Open `android/key.properties` and replace the placeholder values with your keystore credentials:

   ```properties
   storePassword=your_keystore_password
   keyPassword=your_key_password
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

> [!NOTE]
> `android/key.properties` and `*.jks` files are ignored by `.gitignore` and will never be committed to Git.

---

## Step 3: Manage App Versioning

Before each release, update the version in `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

- `1.0.0`: User-facing version name (`versionName`).
- `+1`: Internal build number (`versionCode`). Must be incremented by +1 for every release upload on Google Play Console (e.g. `1.0.0+2`, `1.0.1+3`).

---

## Step 4: Build the Android App Bundle (.aab)

Google Play Store requires an **Android App Bundle (.aab)** for publication.

Run the following release build command in the project root:

```bash
flutter build appbundle --release
```

To pass a custom production backend URL at build time if needed:

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://shreshtlibrary.onrender.com/api/v1
```

### Build Artifact Location
The output signed AAB file will be generated at:
`build/app/outputs/bundle/release/app-release.aab`

---

## Step 5: Uploading to Google Play Console

1. Log into [Google Play Console](https://play.google.com/console).
2. Click **Create app**:
   - **App name**: Shresht Library
   - **Default language**: English (or preferred default)
   - **App or game**: App
   - **Free or paid**: Free (or your monetization model)
3. Navigate to **Testing > Internal testing** (recommended for initial verification) or **Production**.
4. Click **Create new release** and upload `build/app/outputs/bundle/release/app-release.aab`.
5. Complete required Play Console sections:
   - **App Content**: Complete Data Safety, Target Audience, News App, and Government Apps questionnaires.
   - **Store Listing**:
     - **Short Description**: High performance student learning & library management app.
     - **Full Description**: Comprehensive description of Shresht Library features, study tracking, digital ID, QR scanning, and subscription management.
     - **Graphics Assets**:
       - App Icon: 512 x 512 px PNG (32-bit color, max 1024KB)
       - Feature Graphic: 1024 x 500 px PNG or JPEG
       - Phone Screenshots: At least 2 screenshots (min 320px, max 3840px)
       - 7-inch & 10-inch Tablet Screenshots (if supporting tablet devices)
   - **Privacy Policy**: Provide a valid URL to your published privacy policy.

6. Review and launch the release!

---

## Troubleshooting & Maintenance

- **R8 / ProGuard Obfuscation**: ProGuard keep rules are configured in `android/app/proguard-rules.pro`. If third-party plugins throw `ClassNotFoundException` in release mode, add keep rules for that package.
- **Deep Links & App Links**: `AndroidManifest.xml` is configured for `shreshtlibrary.onrender.com` scheme. To verify Android App Links ownership, place `.well-known/assetlinks.json` on your web domain matching your keystore SHA-256 fingerprint.
