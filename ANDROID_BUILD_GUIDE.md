# Kisan Sahayak - Android Build Guide

## 📱 Release APK Configuration

### ✅ Configured Settings

- **App Name:** Kisan Sahayak
- **Package ID:** com.kisan.sahayak
- **Version:** 1.0.0 (Build 1)
- **Min SDK:** 21 (Android 5.0 Lollipop)
- **Target SDK:** 34 (Android 14)

### ✅ Build Optimizations

- ✓ Code minification enabled
- ✓ Resource shrinking enabled
- ✓ ProGuard rules configured
- ✓ Debug logging removed in release
- ✓ MultiDex enabled
- ✓ Tree-shake icons enabled

### 🔨 Build Commands

#### Standard Release APK
```powershell
cd D:\project\FKS\fks_app
flutter clean
flutter pub get
flutter build apk --release --tree-shake-icons
```

#### Split APK by ABI (Smaller size)
```powershell
flutter build apk --release --split-per-abi --tree-shake-icons
```

This generates separate APKs for:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM - Most modern phones)
- `app-x86_64-release.apk` (64-bit x86 - Emulators)

### 📦 APK Output Location

```
build\app\outputs\flutter-apk\app-release.apk
```

For split APKs:
```
build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
build\app\outputs\flutter-apk\app-x86_64-release.apk
```

### 📲 Installation on Android Device

1. **Enable installation from unknown sources:**
   - Settings → Security → Install unknown apps
   - Select file manager or Chrome
   - Allow from this source

2. **Transfer APK to phone:**
   - USB cable
   - WhatsApp/Email
   - Cloud storage (Google Drive, etc.)

3. **Install:**
   - Tap the APK file
   - Click "Install"
   - Open app

### 🔍 APK Size Optimization

Expected sizes:
- **Standard APK:** 25-35 MB
- **Split APK (arm64-v8a):** 15-20 MB

### 🐛 Troubleshooting

#### Build fails with "gradlew not found"
```powershell
cd android
./gradlew clean
cd ..
flutter build apk --release
```

#### Permission denied on gradlew
```powershell
cd android
icacls gradlew /grant Everyone:F
cd ..
```

#### Out of memory error
```powershell
flutter build apk --release --no-tree-shake-icons
```

### 🚀 Quick Build Script

Create `build-release.ps1`:
```powershell
# Build Release APK
Write-Host "🚀 Building Kisan Sahayak Release APK..." -ForegroundColor Green

Set-Location "D:\project\FKS\fks_app"

Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
flutter clean

Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "🔨 Building release APK..." -ForegroundColor Yellow
flutter build apk --release --tree-shake-icons

Write-Host "✅ Build complete!" -ForegroundColor Green
Write-Host "📱 APK Location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
```

Run: `.\build-release.ps1`

### 📋 Checklist

- [x] Package name changed from com.example to com.kisan.sahayak
- [x] App name set to "Kisan Sahayak"
- [x] Version updated to 1.0.0
- [x] Min SDK set to 21
- [x] Target SDK set to 34
- [x] Minify enabled
- [x] Shrink resources enabled
- [x] Debug mode disabled
- [x] ProGuard rules configured
- [x] Icon configured with adaptive icon support
- [x] MultiDex enabled

### 🎯 Production Ready!

Your app is now configured for production release. The APK will:
- ✓ Work on Android 5.0 and above
- ✓ Have optimized size
- ✓ No debug banner
- ✓ Better performance
- ✓ Installable on physical devices
