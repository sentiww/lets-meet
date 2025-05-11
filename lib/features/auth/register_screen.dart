import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';

// Main register screen widget
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _loading = false;
  bool _accepted = false;
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    // Clean up controllers
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // Check if user is at least 18 years old
  bool _isAdult(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final adult = DateTime(now.year - 18, now.month, now.day);
    return date.isBefore(adult);
  }

  // Submit registration data
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_accepted) return;

    setState(() {
      _loading = true;
      _fieldErrors.clear();
    });

    // Call AuthService
    final success = await AuthService.signUp(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      surname: _surnameCtrl.text.trim(),
      dateOfBirth: _birthDate!,
      onFieldErrors: (errors) {
        setState(() {
          _fieldErrors = errors;
        });
      },
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (success) {
      // Show success and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zarejestrowano, zaloguj się')),
      );
      context.go('/');
    } else if (_fieldErrors.isEmpty) {
      // Show generic error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coś poszło nie tak, spróbuj ponownie')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo
                  Image.asset('assets/images/appLogoDark.png', height: 90),
                  const SizedBox(height: 24),
                  const Text(
                    'Stwórz konto \ni dołącz do wydarzeń!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  // Form fields
                  _buildField(_nameCtrl, 'Imię', errorKey: 'name'),
                  _buildField(_surnameCtrl, 'Nazwisko', errorKey: 'surname'),
                  _buildField(
                    _emailCtrl,
                    'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wprowadź e-mail';
                      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!regex.hasMatch(v)) return 'Nieprawidłowy e-mail';
                      return null;
                    },
                    errorKey: 'email',
                  ),
                  _buildField(_usernameCtrl, 'Nazwa użytkownika', errorKey: 'username'),
                  _buildField(
                    _passwordCtrl,
                    'Hasło',
                    obscure: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wprowadź hasło';
                      if (!RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$').hasMatch(v)) {
                        return 'Min. 6 znaków, 1 duża litera i cyfra';
                      }
                      return null;
                    },
                    errorKey: 'password',
                  ),
                  _buildField(
                    _confirmPasswordCtrl,
                    'Powtórz hasło',
                    obscure: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Powtórz hasło';
                      if (v != _passwordCtrl.text) return 'Hasła się różnią';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Date picker
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _birthDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _birthDate == null
                            ? 'Data urodzenia'
                            : DateFormat('yyyy-MM-dd').format(_birthDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  if (_birthDate != null && !_isAdult(_birthDate))
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Musisz mieć co najmniej 18 lat',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Terms acceptance checkbox
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Akceptuję regulamin'),
                    value: _accepted,
                    onChanged: (val) => setState(() => _accepted = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    subtitle: !_accepted
                        ? const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Musisz zaakceptować regulamin',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Register button
                  ElevatedButton(
                    onPressed: _formKey.currentState?.validate() == true &&
                        _birthDate != null &&
                        _isAdult(_birthDate) &&
                        _accepted &&
                        !_loading
                        ? _submit
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Zarejestruj się', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  // Redirect to login
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Masz już konto? Zaloguj się'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Field builder helper
  Widget _buildField(
      TextEditingController controller,
      String hint, {
        TextInputType? keyboardType,
        bool obscure = false,
        String? Function(String?)? validator,
        String? errorKey,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          errorText: _fieldErrors[errorKey],
        ),
        validator: validator ?? (v) => v == null || v.isEmpty ? 'To pole jest wymagane' : null,
      ),
    );
  }
}
