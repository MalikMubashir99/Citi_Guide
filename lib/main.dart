// lib/main.dart
import 'package:app/admin/dashboard/admin_dashboard_screen.dart';
import 'package:app/screens/auth/forgot_password_screen.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/auth/register_screen.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/home/search_screen.dart';
import 'package:app/screens/onbroading/onboarding_screen.dart';
import 'package:app/screens/profile/favorites_screen.dart';
import 'package:app/screens/settings/settings_screen.dart';
import 'package:app/services/analytics_service.dart';
import 'package:app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await NotificationService.initialize();
  } catch (e) {
    print('Notification Service Error (Web): $e');
  }

  runApp(const CitiGuideApp());
}

class CitiGuideApp extends StatelessWidget {
  const CitiGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Citi Guide',

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      navigatorObservers: [AnalyticsService.observer],

      initialRoute: "/",

      routes: {
        "/": (context) => const SplashScreen(),
        "/onboarding": (context) => const OnboardingScreen(),
        "/register": (context) => const RegisterScreen(),
        "/login": (context) => const LoginScreen(),
        "/forgot-password": (context) => const ForgotPasswordScreen(),
        "/home": (context) => const HomeScreen(),
        "/search": (context) => const SearchScreen(),
        "/favorites": (context) => const FavoritesScreen(),
        "/settings": (context) => const SettingsScreen(),
        "/admin-dashboard": (context) => const AdminDashboardScreen(),
      },

      onGenerateRoute: (settings) {
        return null;
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Page Not Found'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Page Not Found',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The page you are looking for does not exist.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
