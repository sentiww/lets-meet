import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

// Main login screen widget
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      body: Container(
        // Full screen container with gradient background
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          // Centered login content box
          child: Container(
            width: isWide ? 400 : double.infinity,
            padding: const EdgeInsets.all(16),
            child: const _LoginContent(),
          ),
        ),
      ),
    );
  }
}

// Login content including illustration, logo, and form
class _LoginContent extends StatelessWidget {
  const _LoginContent();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double illustrationHeight = (screenHeight * 0.3).clamp(240.0, 400.0);
    final double logoHeight = (screenHeight * 0.08).clamp(50.0, 80.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Illustration image
        Image.asset(
          'assets/images/login_illustration.png',
          height: illustrationHeight,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        // App logo
        Image.asset(
          'assets/images/appLogo.png',
          height: logoHeight,
        ),
        const SizedBox(height: 32),
        // Login form
        const _LoginForm(),
      ],
    );
  }
}

// Stateful widget for login form logic
class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  // Form validity checker
  bool get _isFormValid =>
      _emailCtrl.text.isNotEmpty && _passwordCtrl.text.isNotEmpty;

  // Toggle password visibility
  void _toggleObscure() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  // Handle login logic and backend request
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final success = await AuthService.signIn(
      username: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (success) {
      context.go('/feed'); // Navigate to feed screen
    } else {
      // Show error if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nieprawidłowy login lub hasło')),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: () => setState(() {}),
      child: Column(
        children: [
          // Username field
          _InputField(
            hintText: 'Nazwa użytkownika',
            icon: Icons.email_outlined,
            controller: _emailCtrl,
            validator: (v) =>
            v == null || v.isEmpty ? 'Wprowadź nazwę użytkownika' : null,
          ),
          const SizedBox(height: 16),
          // Password field with toggle
          _InputField(
            hintText: 'Hasło',
            icon: Icons.lock_outline,
            controller: _passwordCtrl,
            obscureText: _obscure,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: _toggleObscure,
            ),
            validator: (v) =>
            v == null || v.isEmpty ? 'Wprowadź hasło' : null,
          ),
          const SizedBox(height: 24),
          // Login button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isFormValid && !_loading ? _login : null,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Zaloguj się', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 16),
          // Register redirect
          TextButton(
            onPressed: () {
              context.go('/register');
            },
            child: const Text(
              'Nie masz konta? Zarejestruj się',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable input field widget
class _InputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController controller;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _InputField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    required this.controller,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16),
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        fillColor: Colors.white,
        filled: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
