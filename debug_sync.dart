import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
import 'package:tailoringapp/src/services/google_sheets_service.dart';
import 'package:tailoringapp/src/services/db_service.dart';

void main() async {
  print('=== Google Sheets Sync Debug Script ===\n');

  try {
    // Step 1: Check credentials file
    print('1. Checking credentials file...');

    String credentials;
    bool loadedFromAssets = false;

    // Try to load from assets first (for mobile)
    try {
      credentials = await rootBundle.loadString(
        'assets/Google_Sheet_tailor.json',
      );
      print('✅ Credentials loaded from assets successfully');
      loadedFromAssets = true;
    } catch (e) {
      print('⚠️  Failed to load from assets, trying file system: $e');

      // Fallback to file system (for desktop/debug)
      final credentialsFile = File('Google_Sheet_tailor.json');
      if (!credentialsFile.existsSync()) {
        print(
          '❌ ERROR: Credentials file not found at Google_Sheet_tailor.json',
        );
        print(
          '   Make sure the file exists in the project root directory or assets folder.',
        );
        return;
      }
      credentials = credentialsFile.readAsStringSync();
      print('✅ Credentials file loaded from file system');
    }

    // Step 2: Test basic GSheets connection
    print('\n2. Testing basic GSheets connection...');
    final gsheets = GSheets(credentials);
    print('✅ GSheets instance created');

    // Step 3: Test spreadsheet access
    print('\n3. Testing spreadsheet access...');
    const spreadsheetId = '1F5eBqi23l7O1PohWzeolFZOgOrsZ9wLBBfT9OvqMaWs';
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);

    try {
      // Try to access the spreadsheet to verify it's accessible
      final sheets = spreadsheet.sheets;
      print('✅ Spreadsheet accessed successfully');
    } catch (e) {
      print('❌ ERROR: Could not access spreadsheet $spreadsheetId');
      print('   Error: $e');
      print('   Possible issues:');
      print('   - Spreadsheet ID is incorrect');
      print('   - Service account does not have access');
      print('   - Service account email not shared with spreadsheet');
      print('   - Network connectivity issues');
      return;
    }

    // Step 4: Check required worksheets
    print('\n4. Checking required worksheets...');
    final requiredSheets = [
      'customers',
      'orders',
      'order_details',
      'measurements',
      'shops',
      'item_types',
    ];
    final availableSheets = spreadsheet.sheets.map((s) => s.title).toList();

    print('Available worksheets: $availableSheets');

    for (final sheetName in requiredSheets) {
      if (availableSheets.contains(sheetName)) {
        print('✅ Worksheet "$sheetName" exists');

        // Check headers
        try {
          final worksheet = spreadsheet.worksheetByTitle(sheetName);
          final firstRow = await worksheet!.values.row(1);
          print(
            '   Headers: ${firstRow.map((cell) => cell.toString()).toList()}',
          );
        } catch (e) {
          print('   ⚠️  Warning: Could not read headers - $e');
        }
      } else {
        print('❌ Worksheet "$sheetName" is missing');
      }
    }

    // Step 5: Test GoogleSheetsService initialization
    print('\n5. Testing GoogleSheetsService initialization...');
    final sheetsService = GoogleSheetsService(
      'Google_Sheet_tailor.json',
      spreadsheetId,
    );
    await sheetsService.init();
    print('✅ GoogleSheetsService initialized successfully');

    // Step 6: Test database connection
    print('\n6. Testing database connection...');
    await DBService.database;
    print('✅ Database connection successful');

    // Step 7: Check for existing data
    print('\n7. Checking existing data...');
    final customers = await DBService.getAllCustomers();
    final orders = await DBService.getAllOrders();
    final measurements = await DBService.getAllMeasurements();
    final shops = await DBService.getAllShops();
    final itemTypes = await DBService.getAllItemTypes();

    print('   Customers: ${customers.length}');
    print('   Orders: ${orders.length}');
    print('   Measurements: ${measurements.length}');
    print('   Shops: ${shops.length}');
    print('   Item Types: ${itemTypes.length}');

    // Step 8: Test sync functionality
    print('\n8. Testing sync functionality...');
    try {
      final result = await sheetsService.syncAllData(
        getLastSyncTime: (table) async => '2000-01-01T00:00:00Z',
        setLastSyncTime: (table, time) async {},
      );

      print('✅ Sync test completed');
      print('Results: $result');

      final successCount = result.entries.where((e) => e.value == 'ok').length;
      final errorCount = result.entries.where((e) => e.value == 'error').length;

      print('\nSync Summary:');
      print('   Successful tables: $successCount');
      print('   Failed tables: $errorCount');

      if (errorCount > 0) {
        print('\nErrors:');
        result.entries.where((e) => e.value == 'error').forEach((e) {
          print('   ${e.key}: ${e.value}');
        });
      }
    } catch (e) {
      print('❌ Sync test failed: $e');
    }

    print('\n=== Debug completed ===');
  } catch (e) {
    print('❌ CRITICAL ERROR: $e');
    print('\nStack trace:');
    print(e);
  }
}
