import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/appLogoDark.png',
                  height: 90,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Stwórz swoje konto\ni poznawaj nowych ludzi!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const _InputField(hint: 'Imię'),
                      const SizedBox(height: 12),
                      const _InputField(hint: 'E-mail'),
                      const SizedBox(height: 12),
                      const _InputField(hint: 'Hasło', obscureText: true),
                      const SizedBox(height: 12),
                      const _InputField(hint: 'Powtórz hasło', obscureText: true),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _accepted,
                        onChanged: (value) {
                          setState(() {
                            _accepted = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          'Akceptuję regulamin',
                          style: TextStyle(fontSize: 16),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
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
                            if (_formKey.currentState!.validate() && _accepted) {
                              // TODO: Dodaj logikę rejestracji
                            }
                          },
                          child: const Text(
                            'Zarejestruj się',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white, // ← biały tekst
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.go('/');
                        },
                        child: const Text(
                          'Masz już konto? Zaloguj się',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final bool obscureText;

  const _InputField({required this.hint, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 16),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // mniej zaokrąglone
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'To pole jest wymagane' : null,
    );
  }
}
