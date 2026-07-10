import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:legacy_notebook/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with placeholder credentials (replaced in Phase 4)
  await Supabase.initialize(
    url: 'https://placeholder.supabase.co',
    publishableKey: 'placeholder-publishable-key',
  );

  runApp(
    const ProviderScope(
      child: AppWidget(),
    ),
  );
}
