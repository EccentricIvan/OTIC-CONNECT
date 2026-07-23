import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../core/l10n/app_strings.dart';
import 'api_config.dart';
import 'offline_language_service.dart';

String getAiLanguageInstruction(AppLocale locale) {
  switch (locale) {
    case AppLocale.lg:
      return '''
The user selected Luganda / Oluganda.
You must always reply in clear, natural Luganda.
Do not switch to English unless the user explicitly asks.
If a technical word has no natural Luganda translation, keep the technical word in English and explain it simply in Luganda.
Keep the tone warm, practical, and helpful for Ugandan users.
Every answer in this conversation must continue in Luganda.
''';
    case AppLocale.sw:
      return '''
The user selected Kiswahili.
You must always reply in clear, natural Kiswahili.
Do not switch to English unless the user explicitly asks.
If a technical word has no natural Kiswahili translation, keep the technical word in English and explain it simply in Kiswahili.
Keep the tone warm, practical, and helpful.
Every answer in this conversation must continue in Kiswahili.
''';
    case AppLocale.en:
      return '''
The user selected English.
Reply in clear, simple English.
''';
  }
}

class GeminiService {
  static const _model = 'llama-3.3-70b-versatile';
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static const _systemPrompt =
      '''You are the Africa AI Connect Assistant — a warm, supportive, and knowledgeable companion for women in Sub-Saharan Africa.

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

  Future<String> sendMessage(String message, AppLocale selectedLocale) async {
    final languageService = OfflineLanguageService.instance;
    if (languageService.currentLanguageCode != selectedLocale.name) {
      await languageService.loadLanguage(selectedLocale.name);
    }
    final effectiveLocale = AppLocale.fromLanguageCode(
      languageService.currentLanguageCode,
    );

    _history.add({'role': 'user', 'content': message});

    if (!ApiConfig.hasGroqKey || await _isOffline()) {
      return _offlineReplyFor(message);
    }

    final messages = [
      {'role': 'system', 'content': getAiLanguageInstruction(effectiveLocale)},
      {'role': 'system', 'content': _systemPrompt},
      ..._history,
    ];

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ApiConfig.groqKey}',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'temperature': 0.7,
              'max_tokens': 512,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['choices']?[0]?['message']?['content'] ??
            languageService.getFallbackResponse();

        _history.add({'role': 'assistant', 'content': text});
        return text;
      } else {
        return _offlineReplyFor(message);
      }
    } catch (_) {
      return _offlineReplyFor(message);
    }
  }

  void clearHistory() {
    _history.clear();
  }

  Future<bool> _isOffline() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.every((result) => result == ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  String _offlineReplyFor(String message) {
    final languageService = OfflineLanguageService.instance;
    final category = _offlineCategoryFor(message);

    if (category == null) {
      final reply = languageService.getFallbackResponse();
      _history.add({'role': 'assistant', 'content': reply});
      return reply;
    }

    final responses = languageService.getChatResponses(category);
    if (responses.isEmpty) {
      final reply = languageService.getFallbackResponse();
      _history.add({'role': 'assistant', 'content': reply});
      return reply;
    }

    final index = (message.hashCode & 0x7fffffff) % responses.length;
    final reply = responses[index];
    _history.add({'role': 'assistant', 'content': reply});
    return reply;
  }

  String? _offlineCategoryFor(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('hello') ||
        lower.contains('hi') ||
        lower.contains('habari') ||
        lower.contains('agandi') ||
        lower.contains('gyebale')) {
      return 'greetings';
    }

    if (lower.contains('study') ||
        lower.contains('learn') ||
        lower.contains('school') ||
        lower.contains('read') ||
        lower.contains('soma') ||
        lower.contains('shoma')) {
      return 'study_advice';
    }

    if (lower.contains('buy') ||
        lower.contains('sell') ||
        lower.contains('store') ||
        lower.contains('market') ||
        lower.contains('price') ||
        lower.contains('gula') ||
        lower.contains('tunda') ||
        lower.contains('soko')) {
      return 'store_help';
    }

    return null;
  }
}
