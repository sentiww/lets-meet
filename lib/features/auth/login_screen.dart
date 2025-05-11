import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Container(
                  width: isWide ? 400 : double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: const _LoginContent(),
                ),
              ),
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
    final double illustrationHeight = (screenHeight * 0.3).clamp(240.0, 400.0);
    final double logoHeight = (screenHeight * 0.08).clamp(50.0, 80.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/login_illustration.png',
          height: illustrationHeight,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Image.asset(
          'assets/images/appLogo.png',
          height: logoHeight,
        ),
        const SizedBox(height: 32),
        const _LoginForm(),
      ],
    );
  }
}

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

  bool get _isFormValid =>
      _emailCtrl.text.isNotEmpty && _passwordCtrl.text.isNotEmpty;

  void _toggleObscure() {
    setState(() {
      _obscure = !_obscure;
    });
  }

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
      context.go('/feed');
    } else {
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
          _InputField(
            hintText: 'Nazwa użytkownika',
            icon: Icons.email_outlined,
            controller: _emailCtrl,
            validator: (v) =>
            v == null || v.isEmpty ? 'Wprowadź nazwę użytkownika' : null,
          ),
          const SizedBox(height: 16),
          _InputField(
            hintText: 'Hasło',
            icon: Icons.lock_outline,
            controller: _passwordCtrl,
            obscureText: _obscure,
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: _toggleObscure,
            ),
            validator: (v) => v == null || v.isEmpty ? 'Wprowadź hasło' : null,
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
              onPressed: _isFormValid && !_loading ? _login : null,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Zaloguj się', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 16),
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
      keyboardType: TextInputType.text,
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
