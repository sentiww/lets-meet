import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import '../services/blob_service.dart';

class EventCard extends StatefulWidget {
  final int eventId;

  const EventCard({
    super.key,
    required this.eventId,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late Future<Event?> _eventFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = EventService.getEvent(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Event?>(
      future: _eventFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 350,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Text('Błąd: ${snapshot.error}');
        }

        final event = snapshot.data;
        if (event == null) {
          return const Text('Nie znaleziono wydarzenia');
        }

        return GestureDetector(
          onTap: () {
            context.push('/event/${event.id}');
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Obrazek ładowany z blobów
                  FutureBuilder<Widget>(
                    future: _buildEventImage(event.photoIds),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 280,
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Container(
                          height: 280,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 280,
                          width: double.infinity,
                          child: snapshot.data ?? const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (event.eventDate != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          '${event.eventDate!.day.toString().padLeft(2, '0')}.${event.eventDate!.month.toString().padLeft(2, '0')}.${event.eventDate!.year}r.',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      event.description!,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Widget> _buildEventImage(List<int>? photoIds) async {
  if (photoIds == null || photoIds.isEmpty) {
    // Zwróć domyślny obrazek z assets gdy brak zdjęć
    return Image.asset(
      'assets/images/eventPhotoDefault.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 280,
    );
  }

  try {
    return await BlobService.loadBlobImage(
      photoIds.first,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 280,
    );
  } catch (_) {
    print("Excpetion in Event Card:" + _.toString());
    // W przypadku błędu zwróć domyślny obrazek
    return Image.asset(
      'assets/images/eventPhotoDefault.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 280,
    );
  }
}

}
