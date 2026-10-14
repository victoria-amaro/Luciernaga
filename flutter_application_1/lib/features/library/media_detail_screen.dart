import 'package:flutter/material.dart';

class MediaDetailScreen extends StatelessWidget {
  final String title;
  final String format;
  final String? coverUrl;

  const MediaDetailScreen({
    super.key,
    required this.title,
    required this.format,
    this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Cabecera con la portada grande en alta definición
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: coverUrl != null
                    ? Image.network(
                        coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderHeader(theme),
                      )
                    : _buildPlaceholderHeader(theme),
              ),
            ),
          ),

          // Contenido principal de la ficha (Estilo Letterboxd)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la obra
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Formato y Creador/Autor
                  Text(
                    '$format · Autor/Creador no especificado',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón dinámico de acceso directo (Spotify / Netflix / Google Books)
                  _buildPrimaryActionButton(context, format),
                  const SizedBox(height: 16),

                  // Valoración con 5 estrellas interactiva
                  const Text(
                    'Mi Calificación',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < 4 ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Etiquetas / Subcategorías
                  Wrap(
                    spacing: 8,
                    children: const [
                      Chip(label: Text('#Recomendado')),
                      Chip(label: Text('#Gym')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sinopsis / Notas personales
                  Text(
                    'Sinopsis / Reseña',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acá va la sinopsis oficial cargada automáticamente o las notas personales que escribas sobre este contenido.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Evidencia del origen (Captura / Reel / TikTok)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Guardado automáticamente desde una captura · Hace 2 días',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderHeader(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.auto_stories_rounded,
        size: 64,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPrimaryActionButton(BuildContext context, String format) {
    // Definimos el color y el ícono según el formato (Spotify, Netflix, etc.)
    final isPodcast = format.contains('Podcast');
    final isMovie = format.contains('Película') || format.contains('Serie');

    final color = isPodcast
        ? const Color(0xFF1DB954) // Verde Spotify
        : (isMovie ? const Color(0xFFE50914) : const Color(0xFF4285F4));

    final icon = isPodcast
        ? Icons.podcasts_rounded
        : (isMovie ? Icons.play_arrow_rounded : Icons.menu_book_rounded);

    final label = isPodcast
        ? 'Escuchar en Spotify'
        : (isMovie ? 'Disponible en Netflix / Streaming' : 'Ver en Google Books');

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}