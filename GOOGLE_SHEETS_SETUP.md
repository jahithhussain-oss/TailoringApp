# Google Sheets Sync Setup Guide

## Why Data is Not Syncing to Google Sheets

The sync is not working because of missing configuration. Here's how to fix it:

## Step 1: Create a Google Sheet

1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new spreadsheet
3. Name it "Tailoring App Data" (or any name you prefer)
4. Copy the **Spreadsheet ID** from the URL:
   ```
   https://docs.google.com/spreadsheets/d/SPREADSHEET_ID_HERE/edit
   ```

## Step 2: Create Required Worksheets

In your Google Sheet, create these worksheets (tabs):
- `customers`
- `orders` 
- `order_details`
- `measurements`
- `shops`
- `item_types` (optional - for reference)

## Step 3: Add Headers to Each Worksheet

### Customers Worksheet
Add these headers in row 1:
```
id | name | phone | location | createdAt | lastModified
```

### Orders Worksheet  
Add these headers in row 1:
```
id | orderNumber | customerId | orderDate | dueDate | location | noOfPs | totalPrice | status | totalPieces | createdAt | lastModified
```

### Order Details Worksheet
Add these headers in row 1:
```
id | orderId | itemTypeId | itemDetail | noOfPs | price | measurementType | createdAt | lastModified
```

### Measurements Worksheet
Add these headers in row 1:
```
id | customerId | itemTypeId | length | shoulder | slLoose | armHole | chest | hip | point | seat | fNeck | bNeck | bottomLength | bottomWaist | bottom | createdAt | lastModified
```

### Shops Worksheet
Add these headers in row 1:
```
id | name | location | phone | createdAt | lastModified
```

### Item Types Worksheet (Optional)
Add these headers in row 1:
```
id | type | shortName | description
```

**Note**: The app will automatically create default item types (Shirt, Pant, Suit, Blouse, Dress, Skirt) if none exist. You can sync these to Google Sheets for reference.

## Step 4: Update App Configuration

1. Open `tailoringapp/lib/src/screens/dashboard/dashboard_screen.dart`
2. Find line 61: `'your_spreadsheet_id'`
3. Replace it with your actual Spreadsheet ID:
   ```dart
   'your_actual_spreadsheet_id_here'
   ```

## Step 5: Share Google Sheet with Service Account

1. In your Google Sheet, click "Share" button
2. Add this email address with "Editor" permissions:
   ```
   tailoringdata@nth-bucksaw-369914.iam.gserviceaccount.com
   ```

## Step 6: Test the Sync

1. Run your app
2. Go to Dashboard
3. Click "Sync Data" button
4. Check for success/error messages

## Common Issues

### "Google Sheets service not initialized"
- Check if `Google_Sheet_tailor.json` file exists in the project root
- Verify the spreadsheet ID is correct

### "Failed to access spreadsheet"
- Make sure you shared the sheet with the service account email
- Check if the spreadsheet ID is correct

### "Worksheet not found"
- Make sure all required worksheets exist with exact names
- Check if headers are in row 1

### "Authentication failed"
- Verify the service account JSON file is valid
- Check if the service account has proper permissions

## Troubleshooting

1. **Check console logs** for detailed error messages
2. **Verify spreadsheet ID** in the URL matches your configuration
3. **Test with a simple sheet** first (just customers table)
4. **Check internet connection** - sync requires internet access

## Example Spreadsheet ID
```
1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms
```

Replace `your_spreadsheet_id` with your actual ID (without quotes in the code).
