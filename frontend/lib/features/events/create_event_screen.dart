import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lets_meet/models/post_event_request.dart';
import '../../services/event_service.dart';
import '../../services/blob_service.dart';
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
  List<PlatformFile> _selectedImages = [];

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() => _selectedImages.addAll(result.files));
    }
  }

  Future<Uint8List> _readFileBytes(PlatformFile file) async {
    if (file.bytes != null) return file.bytes!;
    if (file.path != null) return await File(file.path!).readAsBytes();
    throw Exception('Nie można odczytać pliku ${file.name}');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    List<int> blobIds = [];
    for (var img in _selectedImages) {
      final bytes = await _readFileBytes(img);
      final ext = img.extension ?? 'jpg';
      final req = PostBlobRequest(
        name: img.name,
        extension: ext,
        contentType: 'image/$ext',
        data: bytes,
      );
      final id = await BlobService.postBlob(req);
      if (id != null) blobIds.add(id);
    }

    await EventService.postEvent(
      PostEventRequest(
        title: _title,
        description: _description,
        eventDate: _selectedDate,
        photoBlobIds: blobIds,
      ),
    );

    if (context.mounted) context.pop(true);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd.MM.yyyy').format(_selectedDate);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const FeedDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu, color: theme.colorScheme.onBackground),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: GestureDetector(
          onTap: () => context.go('/feed'),
          child: Image.asset(
            'assets/images/appLogoDark.png',
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tytuł
                        _buildTextField(
                          label: 'Tytuł wydarzenia',
                          hint: 'Wpisz tytuł',
                          onChanged: (v) => _title = v,
                          validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wymagane' : null,
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                        // Opis
                        _buildTextField(
                          label: 'Opis',
                          hint: 'Wpisz opis',
                          onChanged: (v) => _description = v,
                          maxLines: 4,
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                        // Data
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text('Data wydarzenia',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                            color: theme.colorScheme
                                                .onSurfaceVariant)),
                                    const SizedBox(height: 4),
                                    Text(dateStr,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                            fontWeight:
                                            FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Dodaj zdjęcia
                        OutlinedButton.icon(
                          onPressed: _pickImages,
                          icon: Icon(Icons.photo_library,
                              color: theme.colorScheme.primary),
                          label: Text('Dodaj zdjęcia',
                              style: TextStyle(
                                  color: theme.colorScheme.primary)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: theme.colorScheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                          ),
                        ),
                        if (_selectedImages.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _selectedImages.map((file) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      file.bytes ?? Uint8List(0),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() =>
                                            _selectedImages.remove(file));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 32),
                        // Utwórz
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                vertical: 18),
                          ),
                          child: Text(
                            'Utwórz wydarzenie',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
    required ThemeData theme,
  }) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
