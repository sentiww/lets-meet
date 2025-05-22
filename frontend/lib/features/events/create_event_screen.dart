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
