import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  // 👇 UPDATED: Using the Gemini 3 Flash Preview model to match your API access
  static const String _modelName = 'gemini-3-flash-preview';

  Future<String> generateSummary({
    required String articleTitle,
    required String articleDescription,
  }) async {
    print('🚀 [GeminiService] Starting summary generation...');
    
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      print('❌ [GeminiService] CRITICAL ERROR: GEMINI_API_KEY is missing!');
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    
    print('🔑 [GeminiService] API Key successfully loaded.');

    try {
      // Initialize the model with the updated 3.0 string
      final model = GenerativeModel(
        model: _modelName,
        apiKey: apiKey,
        // Optional: Adding generation config to keep the summary concise and factual
        generationConfig: GenerationConfig(
          temperature: 0.3, // Lower temperature = more focused/factual
        ),
      );

      final prompt = '''
      You are an AI news assistant for a highly professional news app. 
      Read the following article title and description, and provide a concise summary.
      
      CRITICAL REQUIREMENT: Your response MUST be exactly two sentences long. No more, no less.
      
      Title: $articleTitle
      Description: $articleDescription
      ''';

      print('🧠 [GeminiService] Sending prompt to Gemini ($_modelName)...');

      // Call the API
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null && response.text!.isNotEmpty) {
        print('✅ [GeminiService] Success!');
        return response.text!.trim();
      } else {
        print('⚠️ [GeminiService] Warning: API returned an EMPTY string.');
        throw Exception('Gemini returned an empty response.');
      }
    } catch (e) {
      print('🚨 ========================================== 🚨');
      print('💥 [GeminiService] EXCEPTION CAUGHT!');
      print('🛑 Details: $e');
      print('🚨 ========================================== 🚨');
      
      return 'Failed to generate summary. Please try again later.';
    }
  }
}