Luciérnaga [EN PROCESO]

Luciérnaga busca ser  app móvil en Flutter para guardar y organizar libros, películas, series, podcasts y videos de YouTube que descubres en TikTok e Instagram.

Guarda cada obra en dos taps con portada, datos oficiales, plataformas donde verla o escucharla, fuente de origen, tags, estado (Por ver, En proceso, Completado) y reseña.

⚡ Características principales
Flujo ultrarrápido: Vía Share Intent desde Instagram/TikTok o detección rápida de capturas.

Pipeline "Buscar y Verificar": OCR local en el dispositivo combinado con búsquedas paralelas en APIs oficiales.

Soporte multiformato: Integración con Google Books, TMDB y Spotify.

Selección múltiple (Batch Saving): Identifica y guarda varias obras detectadas en una sola imagen (ej. listas o tops).

Backend seguro: Supabase (PostgreSQL, RLS y Edge Functions).

🏗️ Arquitectura en breve
[ Captura / Share Intent ] ──► [ OCR Local (ML Kit) ] ──► [ Filtro de Ruido ]
                                                                 │
[ Guardado en Batch (Supabase) ] ◄── [ Checklist de Selección ] ◄┼── [ Búsqueda Paralela (APIs) ]
🛠️ Tech Stack
Frontend: Flutter

OCR: Google ML Kit Text Recognition

Backend & Auth: Supabase (PostgreSQL, RLS)

APIs: TMDB API, Google Books API, Spotify Web API
