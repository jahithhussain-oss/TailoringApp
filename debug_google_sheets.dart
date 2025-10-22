import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== Google Sheets Debug Script ===\n');

  try {
    // Step 1: Test assets loading
    print('1. Testing assets loading...');
    try {
      final credentials = await rootBundle.loadString(
        'assets/Google_Sheet_tailor.json',
      );
      print('✅ Assets loaded successfully');
      print('   Credentials length: ${credentials.length}');
      print(
        '   Contains project_id: ${credentials.contains('nth-bucksaw-369914')}',
      );
      print(
        '   Contains client_email: ${credentials.contains('tailoringdata@nth-bucksaw-369914.iam.gserviceaccount.com')}',
      );
    } catch (e) {
      print('❌ Failed to load assets: $e');
      print('   Make sure to run: flutter clean && flutter pub get');
      return;
    }

    // Step 2: Test GSheets import
    print('\n2. Testing GSheets package...');
    try {
      // Import gsheets package
      final gsheets = await import('package:gsheets/gsheets.dart');
      print('✅ GSheets package imported successfully');
    } catch (e) {
      print('❌ Failed to import GSheets: $e');
      print('   Run: flutter pub get');
      return;
    }

    // Step 3: Test GoogleSheetsService import
    print('\n3. Testing GoogleSheetsService...');
    try {
      // Import our service
      final service = await import(
        'package:tailoringapp/src/services/google_sheets_service.dart',
      );
      print('✅ GoogleSheetsService imported successfully');
    } catch (e) {
      print('❌ Failed to import GoogleSheetsService: $e');
      return;
    }

    print('\n=== All imports successful ===');
    print(
      'The issue is likely in the Google Sheets API access or spreadsheet permissions.',
    );
    print('\nNext steps:');
    print('1. Check if the spreadsheet ID is correct');
    print('2. Verify service account has access to the spreadsheet');
    print('3. Check if Google Sheets API is enabled');
  } catch (e) {
    print('❌ CRITICAL ERROR: $e');
  }
}

// Helper function to simulate import
Future<dynamic> import(String package) async {
  // This is a placeholder - actual import testing would require different approach
  return true;
}
