import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CandidateExtractor {
  static final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static final List<RegExp> _noisePatterns = [
    RegExp(r'^@\w+$'),
    RegExp(r'^#\w+'),
    RegExp(r'^\d+[.,]?\d*\s*(mil|[kKmM])?\s*(likes?|views?|comentarios?)?$', caseSensitive: false),
    RegExp(r'^(sígueme|sigueme|follow|like|share|comparte|guarda esto|seguir)$', caseSensitive: false),
    RegExp(r'^\d{1,2}:\d{2}$'),
    RegExp(r'^(buscar|search|buscar contenido).*', caseSensitive: false),
    RegExp(r'^(qué opinás|que opinas|dejame un comentario|comentar)', caseSensitive: false),
    RegExp(r'^only on\s+\w+$', caseSensitive: false),
  ];

  static Future<List<String>> extractCandidatesFromPath(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    final List<String> candidates = [];

    for (final TextBlock block in recognizedText.blocks) {
      for (final TextLine line in block.lines) {
        final text = line.text.trim();
        if (_isValidCandidate(text)) {
          candidates.add(text);
        }
      }
    }

    return candidates.toSet().toList();
  }

  static bool _isValidCandidate(String text) {
    if (text.length < 3 || text.length > 80) return false;

    for (final pattern in _noisePatterns) {
      if (pattern.hasMatch(text)) return false;
    }

    return true;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}