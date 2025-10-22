// google_sheets_service.dart
// Service for handling data operations with Google Sheets API.

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
import 'package:tailoringapp/src/models/customer.dart';
import 'package:tailoringapp/src/services/db_service.dart';
import 'package:tailoringapp/src/models/order.dart';
import 'package:tailoringapp/src/models/measurements.dart';
import 'package:tailoringapp/src/models/shop.dart';

class GoogleSheetsService {
  final String _credentialsPath;
  final String _spreadsheetId;
  late GSheets _gsheets;
  Spreadsheet? _spreadsheet;

  GoogleSheetsService(this._credentialsPath, this._spreadsheetId);

  Future<void> init() async {
    try {
      print('Initializing Google Sheets service...');
      print('Credentials path: $_credentialsPath');
      print('Spreadsheet ID: $_spreadsheetId');

      String credentials;

      // Try to load from assets first (for mobile)
      try {
        credentials = await rootBundle.loadString(
          'assets/Google_Sheet_tailor.json',
        );
        print('✅ Credentials loaded from assets successfully');
      } catch (e) {
        // Fallback to file system (for desktop/debug)
        print('⚠️ Failed to load from assets: $e');
        print('Trying file system fallback...');

        final credentialsFile = File(_credentialsPath);
        if (!credentialsFile.existsSync()) {
          throw Exception(
            'Google Sheets credentials not found!\n\n'
            'Mobile/APK: Assets not loaded properly. Run:\n'
            '  flutter clean\n'
            '  flutter pub get\n'
            '  flutter build apk\n\n'
            'Desktop/Debug: File not found at $_credentialsPath\n\n'
            'Make sure Google_Sheet_tailor.json exists in assets folder.',
          );
        }
        credentials = credentialsFile.readAsStringSync();
        print('✅ Credentials file loaded from file system successfully');
      }

      _gsheets = GSheets(credentials);
      print('GSheets instance created');

      _spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
      print('Spreadsheet accessed: $_spreadsheetId');

      if (_spreadsheet == null) {
        throw Exception(
          'Failed to access spreadsheet $_spreadsheetId. Check if:\n'
          '1. Spreadsheet ID is correct\n'
          '2. Service account has access to the spreadsheet\n'
          '3. Service account email is shared with the spreadsheet',
        );
      }

      print('Google Sheets service initialized successfully');
      print(
        'Available worksheets: ${_spreadsheet!.sheets.map((s) => s.title).toList()}',
      );
    } catch (e) {
      print('Failed to initialize Google Sheets service: $e');
      rethrow;
    }
  }

  Worksheet? getWorksheetByTitle(String title) {
    return _spreadsheet?.worksheetByTitle(title);
  }

  /// Ensure a worksheet exists with proper headers
  Future<void> _ensureWorksheetExists(
    String title,
    List<String> headers,
  ) async {
    if (_spreadsheet == null) {
      throw Exception('Spreadsheet not initialized');
    }

    Worksheet? worksheet = getWorksheetByTitle(title);

    if (worksheet == null) {
      print('Creating worksheet: $title');
      worksheet = await _spreadsheet!.addWorksheet(title);
    }

    // Check if headers exist
    try {
      final firstRow = await worksheet.values.row(1);
      if (firstRow.isEmpty) {
        print('Adding headers to worksheet: $title');
        await worksheet.values.insertRow(1, headers);
      } else {
        // Verify headers match
        final existingHeaders = firstRow
            .map((cell) => cell.toString())
            .toList();
        if (existingHeaders.length != headers.length ||
            !existingHeaders.every((h) => headers.contains(h))) {
          print(
            'Headers mismatch for $title. Expected: $headers, Found: $existingHeaders',
          );
          // You might want to update headers or handle this differently
        }
      }
    } catch (e) {
      print('Error checking/creating headers for $title: $e');
      // Try to add headers anyway
      try {
        await worksheet.values.insertRow(1, headers);
      } catch (e2) {
        print('Failed to add headers to $title: $e2');
        rethrow;
      }
    }
  }

  /// Test method to verify Google Sheets connection and worksheets
  Future<Map<String, dynamic>> testConnection() async {
    final result = <String, dynamic>{};

    try {
      if (_spreadsheet == null) {
        result['error'] = 'Spreadsheet not initialized';
        return result;
      }

      result['spreadsheet_title'] = _spreadsheet!.sheets;
      result['worksheets'] = <String>[];

      // Check if required worksheets exist
      final requiredSheets = [
        'customers',
        'orders',
        'order_details',
        'measurements',
        'shops',
        'item_types',
      ];

      for (final sheetName in requiredSheets) {
        final worksheet = getWorksheetByTitle(sheetName);
        if (worksheet != null) {
          result['worksheets'].add('$sheetName: OK');

          // Try to read first row to check headers
          try {
            final firstRow = await worksheet.values.row(1);
            result['${sheetName}_headers'] = firstRow.length;
          } catch (e) {
            result['${sheetName}_headers'] = 'Error reading headers: $e';
          }
        } else {
          result['worksheets'].add('$sheetName: MISSING');
        }
      }

      result['status'] = 'Connection successful';
    } catch (e) {
      result['error'] = e.toString();
      result['status'] = 'Connection failed';
    }

    return result;
  }

  Future<List<Map<String, String>>> readAllRows(String worksheetTitle) async {
    final sheet = getWorksheetByTitle(worksheetTitle);
    if (sheet == null) return [];
    final rows = await sheet.values.map.allRows();
    return rows ?? [];
  }

  Future<bool> addRow(String worksheetTitle, List<String> row) async {
    final sheet = getWorksheetByTitle(worksheetTitle);
    if (sheet == null) return false;
    return await sheet.values.appendRow(row);
  }

  Future<bool> updateRow(
    String worksheetTitle,
    int rowIndex,
    List<String> row,
  ) async {
    final sheet = getWorksheetByTitle(worksheetTitle);
    if (sheet == null) return false;
    // rowIndex is 0-based for data, but 1-based in Sheets (header is row 1)
    return await sheet.values.insertRow(rowIndex + 2, row); // +2 for header
  }

  Future<bool> deleteRow(String worksheetTitle, int rowIndex) async {
    final sheet = getWorksheetByTitle(worksheetTitle);
    if (sheet == null) return false;
    return await sheet.deleteRow(rowIndex + 2); // +2 for header
  }

  /// Upsert (insert or update) a row by unique [id] in the worksheet.
  Future<bool> upsertRowById(
    String worksheetTitle,
    String id,
    List<String> headers,
    List<String> row,
  ) async {
    final sheet = getWorksheetByTitle(worksheetTitle);
    if (sheet == null) return false;
    final allRows = await sheet.values.map.allRows();
    if (allRows == null) return false;
    final idx = allRows.indexWhere((r) => r['id'] == id);
    if (idx == -1) {
      // Insert new row
      return await sheet.values.appendRow(row);
    } else {
      // Update existing row (row index in Sheets is +2: header + 1-based)
      return await sheet.values.insertRow(idx + 2, row);
    }
  }

  /// Fetch all rows modified after [lastModified] (ISO8601 string)
  Future<List<Map<String, String>>> fetchRowsModifiedAfter(
    String worksheetTitle,
    String lastModified,
  ) async {
    final rows = await readAllRows(worksheetTitle);
    return rows.where((row) {
      final mod = row['lastModified'];
      return mod != null && mod.compareTo(lastModified) > 0;
    }).toList();
  }

  /// Bulk upsert rows by [id] (assumes each row has 'id' and 'lastModified')
  Future<void> bulkUpsertRowsById(
    String worksheetTitle,
    List<String> headers,
    List<List<String>> rows,
  ) async {
    final sheet = getWorksheetByTitle(worksheetTitle);
    if (sheet == null) return;
    final allRows = await sheet.values.map.allRows() ?? [];
    for (final row in rows) {
      final idIdx = headers.indexOf('id');
      if (idIdx == -1) continue;
      final id = row[idIdx];
      final idx = allRows.indexWhere((r) => r['id'] == id);
      if (idx == -1) {
        await sheet.values.appendRow(row);
      } else {
        await sheet.values.insertRow(idx + 2, row);
      }
    }
  }

  /// --- High-level sync stubs ---
  /// Call these from your app logic, passing DBService as needed.

  /// Sync from Google Sheets to SQLite (download new/updated rows)
  Future<void> syncFromSheetsToSQLite({
    required String worksheetTitle,
    required List<String> headers,
    required Future<String> Function()
    getLastSyncTime, // returns ISO8601 string
    required Future<void> Function(List<Map<String, String>>)
    upsertToSQLite, // upsert rows in SQLite
  }) async {
    final lastSync = await getLastSyncTime();
    final newRows = await fetchRowsModifiedAfter(worksheetTitle, lastSync);
    await upsertToSQLite(newRows);
  }

  /// Sync from SQLite to Google Sheets (upload new/updated rows)
  Future<void> syncFromSQLiteToSheets({
    required String worksheetTitle,
    required List<String> headers,
    required Future<List<Map<String, dynamic>>> Function()
    getLocalChanges, // returns rows to sync
  }) async {
    try {
      print('Syncing $worksheetTitle from SQLite to Sheets...');

      // Ensure worksheet exists
      await _ensureWorksheetExists(worksheetTitle, headers);

      final localRows = await getLocalChanges();
      print('Found ${localRows.length} rows to sync for $worksheetTitle');

      if (localRows.isEmpty) {
        print('No rows to sync for $worksheetTitle');
        return;
      }

      // Convert Map<String, dynamic> to List<String> for each row
      final rows = localRows
          .map((row) => headers.map((h) => row[h]?.toString() ?? '').toList())
          .toList();

      await bulkUpsertRowsById(worksheetTitle, headers, rows);
      print('Successfully synced ${rows.length} rows to $worksheetTitle');
    } catch (e) {
      print('Error syncing $worksheetTitle to Sheets: $e');
      rethrow;
    }
  }

  /// Sync all tables (customers, orders, order_details, measurements, shops) both ways.
  Future<Map<String, dynamic>> syncAllData({
    required Future<String> Function(String table) getLastSyncTime,
    required Future<void> Function(String table, String newTime)
    setLastSyncTime,
  }) async {
    final now = DateTime.now().toIso8601String();
    final results = <String, String>{};
    final errors = <String, String>{};

    print('Starting sync process...');
    print('Current time: $now');

    // Helper function to sync a table with error handling
    Future<void> syncTable(
      String tableName,
      Future<void> Function() syncFunction,
    ) async {
      try {
        print('Syncing $tableName...');
        await syncFunction();
        results[tableName] = 'ok';
        print('$tableName synced successfully');
      } catch (e) {
        final errorMsg = 'Error syncing $tableName: $e';
        print(errorMsg);
        errors[tableName] = errorMsg;
        results[tableName] = 'error';
      }
    }

    try {
      // Customers
      await syncTable('customers', () async {
        final lastCustomerSync = await getLastSyncTime('customers');
        print('Last customer sync: $lastCustomerSync');

        await syncCustomersFromSheetsToSQLite(
          getLastSyncTime: () async => lastCustomerSync,
        );
        await syncCustomersFromSQLiteToSheets(
          getLocalChanges: () async =>
              await DBService.getCustomersChangedSince(lastCustomerSync),
        );
        await setLastSyncTime('customers', now);
      });

      // Orders
      await syncTable('orders', () async {
        final lastOrderSync = await getLastSyncTime('orders');
        print('Last order sync: $lastOrderSync');

        await syncOrdersFromSheetsToSQLite(
          getLastSyncTime: () async => lastOrderSync,
        );
        await syncOrdersFromSQLiteToSheets(
          getLocalChanges: () async =>
              await DBService.getOrdersChangedSince(lastOrderSync),
        );
        await setLastSyncTime('orders', now);
      });

      // OrderDetails
      await syncTable('order_details', () async {
        final lastOrderDetailSync = await getLastSyncTime('order_details');
        print('Last order detail sync: $lastOrderDetailSync');

        await syncOrderDetailsFromSheetsToSQLite(
          getLastSyncTime: () async => lastOrderDetailSync,
        );
        await syncOrderDetailsFromSQLiteToSheets(
          getLocalChanges: () async =>
              await DBService.getOrderDetailsChangedSince(lastOrderDetailSync),
        );
        await setLastSyncTime('order_details', now);
      });

      // Measurements
      await syncTable('measurements', () async {
        final lastMeasurementSync = await getLastSyncTime('measurements');
        print('Last measurement sync: $lastMeasurementSync');

        await syncMeasurementsFromSheetsToSQLite(
          getLastSyncTime: () async => lastMeasurementSync,
        );
        await syncMeasurementsFromSQLiteToSheets(
          getLocalChanges: () async =>
              await DBService.getMeasurementsChangedSince(lastMeasurementSync),
        );
        await setLastSyncTime('measurements', now);
      });

      // Shops
      await syncTable('shops', () async {
        final lastShopSync = await getLastSyncTime('shops');
        print('Last shop sync: $lastShopSync');

        await syncShopsFromSheetsToSQLite(
          getLastSyncTime: () async => lastShopSync,
        );
        await syncShopsFromSQLiteToSheets(
          getLocalChanges: () async =>
              await DBService.getShopsChangedSince(lastShopSync),
        );
        await setLastSyncTime('shops', now);
      });

      // Item Types
      await syncTable('item_types', () async {
        final lastItemTypeSync = await getLastSyncTime('item_types');
        print('Last item type sync: $lastItemTypeSync');

        await syncItemTypesFromSheetsToSQLite(
          getLastSyncTime: () async => lastItemTypeSync,
        );
        await syncItemTypesFromSQLiteToSheets(
          getLocalChanges: () async =>
              await DBService.getItemTypesChangedSince(lastItemTypeSync),
        );
        await setLastSyncTime('item_types', now);
      });
    } catch (e) {
      print('Critical sync error: $e');
      results['error'] = e.toString();
    }

    // Add summary information
    final successCount = results.entries.where((e) => e.value == 'ok').length;
    final errorCount = results.entries.where((e) => e.value == 'error').length;

    if (errorCount == 0) {
      results['summary'] =
          'All tables synced successfully ($successCount tables)';
    } else {
      results['summary'] =
          'Sync completed with errors ($successCount success, $errorCount errors)';
    }

    print('Sync completed: ${results['summary']}');
    return results;
  }

  /// --- EXAMPLE: Customers Sync Integration ---
  /// Call these from your app logic to sync customers.

  Future<void> syncCustomersFromSheetsToSQLite({
    required Future<String> Function() getLastSyncTime,
  }) async {
    await syncFromSheetsToSQLite(
      worksheetTitle: 'customers',
      headers: Customer.sheetHeaders,
      getLastSyncTime: getLastSyncTime,
      upsertToSQLite: (rows) async {
        // Convert rows to Customer and upsert in SQLite
        final customers = rows.map((r) => Customer.fromMap(r)).toList();
        await DBService.upsertCustomers(
          customers
              .map((c) => c.toMap())
              .whereType<Map<String, dynamic>>()
              .toList(),
        );
      },
    );
  }

  Future<void> syncCustomersFromSQLiteToSheets({
    required Future<List<Map<String, dynamic>>> Function() getLocalChanges,
  }) async {
    await syncFromSQLiteToSheets(
      worksheetTitle: 'customers',
      headers: Customer.sheetHeaders,
      getLocalChanges: getLocalChanges,
    );
  }

  /// --- EXAMPLE: Orders Sync Integration ---
  /// Call these from your app logic to sync orders.

  Future<void> syncOrdersFromSheetsToSQLite({
    required Future<String> Function() getLastSyncTime,
  }) async {
    await syncFromSheetsToSQLite(
      worksheetTitle: 'orders',
      headers: Order.sheetHeaders,
      getLastSyncTime: getLastSyncTime,
      upsertToSQLite: (rows) async {
        // Convert rows to Order and upsert in SQLite
        final orders = rows.map((r) => Order.fromMap(r)).toList();
        await DBService.upsertOrders(
          orders
              .map((o) => o.toMap())
              .whereType<Map<String, dynamic>>()
              .toList(),
        );
      },
    );
  }

  Future<void> syncOrdersFromSQLiteToSheets({
    required Future<List<Map<String, dynamic>>> Function() getLocalChanges,
  }) async {
    await syncFromSQLiteToSheets(
      worksheetTitle: 'orders',
      headers: Order.sheetHeaders,
      getLocalChanges: getLocalChanges,
    );
  }

  /// --- EXAMPLE: OrderDetails Sync Integration ---
  /// Call these from your app logic to sync order_details.

  Future<void> syncOrderDetailsFromSheetsToSQLite({
    required Future<String> Function() getLastSyncTime,
  }) async {
    await syncFromSheetsToSQLite(
      worksheetTitle: 'order_details',
      headers: OrderDetail.sheetHeaders,
      getLastSyncTime: getLastSyncTime,
      upsertToSQLite: (rows) async {
        // Convert rows to OrderDetail and upsert in SQLite
        final details = rows.map((r) => OrderDetail.fromMap(r)).toList();
        await DBService.upsertOrderDetails(
          details
              .map((d) => d.toMap())
              .whereType<Map<String, dynamic>>()
              .toList(),
        );
      },
    );
  }

  Future<void> syncOrderDetailsFromSQLiteToSheets({
    required Future<List<Map<String, dynamic>>> Function() getLocalChanges,
  }) async {
    await syncFromSQLiteToSheets(
      worksheetTitle: 'order_details',
      headers: OrderDetail.sheetHeaders,
      getLocalChanges: getLocalChanges,
    );
  }

  /// --- EXAMPLE: Measurements Sync Integration ---
  /// Call these from your app logic to sync measurements.
  Future<void> syncMeasurementsFromSheetsToSQLite({
    required Future<String> Function() getLastSyncTime,
  }) async {
    await syncFromSheetsToSQLite(
      worksheetTitle: 'measurements',
      headers: Measurement.sheetHeaders,
      getLastSyncTime: getLastSyncTime,
      upsertToSQLite: (rows) async {
        final measurements = rows.map((r) => Measurement.fromMap(r)).toList();
        await DBService.upsertMeasurements(
          measurements
              .map((m) => m.toMap())
              .whereType<Map<String, dynamic>>()
              .toList(),
        );
      },
    );
  }

  Future<void> syncMeasurementsFromSQLiteToSheets({
    required Future<List<Map<String, dynamic>>> Function() getLocalChanges,
  }) async {
    await syncFromSQLiteToSheets(
      worksheetTitle: 'measurements',
      headers: Measurement.sheetHeaders,
      getLocalChanges: getLocalChanges,
    );
  }

  /// --- EXAMPLE: Shops Sync Integration ---
  /// Call these from your app logic to sync shops.
  Future<void> syncShopsFromSheetsToSQLite({
    required Future<String> Function() getLastSyncTime,
  }) async {
    await syncFromSheetsToSQLite(
      worksheetTitle: 'shops',
      headers: Shop.sheetHeaders,
      getLastSyncTime: getLastSyncTime,
      upsertToSQLite: (rows) async {
        final shops = rows.map((r) => Shop.fromMap(r)).toList();
        await DBService.upsertShops(
          shops
              .map((s) => s.toMap())
              .whereType<Map<String, dynamic>>()
              .toList(),
        );
      },
    );
  }

  Future<void> syncShopsFromSQLiteToSheets({
    required Future<List<Map<String, dynamic>>> Function() getLocalChanges,
  }) async {
    await syncFromSQLiteToSheets(
      worksheetTitle: 'shops',
      headers: Shop.sheetHeaders,
      getLocalChanges: getLocalChanges,
    );
  }

  /// --- Item Types Sync Integration ---
  /// Call these from your app logic to sync item types.

  Future<void> syncItemTypesFromSheetsToSQLite({
    required Future<String> Function() getLastSyncTime,
  }) async {
    await syncFromSheetsToSQLite(
      worksheetTitle: 'item_types',
      headers: ['id', 'type', 'shortName', 'description'],
      getLastSyncTime: getLastSyncTime,
      upsertToSQLite: (rows) async {
        for (final row in rows) {
          await DBService.upsertItemType(row);
        }
      },
    );
  }

  Future<void> syncItemTypesFromSQLiteToSheets({
    required Future<List<Map<String, dynamic>>> Function() getLocalChanges,
  }) async {
    await syncFromSQLiteToSheets(
      worksheetTitle: 'item_types',
      headers: ['id', 'type', 'shortName', 'description'],
      getLocalChanges: getLocalChanges,
    );
  }
}
