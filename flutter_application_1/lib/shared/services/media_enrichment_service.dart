import '../models/media_preview_model.dart';
import 'google_books_service.dart';
import 'tmdb_service.dart';

class EnrichedMediaData {
  final String? creator;
  final String? coverUrl;
  final String? synopsis;

  const EnrichedMediaData({
    this.creator,
    this.coverUrl,
    this.synopsis,
  });
}

class MediaEnrichmentService {
  /// Consulta automáticamente la API correspondiente según el tipo de obra
  static Future<EnrichedMediaData> enrich({
    required String title,
    required MediaType mediaType,
    String? existingCreator,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return const EnrichedMediaData();

    switch (mediaType) {
      case MediaType.book:
        final details = await GoogleBooksService.searchBookDetails(
          cleanTitle,
          author: existingCreator,
        );
        return EnrichedMediaData(
          creator: details['author'],
          coverUrl: details['coverUrl'],
          synopsis: details['synopsis'],
        );

      case MediaType.movie:
      case MediaType.documentary:
        final details = await TmdbService.searchMediaDetails(
          cleanTitle,
          isSeries: false,
        );
        return EnrichedMediaData(
          creator: details['creator'] ?? existingCreator,
          coverUrl: details['coverUrl'],
          synopsis: details['synopsis'],
        );

      case MediaType.series:
        final details = await TmdbService.searchMediaDetails(
          cleanTitle,
          isSeries: true,
        );
        return EnrichedMediaData(
          creator: details['creator'] ?? existingCreator,
          coverUrl: details['coverUrl'],
          synopsis: details['synopsis'],
        );

      case MediaType.podcast:
      case MediaType.youtubeVideo:
      case MediaType.unknown:
        return EnrichedMediaData(
          creator: existingCreator,
        );
    }
  }
}