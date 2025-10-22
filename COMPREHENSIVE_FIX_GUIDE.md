# Fix: "Google sheet setup: configuration error: Google sheet is not available"

## 🚨 **Current Issue**
You're getting "Google sheet setup: configuration error: Google sheet is not available" which means the Google Sheets service isn't initializing properly.

## 🔍 **Diagnostic Steps**

### **Step 1: Check Console Logs**
Look for these specific error messages in your console:

1. **If you see:** `❌ Failed to load from assets: [error]`
   - **Cause:** Assets not properly included in APK
   - **Fix:** Rebuild APK (see Step 2 below)

2. **If you see:** `Failed to access spreadsheet [ID]`
   - **Cause:** Spreadsheet permissions issue
   - **Fix:** Share spreadsheet with service account (see Step 3 below)

3. **If you see:** `Authentication failed` or `API not enabled`
   - **Cause:** Google Sheets API not enabled
   - **Fix:** Enable Google Sheets API (see Step 4 below)

### **Step 2: Fix Assets Loading (Most Common)**
```bash
cd tailoringapp
flutter clean
flutter pub get
flutter build apk --debug
flutter install
```

### **Step 3: Fix Spreadsheet Permissions**
1. Go to your Google Sheet: https://docs.google.com/spreadsheets/d/1F5eBqi23l7O1PohWzeolFZOgOrsZ9wLBBfT9OvqMaWs/edit
2. Click "Share" button
3. Add this email with "Editor" permissions:
   ```
   tailoringdata@nth-bucksaw-369914.iam.gserviceaccount.com
   ```

### **Step 4: Enable Google Sheets API**
1. Go to Google Cloud Console: https://console.cloud.google.com/
2. Select project: "nth-bucksaw-369914"
3. Go to "APIs & Services" > "Library"
4. Search for "Google Sheets API"
5. Click "Enable"

## 🧪 **Testing Steps**

### **Test 1: Assets Loading**
```bash
dart simple_test.dart
```
Should show: "✅ Assets loaded successfully"

### **Test 2: App Logs**
1. Run your app
2. Go to Dashboard
3. Check console logs for:
   - "✅ Credentials loaded from assets successfully"
   - "Google Sheets service initialized successfully"

### **Test 3: Connection Test**
1. In app, click "Test Connection" button
2. Should show detailed connection status

## 📱 **Expected Behavior After Fix**

### **Success Logs:**
```
Initializing Google Sheets service...
Credentials path: Google_Sheet_tailor.json
Spreadsheet ID: 1F5eBqi23l7O1PohWzeolFZOgOrsZ9wLBBfT9OvqMaWs
✅ Credentials loaded from assets successfully
GSheets instance created
Spreadsheet accessed: 1F5eBqi23l7O1PohWzeolFZOgOrsZ9wLBBfT9OvqMaWs
Google Sheets service initialized successfully
Available worksheets: [customers, orders, order_details, measurements, shops, item_types]
```

### **Success UI:**
- ✅ Green "Google Sheets connected successfully" message
- ✅ "Test Connection" shows detailed status
- ✅ "Sync Data" works without errors

## 🚫 **Common Issues & Solutions**

### **Issue 1: "Assets not loaded properly"**
**Solution:**
```bash
flutter clean
flutter pub get
flutter build apk --debug
flutter install
```

### **Issue 2: "Failed to access spreadsheet"**
**Solution:**
1. Share Google Sheet with service account email
2. Give "Editor" permissions
3. Check spreadsheet ID is correct

### **Issue 3: "Authentication failed"**
**Solution:**
1. Enable Google Sheets API in Google Cloud Console
2. Check service account credentials are valid
3. Verify internet connectivity

### **Issue 4: "Service not initialized"**
**Solution:**
1. Check console logs for specific error
2. Follow appropriate fix above
3. Rebuild and reinstall APK

## 📋 **Complete Fix Checklist**

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Build new APK with `flutter build apk --debug`
- [ ] Install new APK with `flutter install`
- [ ] Share Google Sheet with service account email
- [ ] Enable Google Sheets API in Google Cloud Console
- [ ] Test assets loading with `dart simple_test.dart`
- [ ] Check app console logs for success messages
- [ ] Test "Test Connection" button in app
- [ ] Verify green success message appears

## 🎯 **Most Likely Cause**

Based on the error message, the most likely cause is **assets not properly loaded in the APK**. 

**Quick Fix:**
```bash
flutter clean && flutter pub get && flutter build apk --debug && flutter install
```

## 📞 **Still Having Issues?**

If the problem persists after following all steps:

1. **Check console logs** - Look for the specific error message
2. **Verify you're running the NEW APK** - Make sure you installed the rebuilt version
3. **Test on different device** - Rule out device-specific issues
4. **Check internet connection** - Ensure device can access Google APIs
5. **Verify Google Cloud project settings** - Make sure APIs are enabled

The error message will now be more specific and help identify the exact issue!

