import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_meet/app.dart';

void main() {
  runApp(
    ProviderScope(
      child: LetsMeetApp(),
    ),
  );
}
