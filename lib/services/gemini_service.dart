import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class GeminiService {
  static const _model = 'gemini-2.0-flash';
  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  static const _systemPrompt = '''You are Otic She Connect AI Assistant — a warm, supportive, and knowledgeable companion for women in Sub-Saharan Africa.

Your role is to help women with:
- Business and entrepreneurship advice
- Agricultural tips and farming guidance
- Financial literacy (savings, budgeting, mobile money, SACCOs)
- Health and nutrition information
- Digital skills guidance
- Job and career advice
- Community building and leadership

Guidelines:
- Be warm, encouraging, and practical
- Give concise, actionable advice
- Use simple language accessible to all literacy levels
- Be culturally sensitive to East African context
- When discussing health topics, recommend consulting a healthcare professional for serious concerns
- Celebrate their efforts and progress
- Keep responses under 200 words unless asked for detail''';

  final List<Map<String, dynamic>> _history = [];

  Future<String> sendMessage(String message) async {
    _history.add({
      'role': 'user',
      'parts': [{'text': message}],
    });

    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=${ApiConfig.geminiKey}');

    final body = jsonEncode({
      'system_instruction': {
        'parts': [{'text': _systemPrompt}],
      },
      'contents': _history,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 512,
      },
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'I could not generate a response. Please try again.';

        _history.add({
          'role': 'model',
          'parts': [{'text': text}],
        });

        return text;
      } else {
        final error = jsonDecode(response.body);
        final msg = error['error']?['message'] ?? 'Unknown error';
        return 'Sorry, I encountered an error: $msg';
      }
    } catch (e) {
      return 'I\'m having trouble connecting. Please check your internet connection and try again.';
    }
  }

  void clearHistory() {
    _history.clear();
  }
}
