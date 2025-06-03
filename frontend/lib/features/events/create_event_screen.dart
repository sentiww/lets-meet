import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // ⬅️ ADDED
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_meet/models/post_event_request.dart';
import '../../services/event_service.dart';
import '../../services/blob_service.dart'; // ⬅️ ADDED
import '../../widgets/feed_drawer.dart';
import '../../models/post_blob_request.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _selectedDate = DateTime.now();

  List<PlatformFile> _selectedImages = []; // ⬅️

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true, // ważne, żeby mieć bytes
    );
    if (result != null) {
      setState(() {
        _selectedImages.addAll(result.files);
      });
    }
  }

  Future<Uint8List> _readFileBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes!;
    } else if (file.path != null) {
      final fileBytes = await File(file.path!).readAsBytes();
      return fileBytes;
    } else {
      throw Exception('Nie można odczytać pliku ${file.name}');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    List<int> blobIds = [];

    for (var image in _selectedImages) {
      final bytes = await _readFileBytes(image);
      final extension = image.extension ?? 'jpg';

      final blobRequest = PostBlobRequest(
        name: image.name,
        extension: extension,
        contentType: 'image/$extension',
        data: bytes,
      );

      final blobId = await BlobService.postBlob(blobRequest);
      if (blobId != null) {
        blobIds.add(blobId);
      }
    }

    await EventService.postEvent(
      PostEventRequest(
        title: _title,
        description: _description,
        eventDate: _selectedDate,
        photoBlobIds: blobIds,
      ),
    );

    if (context.mounted) {
      context.pop(true); // return success
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FeedDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Nowe wydarzenie', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              context.go('/feed'); // Powrót do ekranu Feed
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _TextFieldTile(
                  label: 'Tytuł wydarzenia',
                  hintText: 'Wpisz tytuł',
                  onChanged: (val) => _title = val,
                  validator: (val) => val == null || val.isEmpty ? 'Wymagane' : null,
                ),
                _TextFieldTile(
                  label: 'Opis',
                  hintText: 'Wpisz opis',
                  maxLines: 4,
                  onChanged: (val) => _description = val,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  leading: const Icon(Icons.calendar_today, color: Color(0xFF6A1B9A)),
                  title: const Text('Data wydarzenia'),
                  subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Dodaj zdjęcia'),
                  ),
                ),
                if (_selectedImages.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedImages.map((file) {
                      return Stack(
                        children: [
                          Image.memory(
                            file.bytes ?? Uint8List(0),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.remove(file);
                                });
                              },
                              child: const Icon(Icons.cancel, color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Utwórz wydarzenie'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextFieldTile extends StatelessWidget {
  final String label;
  final String hintText;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String> onChanged;

  const _TextFieldTile({
    required this.label,
    required this.hintText,
    required this.onChanged,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          filled: true,
          fillColor: const Color(0xFFF1E8F8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
