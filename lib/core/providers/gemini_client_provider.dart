import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiClient {
  GeminiClient({required this.model});

  final GenerativeModel model;

  Future generateContentFromText({required String prompt}) async {
    return model.generateContent(
      [Content.text(prompt)],
      safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ],
      generationConfig: GenerationConfig(maxOutputTokens: 50),
    ).then((value) => value.text ?? '');
  }
}

final geminiClientProvider = Provider<GeminiClient>((ref) {
  throw UnimplementedError('Instantiate in main.dart');
});
