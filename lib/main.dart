import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options for web
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBJ0Ry2z29T94g9GoBrEPi-6uzDha1nfzM",
        authDomain: "streakforge-c709f.firebaseapp.com",
        projectId: "streakforge-c709f",
        storageBucket: "streakforge-c709f.firebasestorage.app",
        messagingSenderId: "395796914101",
        appId: '1:395796914101:web:45067f9805b22a85e643fc',
        databaseURL: "https://streakforge-c709f.firebaseio.com",
      ),
    );
    debugPrint('✅ Firebase initialized successfully.');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization warning: $e');
  }

  // Initialize Notifications
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('⚠️ Notification initialization failed: $e');
  }

  // Set preferred orientations
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('⚠️ Orientation settings not supported on this platform.');
  }

  runApp(const StreakForgeApp());
}

class StreakForgeApp extends StatelessWidget {
  const StreakForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Routes
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
