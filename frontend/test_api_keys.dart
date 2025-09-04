import 'package:flutter/material.dart';
import 'lib/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Testing API Key Pool Integration');
  print('=' * 50);
  
  // Test the ApiKeyPool directly
  await ApiService.testApiKeyPool();
  
  print('\n🔄 Testing backend synchronization...');
  final result = await ApiService.sendApiKeysToBackend();
  print('📊 Result: $result');
}
