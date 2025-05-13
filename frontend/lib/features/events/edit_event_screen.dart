import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_meet/models/post_event_request.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../widgets/feed_drawer.dart';

class EditEventScreen extends StatefulWidget {
  final int eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  Event? _event;
  bool _loading = true;

  late String _title;
  late String _description;
  late DateTime? _selectedDate;
  late List<String> photoBlobIds = [];

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final event = await EventService.getEvent(widget.eventId);
    if (event != null) {
      _title = event.title;
      _description = event.description ?? '';
      _selectedDate = event.eventDate;
    }
    setState(() {
      _event = event;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await EventService.updateEvent(
        widget.eventId,
        PostEventRequest(title: _title, description: _description, eventDate: _selectedDate!, photoBlobIds: photoBlobIds)
      );
      if (context.mounted) {
        context.pop(true);
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
      setState(() => _selectedDate = date);
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
        title: const Text('Edytuj wydarzenie', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _event == null
                ? const Center(child: Text('Nie znaleziono wydarzenia'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _TextFieldTile(
                            label: 'Tytuł wydarzenia',
                            hintText: 'Wpisz tytuł',
                            initialValue: _title,
                            onChanged: (val) => _title = val,
                            validator: (val) => val == null || val.isEmpty ? 'Wymagane' : null,
                          ),
                          _TextFieldTile(
                            label: 'Opis',
                            hintText: 'Wpisz opis',
                            maxLines: 4,
                            initialValue: _description,
                            onChanged: (val) => _description = val,
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            leading: const Icon(Icons.calendar_today, color: Color(0xFF6A1B9A)),
                            title: const Text('Data wydarzenia'),
                            subtitle: Text('${_selectedDate?.toLocal()}'.split(' ')[0]),
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
                            child: const Text('Zapisz zmiany'),
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
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String> onChanged;

  const _TextFieldTile({
    required this.label,
    required this.hintText,
    required this.onChanged,
    this.maxLines = 1,
    this.validator,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
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
