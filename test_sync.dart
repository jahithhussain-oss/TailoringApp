import 'dart:io';
import 'package:gsheets/gsheets.dart';

void main() async {
  try {
    print('Testing Google Sheets connection...');

    // Read credentials
    final credentialsFile = File('Google_Sheet_tailor.json');
    if (!credentialsFile.existsSync()) {
      print('ERROR: Credentials file not found at Google_Sheet_tailor.json');
      return;
    }

    final credentials = credentialsFile.readAsStringSync();
    print('✓ Credentials file loaded');

    // Initialize GSheets
    final gsheets = GSheets(credentials);
    print('✓ GSheets instance created');

    // Test spreadsheet access
    const spreadsheetId = '1F5eBqi23l7O1PohWzeolFZOgOrsZ9wLBBfT9OvqMaWs';
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);

    if (spreadsheet == null) {
      print('ERROR: Could not access spreadsheet');
      return;
    }

    print('✓ Spreadsheet accessed successfully');
    print('Available worksheets:');

    for (final sheet in spreadsheet.sheets) {
      // print('  - ${sheet.title}');
    }

    // Test worksheet access
    final requiredSheets = [
      'customers',
      'orders',
      'order_details',
      'measurements',
      'shops',
      'item_types',
    ];

    for (final sheetName in requiredSheets) {
      final worksheet = spreadsheet.worksheetByTitle(sheetName);
      if (worksheet != null) {
        print('✓ Worksheet "$sheetName" exists');

        // Try to read first row
        try {
          final firstRow = await worksheet.values.row(1);
          print(
            '  Headers: ${firstRow.map((cell) => cell.toString()).toList()}',
          );
        } catch (e) {
          print('  Warning: Could not read headers - $e');
        }
      } else {
        print('✗ Worksheet "$sheetName" does not exist');
      }
    }

    print('\n✓ Google Sheets connection test completed successfully!');
  } catch (e) {
    print('ERROR: $e');
  }
}
