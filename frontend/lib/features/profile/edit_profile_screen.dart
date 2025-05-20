import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_meet/services/user_service.dart';
import 'package:lets_meet/services/blob_service.dart';
import '../../models/user.dart';
import '../../models/post_blob_request.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  File? _pickedImage;
  bool _loading = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser(); // Load current user data on screen init
  }

  // Fetch current user from the backend
  Future<void> _loadUser() async {
    final user = await UserService.getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
        _nameCtrl.text = user.name;
        _surnameCtrl.text = user.surname;
        _usernameCtrl.text = user.username;
      });
    }
  }

  // Open image picker to select profile picture
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  // Simulated save function (since no backend communication)
  Future<void> _submit() async {
  if (!_formKey.currentState!.validate() || _user == null) return;

  setState(() => _loading = true);

  try {
    int? avatarId = _user!.avatarId;

    if (_pickedImage != null) {
      final bytes = await _pickedImage!.readAsBytes();
      final filename = _pickedImage!.path.split('/').last;
      final extension = filename.split('.').last;

      final blobRequest = PostBlobRequest(
        name: filename,
        extension: extension,
        contentType: 'image/$extension',
        data: bytes,
      );
      // Upload new blob first
      final newAvatarId = await BlobService.postBlob(blobRequest);

      // Then safely delete the old blob (if any)
      if (avatarId != null) {
        await BlobService.deleteBlob(avatarId);
      }

      avatarId = newAvatarId;
    }

    final success = await UserService.updateCurrentUser(
      name: _nameCtrl.text.trim(),
      surname: _surnameCtrl.text.trim(),
      dateOfBirth: _user!.dateOfBirth ?? DateTime(2000),
      email: _user!.email ?? '',
      avatarId: avatarId,
    );

    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Zapisano zmiany profilu' : 'Nie udało się zapisać zmian')),
      );
    }
  } catch (e) {
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: ${e.toString()}')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      // Show loading spinner while user data is being fetched
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text("Edytuj profil"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (_user!.avatarUrl != null
                          ? NetworkImage(_user!.avatarUrl!)
                          : null) as ImageProvider<Object>?,
                      child: _pickedImage == null && _user!.avatarUrl == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceActionSheet,
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Icon(Icons.edit, color: Colors.purple),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  onChanged: () => setState(() {}),
                  child: Column(
                    children: [
                      _buildField(_nameCtrl, 'Imię'),
                      const SizedBox(height: 12),
                      _buildField(_surnameCtrl, 'Nazwisko'),
                      const SizedBox(height: 12),
                      _buildField(_usernameCtrl, 'Nazwa użytkownika'),
                      const SizedBox(height: 12),
                      _buildField(_passwordCtrl, 'Nowe hasło (opcjonalnie)', obscureText: true),
                      const SizedBox(height: 12),
                      _buildField(_confirmPasswordCtrl, 'Powtórz hasło', obscureText: true),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : const Text('ZAPISZ', style: TextStyle(color: Colors.white, fontSize: 18)),
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

  // Form field builder with validation for matching passwords only
  Widget _buildField(TextEditingController controller, String hint, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3EFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (value) {
        // Validate only if passwords are filled
        if ((controller == _passwordCtrl || controller == _confirmPasswordCtrl) &&
            _passwordCtrl.text.isNotEmpty) {
          if (_confirmPasswordCtrl.text != _passwordCtrl.text) {
            return 'Hasła muszą być takie same';
          }
        }

        return null;
      },
    );
  }

  // Show modal bottom sheet to choose image source
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Zrób zdjęcie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Wybierz z galerii'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
