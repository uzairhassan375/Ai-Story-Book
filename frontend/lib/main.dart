import 'package:ai_storybook_frontend/services/remote-config-service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await ApiKeyPool.init('ai_storybook_frontend');
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await RemoteConfigService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

    // 🔹 Firebase Analytics instance
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

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
