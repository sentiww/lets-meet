import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const SingleChildScrollView(
              child: _LoginContent(),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double illustrationHeight = (screenHeight * 0.3).clamp(240, 400);
    final double logoHeight = (screenHeight * 0.08).clamp(50, 80);

    return Column(
      children: [
        AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Image.asset(
              'assets/images/login_illustration.png',
              height: illustrationHeight,
              fit: BoxFit.contain,
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 800),
          child: Image.asset(
            'assets/images/appLogo.png',
            height: logoHeight,
          ),
        ),
        const SizedBox(height: 32),
        const _LoginForm(),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _InputField(
          hintText: 'E-mail',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        const _InputField(
          hintText: 'Hasło',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 24),
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
            onPressed: () {
              context.go('/feed');
            },
            child: const Text(
              'Zaloguj się',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Image.asset(
              'assets/images/logo_google_g_icon.png',
              height: 32,
            ),
            label: const Text(
              'Zaloguj się przez Google',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            context.go('/register');
          },
          child: const Text(
            'Nie masz konta? Zarejestruj się',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;

  const _InputField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16),
        prefixIcon: Icon(icon),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
