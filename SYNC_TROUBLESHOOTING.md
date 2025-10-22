# Google Sheets Sync Troubleshooting Guide

## Current Issues and Solutions

### Issue 1: Google Sheets Service Not Initializing

**Symptoms:**
- "Google Sheets service not initialized" error message
- No error messages shown when sync fails silently

**Solutions:**

1. **Check Credentials File Location**
   ```bash
   # Make sure the file exists in the project root
   ls -la Google_Sheet_tailor.json
   ```

2. **Verify Service Account Access**
   - Go to your Google Sheet: https://docs.google.com/spreadsheets/d/1F5eBqi23l7O1PohWzeolFZOgOrsZ9wLBBfT9OvqMaWs/edit
   - Click "Share" button
   - Add this email with "Editor" permissions:
     ```
     tailoringdata@nth-bucksaw-369914.iam.gserviceaccount.com
     ```

3. **Test Connection**
   - Run the debug script: `dart debug_sync.dart`
   - Check console output for detailed error messages

### Issue 2: Missing Worksheets

**Symptoms:**
- Sync fails with "Worksheet not found" errors
- Some tables sync but others don't

**Required Worksheets:**
- `customers`
- `orders`
- `order_details`
- `measurements`
- `shops`
- `item_types`

**Solution:**
1. Create missing worksheets in your Google Sheet
2. Add proper headers to each worksheet (see headers below)

### Issue 3: Incorrect Headers

**Symptoms:**
- Data syncs but appears in wrong columns
- Headers mismatch errors

**Required Headers for Each Worksheet:**

#### Customers Worksheet
```
id | name | phone | location | createdAt | lastModified
```

#### Orders Worksheet
```
id | orderNumber | customerId | orderDate | dueDate | location | noOfPs | totalPrice | status | totalPieces | createdAt | lastModified
```

#### Order Details Worksheet
```
id | orderId | itemTypeId | itemDetail | noOfPs | price | measurementType | createdAt | lastModified
```

#### Measurements Worksheet
```
id | customerId | itemTypeId | length | shoulder | slLoose | armHole | chest | hip | point | seat | fNeck | bNeck | bottomLength | bottomWaist | bottom | createdAt | lastModified
```

#### Shops Worksheet
```
id | name | location | phone | createdAt | lastModified
```

#### Item Types Worksheet
```
id | type | shortName | description
```

### Issue 4: Authentication Problems

**Symptoms:**
- "Authentication failed" errors
- "Service account access denied" errors

**Solutions:**

1. **Verify Service Account JSON**
   - Check that `Google_Sheet_tailor.json` is valid JSON
   - Ensure all required fields are present

2. **Check Project Permissions**
   - Go to Google Cloud Console
   - Navigate to IAM & Admin > Service Accounts
   - Verify the service account exists and is active

3. **Enable Google Sheets API**
   - Go to Google Cloud Console
   - Navigate to APIs & Services > Library
   - Search for "Google Sheets API" and enable it

### Issue 5: Network/Connectivity Issues

**Symptoms:**
- Timeout errors
- Network connection failures

**Solutions:**

1. **Check Internet Connection**
   - Ensure device has stable internet access
   - Try accessing Google Sheets in browser

2. **Firewall/Proxy Issues**
   - Check if corporate firewall blocks Google APIs
   - Configure proxy settings if needed

## Debugging Steps

### Step 1: Run Debug Script
```bash
cd tailoringapp
dart debug_sync.dart
```

### Step 2: Check Console Logs
Look for these log messages in your app:
- "Google Sheets service initialized successfully"
- "Syncing [table_name]..."
- "Error syncing [table_name]: [error_message]"

### Step 3: Test Individual Components
1. Test connection using "Test Connection" button in app
2. Try syncing one table at a time
3. Check if data exists in local database

### Step 4: Verify Data Flow
1. Create test data in app
2. Check if it appears in local database
3. Attempt sync to Google Sheets
4. Verify data appears in Google Sheets

## Common Error Messages and Solutions

### "Credentials file not found"
- **Solution:** Move `Google_Sheet_tailor.json` to project root directory

### "Failed to access spreadsheet"
- **Solution:** Check spreadsheet ID and ensure service account has access

### "Worksheet not found"
- **Solution:** Create missing worksheets with correct names and headers

### "Headers mismatch"
- **Solution:** Update worksheet headers to match the required format

### "Authentication failed"
- **Solution:** Verify service account JSON and Google Sheets API access

## Testing the Fix

1. **Run the app**
2. **Go to Dashboard**
3. **Click "Test Connection"** - should show green success message
4. **Click "Sync Data"** - should show detailed results
5. **Check Google Sheets** - data should appear in correct worksheets

## Getting Help

If issues persist:

1. Run `dart debug_sync.dart` and share the output
2. Check console logs in your app
3. Verify all setup steps were completed
4. Test with a fresh Google Sheet to isolate issues

## Quick Setup Checklist

- [ ] `Google_Sheet_tailor.json` file exists in project root
- [ ] Google Sheets API is enabled in Google Cloud Console
- [ ] Service account email is shared with Google Sheet
- [ ] All required worksheets exist with correct headers
- [ ] Spreadsheet ID is correct in dashboard_screen.dart
- [ ] Internet connection is stable
- [ ] App has been restarted after configuration changes

