import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool loading = false;

  final AuthService auth = AuthService();

  // ✅ Email validator
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter your email";
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  // ✅ Phone validator
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter your phone number";
    }
    if (value.length < 10) {
      return "Enter a valid phone number (min 10 digits)";
    }
    return null;
  }

  // ✅ Password validator
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter your password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    // Optional: Add more password requirements
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must contain at least one uppercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Password must contain at least one number";
    }
    return null;
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await auth.registerUser(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Created Successfully 🎉"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, "/home");
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
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/register.jpg",
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xff0984E3),
            ),
          ),
          // ✅ Fixed: withOpacity → withValues(alpha:)
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
                    const SizedBox(height: 50),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Start your journey with Citi Guide.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 35),

                    // ✅ Full Name
                    CustomTextField(
                      controller: fullNameController,
                      hintText: "Full Name",
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your full name";
                        }
                        if (value.length < 3) {
                          return "Name must be at least 3 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // ✅ Phone
                    CustomTextField(
                      controller: phoneController,
                      hintText: "Phone Number",
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 18),

                    // ✅ Email with validation
                    CustomTextField(
                      controller: emailController,
                      hintText: "Email",
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 18),

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
                    const SizedBox(height: 18),

                    // ✅ Confirm Password
                    CustomTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: hideConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          hideConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            hideConfirmPassword =
                                !hideConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Confirm your password";
                        }
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    PrimaryButton(
                      text: "Create Account",
                      isLoading: loading,
                      onPressed: register,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
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