# Mobile APK Setup Guide for Google Sheets Sync

## Issue: "Google Sheets service is not initialized" on Mobile APK

This error occurs because mobile apps can't access files using relative paths the same way as desktop applications. The credentials file needs to be included as an asset in the Flutter app bundle.

## ✅ **Solution Implemented**

I've fixed the issue by:

1. **Moving credentials to assets folder** - `assets/Google_Sheet_tailor.json`
2. **Updated pubspec.yaml** - Added assets configuration
3. **Enhanced Google Sheets service** - Now loads from assets on mobile, fallback to file system on desktop
4. **Improved error handling** - Better mobile-specific error messages

## 📱 **Steps to Deploy Fixed APK**

### 1. **Clean and Rebuild**
```bash
cd tailoringapp
flutter clean
flutter pub get
```

### 2. **Build APK**
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

### 3. **Install APK**
```bash
# Install debug APK
flutter install

# Or manually install the APK file from:
# build/app/outputs/flutter-apk/app-debug.apk
```

## 🔧 **What Was Fixed**

### **Before (Broken on Mobile):**
```dart
// This only works on desktop/debug
final credentialsFile = File('Google_Sheet_tailor.json');
final credentials = credentialsFile.readAsStringSync();
```

### **After (Works on Mobile):**
```dart
// Try assets first (mobile), fallback to file system (desktop)
try {
  credentials = await rootBundle.loadString('assets/Google_Sheet_tailor.json');
} catch (e) {
  // Fallback for desktop/debug
  final credentialsFile = File(_credentialsPath);
  credentials = credentialsFile.readAsStringSync();
}
```

## 📋 **Files Modified**

1. **`pubspec.yaml`** - Added assets configuration
2. **`assets/Google_Sheet_tailor.json`** - Moved credentials to assets folder
3. **`lib/src/services/google_sheets_service.dart`** - Enhanced to load from assets
4. **`lib/src/screens/dashboard/dashboard_screen.dart`** - Better mobile error messages
5. **`debug_sync.dart`** - Updated to handle assets loading

## 🧪 **Testing the Fix**

### **Test on Mobile Device:**
1. Install the new APK
2. Open the app
3. Go to Dashboard
4. Click "Test Connection" - should show green success message
5. Click "Sync Data" - should work without "service not initialized" error

### **Expected Behavior:**
- ✅ **Success**: Green "Google Sheets connected successfully" message
- ✅ **Sync**: Data syncs to Google Sheets without errors
- ✅ **Error Handling**: Clear error messages if something is wrong

## 🔍 **Troubleshooting Mobile Issues**

### **If sync still fails after APK update:**

1. **Check Console Logs**
   - Look for "Credentials loaded from assets successfully"
   - Verify no "Credentials file not found" errors

2. **Verify Assets Configuration**
   ```yaml
   # In pubspec.yaml
   flutter:
     assets:
       - assets/Google_Sheet_tailor.json
   ```

3. **Check Google Sheets Setup**
   - Share sheet with: `tailoringdata@nth-bucksaw-369914.iam.gserviceaccount.com`
   - Ensure all required worksheets exist
   - Verify headers are correct

4. **Network Issues**
   - Ensure device has internet connection
   - Check if corporate firewall blocks Google APIs

## 📊 **Debug Information**

The app now provides detailed logging:
- **Mobile**: "Credentials loaded from assets successfully"
- **Desktop**: "Credentials file loaded from file system successfully"
- **Error**: Specific error messages with troubleshooting steps

## 🚀 **Next Steps**

1. **Build new APK** with the fixes
2. **Install on mobile device**
3. **Test sync functionality**
4. **Verify data appears in Google Sheets**

The "Google Sheets service is not initialized" error should now be resolved for mobile APK installations.

## 📞 **Support**

If issues persist after following this guide:
1. Check console logs for specific error messages
2. Verify all setup steps were completed
3. Test with a fresh Google Sheet
4. Ensure internet connectivity on mobile device

