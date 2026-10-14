import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExtractedItem {
  final String title;
  final String format; // book | movie | series | podcast | documentary | youtube_video | unknown
  final String? creator;
  final String? synopsis;
  final List<String> tags;
  final double confidence;

  const ExtractedItem({
    required this.title,
    required this.format,
    this.creator,
    this.synopsis,
    this.tags = const [],
    this.confidence = 0,
  });

  factory ExtractedItem.fromJson(Map<String, dynamic> j) => ExtractedItem(
        title: (j['title'] as String?)?.trim() ?? '',
        format: (j['format'] as String?) ?? 'unknown',
        creator: j['creator'] as String?,
        synopsis: j['synopsis'] as String?,
        tags: (j['tags'] as List?)?.whereType<String>().toList() ?? const [],
        confidence: (j['confidence'] as num?)?.toDouble() ?? 0,
      );
}

class AnalysisException implements Exception {
  final String message;
  const AnalysisException(this.message);
  @override
  String toString() => message;
}

class AnalysisClient {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<ExtractedItem>> analyzeScreenshot(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final res = await _db.functions.invoke(
        'extract-and-enrich',
        body: {'imageBase64': base64Encode(bytes), 'mimeType': mimeType},
      );

      final payload = res.data;
      if (payload is! Map || payload['success'] != true) {
        throw AnalysisException(_errorFrom(payload));
      }

      final rawItems = (payload['data'] as Map?)?['items'] as List? ?? const [];
      return rawItems
          .whereType<Map>()
          .map((m) => ExtractedItem.fromJson(Map<String, dynamic>.from(m)))
          .where((i) => i.title.isNotEmpty)
          .toList();
    } on FunctionException catch (e) { // Nombre correcto en supabase_flutter
      debugPrint('Edge Function ${e.status}: ${e.details}');
      throw AnalysisException(_errorFrom(e.details));
    } catch (e) {
      debugPrint('Error inesperado al analizar: $e');
      throw const AnalysisException('No se pudo analizar la imagen. Intentá de nuevo.');
    }
  }

  String _errorFrom(dynamic payload) {
    if (payload is Map && payload['error'] is String) {
      return payload['error'] as String;
    }
    return 'No se pudo analizar la imagen. Intentá de nuevo.';
  }
}