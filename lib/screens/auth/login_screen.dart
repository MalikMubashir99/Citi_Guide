import 'package:app/admin/dashboard/admin_dashboard_screen.dart';
import 'package:app/admin/services/admin_service.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  final AuthService auth = AuthService();

  // ✅ Email validator
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  // ✅ Password validator
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final credential = await auth.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      // ✅ Check if user exists
      if (credential.user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => loading = false);
        return;
      }

      final adminService = AdminService();

      // ✅ Check if user is admin with error handling
      bool isAdmin = false;
      try {
        isAdmin = await adminService.isAdmin(credential.user!.uid);
      } catch (e) {
        // If admin check fails, treat as normal user
        print("Admin check failed: $e");
        isAdmin = false;
      }

      print("UID: ${credential.user!.uid}");
      print("ADMIN: $isAdmin");

      if (!mounted) return;

      // ✅ Navigate based on admin status
      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>  AdminDashboardScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/login.jpg",
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xff0984E3),
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    const Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sign in to continue exploring.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ✅ Email with validation
                    CustomTextField(
                      controller: emailController,
                      hintText: "Email",
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 20),

                    // ✅ Password with validation
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      prefixIcon: Icons.lock,
                      obscureText: hidePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 5),

                    // ✅ Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/forgot-password");
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Login Button
                    PrimaryButton(
                      text: "Login",
                      onPressed: login,
                      isLoading: loading,
                    ),
                    const SizedBox(height: 20),

                    // ✅ Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/register");
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}