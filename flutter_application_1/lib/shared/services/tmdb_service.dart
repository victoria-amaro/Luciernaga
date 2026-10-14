import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TmdbService {
  // Opcional: flutter run --dart-define=TMDB_API_KEY=tu_api_key
  static const _apiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: 'TU_API_KEY_AQUI', // Pegá tu clave de TMDB si preferís hardcodearla en dev
  );

  static const _baseUrl = 'api.themoviedb.org';
  static const _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Busca una película, serie o documental en TMDB por título
  static Future<Map<String, String?>> searchMediaDetails(
    String title, {
    required bool isSeries,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty || _apiKey == 'TU_API_KEY_AQUI') {
      return {'creator': null, 'coverUrl': null, 'synopsis': null};
    }

    try {
      final endpoint = isSeries ? '/3/search/tv' : '/3/search/movie';
      final uri = Uri.https(_baseUrl, endpoint, {
        'api_key': _apiKey,
        'query': cleanTitle,
        'language': 'es-ES', // Idioma para traer la sinopsis en español
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final results = data['results'] as List?;

        if (results != null && results.isNotEmpty) {
          final firstMatch = results[0] as Map<String, dynamic>;

          final posterPath = firstMatch['poster_path'] as String?;
          final coverUrl = posterPath != null ? '$_imageBaseUrl$posterPath' : null;
          final overview = firstMatch['overview'] as String?;

          // Extraer año de estreno
          final releaseDate = isSeries
              ? firstMatch['first_air_date'] as String?
              : firstMatch['release_date'] as String?;
          final year = releaseDate != null && releaseDate.length >= 4
              ? releaseDate.substring(0, 4)
              : null;

          return {
            'creator': year != null ? 'Estreno: $year' : null,
            'coverUrl': coverUrl,
            'synopsis': overview?.isNotEmpty == true ? overview : null,
          };
        }
      } else {
        debugPrint('TMDB HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en TmdbService para "$cleanTitle": $e');
    }

    return {'creator': null, 'coverUrl': null, 'synopsis': null};
  }
}