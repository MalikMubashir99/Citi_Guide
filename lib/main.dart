// lib/main.dart
import 'package:app/admin/dashboard/admin_dashboard_screen.dart';
import 'package:app/core/constants/app_colors.dart';
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

      // ✅ Cleaned up onGenerateRoute
      onGenerateRoute: (settings) {
        return null;
      },

      // ✅ Updated 404 Page to match warm earthy theme
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: AppColors.background, // Warm linen background
            appBar: AppBar(
              title: const Text('Page Not Found'),
              backgroundColor: AppColors.background,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              iconTheme: const IconThemeData(color: AppColors.dark),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Warm error icon container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: AppColors.error, // Burnt Sienna
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Page Not Found',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The page you are looking for does not exist.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey, // Warm Charcoal
                    ),
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