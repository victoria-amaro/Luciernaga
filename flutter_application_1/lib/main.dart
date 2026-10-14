import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/features/capture/confirmation_bottom_sheet.dart';
import 'package:flutter_application_1/features/library/library_screen.dart';
import 'package:flutter_application_1/shared/services/candidate_extractor.dart';
import 'package:flutter_application_1/shared/services/candidate_resolver.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pixmztoatdgqbwzoiirg.supabase.co',
    publishableKey: 'sb_publishable_zf1RjpN762vKAmldQm9MMQ_hG7t3hKK',
  );

  await _ensureSession();

  runApp(const LuciernagaApp());
}

Future<User?> _ensureSession() async {
  final auth = Supabase.instance.client.auth;
  if (auth.currentUser == null) {
    try {
      final response = await auth.signInAnonymously();
      return response.user;
    } catch (e) {
      debugPrint('Aviso de auth: $e');
    }
  }
  return auth.currentUser;
}

class LuciernagaApp extends StatelessWidget {
  const LuciernagaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luciérnaga',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const LibraryScreenWrapper(),
    );
  }
}

class LibraryScreenWrapper extends StatelessWidget {
  const LibraryScreenWrapper({super.key});

  Future<void> _capturarDeGaleria(BuildContext context) async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );

    if (image == null) return;
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Escaneando captura en el dispositivo...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final candidates = await CandidateExtractor.extractCandidatesFromPath(image.path);

      if (candidates.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se detectó texto en la imagen.')),
        );
        return;
      }

      final matches = await CandidateResolver.resolveCandidates(candidates);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ConfirmationBottomSheet.show(
        context,
        matches: matches,
        onSave: (selectedMatches) async {
          Navigator.pop(context);

          try {
            final supabase = Supabase.instance.client;
            final user = await _ensureSession();

            for (final match in selectedMatches) {
              await supabase.from('media_items').insert({
                if (user?.id != null) 'user_id': user!.id,
                'format': match.format,
                'title': match.title,
                'creator': match.creator,
                'cover_url': match.coverUrl,
                'synopsis': match.synopsis,
                'status': 'to_consume',
              });
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Se guardaron ${selectedMatches.length} obras en tu biblioteca.'),
                ),
              );
            }
          } catch (e) {
            debugPrint('Error guardando en Supabase: $e');
          }
        },
      );
    } catch (e) {
      debugPrint('Error en el escaneo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escanear: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const LibraryScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _capturarDeGaleria(context),
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Subir Captura'),
      ),
    );
  }
}