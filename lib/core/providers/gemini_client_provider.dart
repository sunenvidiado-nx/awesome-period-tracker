import 'package:awesome_period_tracker/core/environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiClient {
  GeminiClient({required this.model});

  final GenerativeModel model;

  Future<String> generateContentFromText({required String prompt}) async {
    return model.generateContent(
      [Content.text(prompt)],
      safetySettings: [
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      ],
    ).then((value) => value.text ?? '');
  }
}

final geminiClientProvider = Provider((ref) {
  return GeminiClient(
    model: GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: Environment.geminiApiKey,
    ),
  );
});
