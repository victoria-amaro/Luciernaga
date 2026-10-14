import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GoogleBooksService {
  /// Opcional: flutter run --dart-define=GOOGLE_BOOKS_API_KEY=xxxx
  /// Sin key funciona, pero con cuota compartida más baja.
  static const _apiKey = String.fromEnvironment('GOOGLE_BOOKS_API_KEY');

  static const _empty = <String, String?>{
    'author': null,
    'coverUrl': null,
    'synopsis': null,
    'infoLink': null,
    'googleBooksId': null,
  };

  /// Busca detalles del libro usando título y creador opcional
  static Future<Map<String, String?>> searchBookDetails(
    String title, {
    String? author,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return _empty;

    try {
      final q = StringBuffer('intitle:$cleanTitle');
      if (author != null && author.trim().isNotEmpty) {
        q.write(' inauthor:${author.trim()}');
      }

      final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
        'q': q.toString(),
        'maxResults': '5',
        'printType': 'books',
        if (_apiKey.isNotEmpty) 'key': _apiKey,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint('GoogleBooks HTTP ${response.statusCode} para "$cleanTitle"');
        return _empty;
      }

      final data = json.decode(utf8.decode(response.bodyBytes));
      final items = (data is Map ? data['items'] : null) as List?;
      if (items == null || items.isEmpty) return _empty;

      final best = _pickBest(items, cleanTitle);
      final volumeInfo = (best['volumeInfo'] as Map?) ?? const {};

      final authors = (volumeInfo['authors'] as List?)?.whereType<String>().toList();
      final imageLinks = volumeInfo['imageLinks'] as Map?;

      String? coverUrl =
          (imageLinks?['thumbnail'] ?? imageLinks?['smallThumbnail']) as String?;
      if (coverUrl != null) {
        coverUrl = coverUrl
            .replaceFirst('http://', 'https://')
            .replaceAll('&edge=curl', ''); // Quita el efecto de esquina doblada
      }

      return {
        'author': (authors != null && authors.isNotEmpty) ? authors.join(', ') : null,
        'coverUrl': coverUrl,
        'synopsis': _stripHtml(volumeInfo['description'] as String?),
        'infoLink': volumeInfo['infoLink'] as String?,
        'googleBooksId': best['id'] as String?,
      };
    } on TimeoutException {
      debugPrint('GoogleBooks timeout para "$cleanTitle"');
    } catch (e, st) {
      debugPrint('GoogleBooks error para "$cleanTitle": $e\n$st');
    }
    return _empty;
  }

  /// Elige la mejor coincidencia que tenga portada y coincida con el título
  static Map _pickBest(List items, String query) {
    final q = _norm(query);
    final maps = items.whereType<Map>().toList();

    bool titleMatches(Map m) {
      final t = _norm(((m['volumeInfo'] as Map?)?['title'] as String?) ?? '');
      return t.isNotEmpty && (t == q || t.contains(q) || q.contains(t));
    }

    bool hasCover(Map m) => ((m['volumeInfo'] as Map?)?['imageLinks']) != null;

    return maps.firstWhere(
      (m) => titleMatches(m) && hasCover(m),
      orElse: () => maps.firstWhere(titleMatches, orElse: () => maps.first),
    );
  }

  static String _norm(String s) {
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    var out = s.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  static String? _stripHtml(String? html) {
    if (html == null) return null;
    final text = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
    return text.isEmpty ? null : text;
  }
}