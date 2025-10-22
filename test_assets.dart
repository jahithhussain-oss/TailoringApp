import 'package:flutter/services.dart';

void main() async {
  print('Testing assets loading...');

  try {
    // Test loading the credentials file from assets
    final credentials = await rootBundle.loadString(
      'assets/Google_Sheet_tailor.json',
    );
    print('✅ Assets loaded successfully');
    print('Credentials length: ${credentials.length}');
    print('First 100 characters: ${credentials.substring(0, 100)}...');
  } catch (e) {
    print('❌ Failed to load assets: $e');
    print('Make sure to run: flutter clean && flutter pub get');
  }
}
