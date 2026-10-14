import 'google_books_service.dart';
import 'tmdb_service.dart';

class ResolvedMatch {
  final String title;
  final String? creator;
  final String? coverUrl;
  final String? synopsis;
  final String format;

  ResolvedMatch({
    required this.title,
    this.creator,
    this.coverUrl,
    this.synopsis,
    required this.format,
  });
}

class CandidateResolver {
  static Future<List<ResolvedMatch>> resolveCandidates(List<String> candidates) async {
    final List<ResolvedMatch> matches = [];
    final Set<String> foundTitles = {};

    for (final candidate in candidates.take(6)) {
      final book = await GoogleBooksService.searchBookDetails(candidate);
      if (book['coverUrl'] != null && book['author'] != null) {
        final title = candidate;
        if (!foundTitles.contains(title.toLowerCase())) {
          foundTitles.add(title.toLowerCase());
          matches.add(ResolvedMatch(
            title: title,
            creator: book['author'],
            coverUrl: book['coverUrl'],
            synopsis: book['synopsis'],
            format: 'book',
          ));
          continue;
        }
      }

      final media = await TmdbService.searchMediaDetails(candidate, isSeries: false);
      if (media['coverUrl'] != null) {
        final title = candidate;
        if (!foundTitles.contains(title.toLowerCase())) {
          foundTitles.add(title.toLowerCase());
          matches.add(ResolvedMatch(
            title: title,
            creator: media['creator'],
            coverUrl: media['coverUrl'],
            synopsis: media['synopsis'],
            format: 'movie',
          ));
        }
      }
    }

    return matches;
  }
}