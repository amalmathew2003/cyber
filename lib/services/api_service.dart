
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cyber_poster.dart';

class ApiService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static Future<CyberPoster> generatePosterContent(String topic, String apiKey, String language) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {
            'role': 'system',
            'content': '''You are a cybersecurity expert. Generate educational poster content for the given topic. 
            The response must be in $language.
            Return ONLY a valid JSON object with these keys:
            - title (A punchy title with an emoji, e.g., "🚨 LINKEDIN JOB SCAM")
            - description (A brief, engaging hook)
            - warningPoints (List of 4-5 points starting with ⚠️ about the threat)
            - safetyTips (List of 4-5 points starting with ❌ or 🔐 about staying safe)
            - footer (A strong closing message)
            - hashtags (List of 5-6 relevant hashtags)
            
            Structure the content point-wise. Use $language ONLY. Return ONLY JSON.'''
          },
          {
            'role': 'user',
            'content': topic,
          }
        ],
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String textContent = data['choices'][0]['message']['content'];
      final content = jsonDecode(textContent);
      return CyberPoster.fromJson(content);
    } else {
      throw Exception('Failed to generate content: ${response.body}');
    }
  }
}
