import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_meet/models/post_event_request.dart';
import '../../services/event_service.dart';
import '../../widgets/feed_drawer.dart';

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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await EventService.postEvent(
        PostEventRequest(
          title: _title,
          description: _description,
          eventDate: _selectedDate,
          photoBlobIds: [],
        ),
      );
      if (context.mounted) {
        context.pop(true); // return success
      }
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
        leadingWidth: 80,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                context.go('/feed'); // Powrót do ekranu Feed
              },
            ),
          ],
        ),
        title: const Text(
          'Nowe wydarzenie',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
<<<<<<< Updated upstream
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
=======
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
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
                      validator: (val) =>
                      val == null || val.isEmpty ? 'Wymagane' : null,
>>>>>>> Stashed changes
                    ),
                    _TextFieldTile(
                      label: 'Opis',
                      hintText: 'Wpisz opis',
                      maxLines: 4,
                      onChanged: (val) => _description = val,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        leading: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF6A1B9A),
                        ),
                        title: const Text(
                          'Data wydarzenia',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${_selectedDate.toLocal()}'.split(' ')[0],
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Dodaj zdjęcia'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedImages.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
                                    setState(() {
                                      _selectedImages.remove(file);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
