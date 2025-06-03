import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../services/blob_service.dart';
import '../../widgets/feed_drawer.dart';

class EventProfileScreen extends StatefulWidget {
  final int eventId;

  const EventProfileScreen({super.key, required this.eventId});

  @override
  State<EventProfileScreen> createState() => _EventProfileScreenState();
}

class _EventProfileScreenState extends State<EventProfileScreen> {
  Event? _event;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final event = await EventService.getEvent(widget.eventId);
    setState(() {
      _event = event;
      _loading = false;
    });
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
        title: Image.asset(
          'assets/images/appLogoDark.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _event == null
                ? const Center(child: Text('Nie znaleziono wydarzenia'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: Icon(
                            Icons.event,
                            size: 100,
                            color: Colors.deepPurple.shade300,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (_event!.photoIds == null || _event!.photoIds!.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                height: 200,
                                width: 300,
                                child: Image.asset(
                                  'assets/images/eventPhotoDefault.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: SizedBox(
                              height: 200,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: _event!.photoIds!.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final blobId = _event!.photoIds![index];
                                  return FutureBuilder<Widget>(
                                    future: BlobService.loadBlobImage(blobId,
                                        fit: BoxFit.cover, width: 300, height: 200),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Container(
                                          width: 300,
                                          height: 200,
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      } else if (snapshot.hasError || !snapshot.hasData) {
                                        return Container(
                                          width: 300,
                                          height: 200,
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                          ),
                                        );
                                      } else {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: SizedBox(
                                            width: 300,
                                            height: 200,
                                            child: snapshot.data,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),
                        _ProfileInfoTile(
                          label: 'Tytuł wydarzenia',
                          value: _event!.title,
                          icon: Icons.title,
                        ),
                        _ProfileInfoTile(
                          label: 'Data wydarzenia',
                          value:
                              "${_event!.eventDate!.year.toString().padLeft(4, '0')}-"
                              "${_event!.eventDate!.month.toString().padLeft(2, '0')}-"
                              "${_event!.eventDate!.day.toString().padLeft(2, '0')} "
                              "${_event!.eventDate!.hour.toString().padLeft(2, '0')}:"
                              "${_event!.eventDate!.minute.toString().padLeft(2, '0')}",
                          icon: Icons.calendar_today,
                        ),
                        _ProfileInfoTile(
                          label: 'Opis',
                          value: _event!.description ?? 'Brak opisu',
                          icon: Icons.description,
                        ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: const _BottomNavBar(currentIndex: 0),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF1E8F8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6A1B9A)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Odkrywaj',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Wiadomości',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
      onTap: (index) {
        if (index == 0) context.go('/feed');
        if (index == 1) context.goNamed('chat_list');
        if (index == 2) context.go('/profile');
      },
    );
  }
}
