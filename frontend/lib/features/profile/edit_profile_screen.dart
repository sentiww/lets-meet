import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_meet/models/blob.dart';
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
  final _emailCtrl = TextEditingController();
  DateTime? _dateOfBirth;

  File? _pickedImage;
  bool _loading = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserService.getCurrentUser();
    if (user != null) {
      setState(() {
        _user = user;
        _nameCtrl.text = user.name;
        _surnameCtrl.text = user.surname;
        _emailCtrl.text = user.email ?? '';
        _dateOfBirth = user.dateOfBirth;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

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

        int? newAvatarId = await BlobService.postBlob(blobRequest);
        try
        {
          if (avatarId != null && newAvatarId !=null) {
            await BlobService.deleteBlob(avatarId);
          }
        }
        catch(e)
        {
          print('Blob Remove exception:' +e.toString());
        }
        if(newAvatarId != null)
        {
          avatarId = newAvatarId;
        }
      }

      final success = await UserService.updateCurrentUser(
        name: _nameCtrl.text.trim(),
        surname: _surnameCtrl.text.trim(),
        dateOfBirth: _dateOfBirth ?? DateTime(2000),
        email: _emailCtrl.text.trim(),
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

  Widget _buildProfileAvatar() {
    if (_pickedImage != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_pickedImage!),
      );
    }

    if (_user?.avatarId != null) {
      return FutureBuilder<Uint8List>(
        future: BlobService.getBlobData(_user!.avatarId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade300,
              child: const CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return CircleAvatar(
              radius: 60,
              backgroundImage: MemoryImage(snapshot.data!),
            );
          } else {
            return const CircleAvatar(
              radius: 60,
              child: Icon(Icons.person, size: 60),
            );
          }
        },
      );
    }

    return const CircleAvatar(
      radius: 60,
      child: Icon(Icons.person, size: 60),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
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
                    _buildProfileAvatar(),
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
                      _buildField(_emailCtrl, 'Email', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildDatePicker(context),
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
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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

  Widget _buildField(TextEditingController controller, String hint,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
        if (value == null || value.isEmpty) return 'To pole jest wymagane';
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _dateOfBirth = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF3EFFF),
          hintText: 'Data urodzenia',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        child: Text(
          _dateOfBirth != null
              ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}.${_dateOfBirth!.month.toString().padLeft(2, '0')}.${_dateOfBirth!.year}'
              : 'Wybierz datę urodzenia',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

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
