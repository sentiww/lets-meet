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
    final e = await EventService.getEvent(widget.eventId);
    setState(() {
      _event = e;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const FeedDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87, size: 28),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Image.asset('assets/images/appLogoDark.png', height: 40),
        centerTitle: true,
      ),

      backgroundColor: theme.colorScheme.surface,

      // GŁÓWNA ZAWARTOŚĆ
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _event == null
                    ? const Center(child: Text('Nie znaleziono wydarzenia'))
                    : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HERO IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 220,
                          child: (_event!.photoIds?.isNotEmpty ?? false)
                              ? FutureBuilder<Widget>(
                            future: BlobService.loadBlobImage(
                              _event!.photoIds!.first,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                            builder: (ctx, snap) {
                              if (snap.connectionState == ConnectionState.waiting) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              }
                              if (snap.hasError || snap.data == null) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                  ),
                                );
                              }
                              return snap.data!;
                            },
                          )
                              : Image.asset(
                            'assets/images/eventPhotoDefault.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // TYTUŁ I DATA
                      Text(
                        _event!.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(_event!),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // GALERIA MINIATUR
                      if ((_event!.photoIds?.length ?? 0) > 1)
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _event!.photoIds!.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (ctx, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FutureBuilder<Widget>(
                                future: BlobService.loadBlobImage(
                                  _event!.photoIds![i],
                                  width: 120,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                builder: (ctx, snap) {
                                  if (snap.connectionState == ConnectionState.waiting) {
                                    return Container(
                                      width: 120,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  }
                                  if (snap.hasError || snap.data == null) {
                                    return Container(
                                      width: 120,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    );
                                  }
                                  return snap.data!;
                                },
                              ),
                            ),
                          ),
                        ),
                      if ((_event!.photoIds?.length ?? 0) > 1) const SizedBox(height: 24),

                      // OPIS W KARDCIE
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OPIS',
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _event!.description ?? 'Brak opisu',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // STOI NIEWZMIENIONY DOLNY PAS
      bottomNavigationBar: const _BottomNavBar(currentIndex: 0),
    );
  }

  String _formatDate(Event e) {
    final d = e.eventDate!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
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
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Odkrywaj'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Wiadomości'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
      onTap: (i) {
        if (i == 0) context.go('/feed');
        if (i == 1) context.goNamed('chat_list');
        if (i == 2) context.go('/profile');
      },
    );
  }
}
