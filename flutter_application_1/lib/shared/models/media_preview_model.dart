enum SourcePlatform {
  tiktok,
  instagram,
  youtube,
  screenshot,
  manual,
}

enum MediaType {
  book,
  movie,
  series,
  podcast,
  documentary,
  youtubeVideo,
  unknown,
}

enum LoadingStage {
  extracting,
  enriching,
  ready,
  failed,
}

class MediaPreviewModel {
  final SourcePlatform source;
  final DateTime capturedAt;
  final LoadingStage stage;
  final MediaType mediaType;
  final String? title;
  final String? creator;
  final String? coverUrl;
  final String? originalUrl;

  MediaPreviewModel({
    required this.source,
    required this.capturedAt,
    required this.stage,
    this.mediaType = MediaType.unknown,
    this.title,
    this.creator,
    this.coverUrl,
    this.originalUrl,
  });

  String get mediaTypeLabel {
    switch (mediaType) {
      case MediaType.book:
        return '📖 Libro';
      case MediaType.movie:
        return '🎬 Película';
      case MediaType.series:
        return '📺 Serie';
      case MediaType.podcast:
        return '🎙️ Podcast';
      case MediaType.documentary:
        return '🎞️ Documental';
      case MediaType.youtubeVideo:
        return '▶️ Video de YouTube';
      case MediaType.unknown:
        return '✨ Obra cultural';
    }
  }

  MediaPreviewModel copyWith({
    SourcePlatform? source,
    DateTime? capturedAt,
    LoadingStage? stage,
    MediaType? mediaType,
    String? title,
    String? creator,
    String? coverUrl,
    String? originalUrl,
  }) {
    return MediaPreviewModel(
      source: source ?? this.source,
      capturedAt: capturedAt ?? this.capturedAt,
      stage: stage ?? this.stage,
      mediaType: mediaType ?? this.mediaType,
      title: title ?? this.title,
      creator: creator ?? this.creator,
      coverUrl: coverUrl ?? this.coverUrl,
      originalUrl: originalUrl ?? this.originalUrl,
    );
  }
}