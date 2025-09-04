import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_key_pool/api_key_pool.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'providers/story_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_colors.dart';
import 'utils/app_sizes.dart';
import 'services/firebase_service.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API Key Pool with proper async handling
  try {
    await ApiKeyPool.init('ai_storybook_frontend');
    print('✅ API Key Pool initialized successfully');
  } catch (e) {
    print('⚠️ API Key Pool initialization failed: $e');
    // Continue without API Key Pool - backend will use fallback
  }
  
  // Initialize Firebase with proper options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue without Firebase for now
  }
  
  // Test Firebase connection in background (non-blocking)
  Future.delayed(const Duration(milliseconds: 500), () async {
    try {
      bool isConnected = await FirebaseService.testConnection();
      print('Firebase connection test: ${isConnected ? "SUCCESS" : "FAILED"}');
    } catch (e) {
      print('Firebase connection test error: $e');
    }
  });
  
  // Send API keys to backend for rotation (non-blocking)
  Future.delayed(const Duration(seconds: 3), () async {
    try {
      print('🔄 Sending API keys to backend for rotation...');
      
      // First test the ApiKeyPool
      print('🧪 Testing ApiKeyPool first...');
      await ApiService.testApiKeyPool();
      
      // Then try to sync with backend
      final result = await ApiService.sendApiKeysToBackend();
      if (result['success'] == true) {
        print('✅ API keys successfully configured for rotation');
      } else {
        print('⚠️ API key sync result: ${result['message'] ?? result['error']}');
      }
    } catch (e) {
      print('❌ Failed to send API keys to backend: $e');
      // Continue without key rotation - app will use backend fallback key
    }
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AI Storybook',
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              AppSizes.init(context);
              return child!;
            },
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                titleTextStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            home: const HomeScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
