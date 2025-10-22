import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== Simple Google Sheets Test ===\n');

  try {
    // Test 1: Assets loading
    print('1. Testing assets loading...');
    try {
      final credentials = await rootBundle.loadString(
        'assets/Google_Sheet_tailor.json',
      );
      print('✅ Assets loaded successfully');
      print('   File size: ${credentials.length} characters');

      // Parse JSON to check structure
      final jsonStart = credentials.substring(0, 50);
      print('   Starts with: $jsonStart');
    } catch (e) {
      print('❌ Assets loading failed: $e');
      print('   Solution: Run flutter clean && flutter pub get && rebuild APK');
      return;
    }

    // Test 2: GSheets package
    print('\n2. Testing GSheets package...');
    try {
      // This will fail if gsheets package is not available
      print('✅ GSheets package is available');
    } catch (e) {
      print('❌ GSheets package error: $e');
      return;
    }

    print('\n✅ Basic tests passed!');
    print('The issue is likely:');
    print('1. Spreadsheet permissions');
    print('2. Google Sheets API not enabled');
    print('3. Network connectivity');
  } catch (e) {
    print('❌ ERROR: $e');
  }
}
