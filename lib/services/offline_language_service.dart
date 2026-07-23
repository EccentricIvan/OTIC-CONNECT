import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineLanguageService extends ChangeNotifier {
  OfflineLanguageService._();

  static final OfflineLanguageService instance = OfflineLanguageService._();

  static const defaultLanguageCode = 'en';
  static const prefsKey = 'app_locale';
  static const supportedLanguageCodes = {'en', 'lg', 'sw'};

  static const _languagePackPath = 'assets/language_packs';
  static const _chatPackPath = 'assets/chat_packs';

  String _currentLanguageCode = defaultLanguageCode;
  Map<String, String> _languagePack = {};
  Map<String, String> _englishLanguagePack = {};
  Map<String, List<String>> _chatPack = {};
  Map<String, List<String>> _englishChatPack = {};

  String get currentLanguageCode => _currentLanguageCode;

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await loadLanguage(prefs.getString(prefsKey) ?? defaultLanguageCode);
  }

  Future<void> loadLanguage(String code) async {
    final selectedCode = _supportedOrDefault(code);

    final englishLanguagePack = await _loadLanguagePack(defaultLanguageCode);
    final englishChatPack = await _loadChatPack(defaultLanguageCode);

    final selectedLanguagePack =
        selectedCode == defaultLanguageCode
            ? englishLanguagePack
            : await _loadLanguagePack(selectedCode);
    final selectedChatPack =
        selectedCode == defaultLanguageCode
            ? englishChatPack
            : await _loadChatPack(selectedCode);

    _currentLanguageCode = selectedCode;
    _englishLanguagePack = englishLanguagePack;
    _languagePack = selectedLanguagePack;
    _englishChatPack = englishChatPack;
    _chatPack = selectedChatPack;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, selectedCode);

    notifyListeners();
  }

  String t(String key) {
    return _languagePack[key] ?? _englishLanguagePack[key] ?? key;
  }

  List<String> getChatResponses(String category) {
    final selectedResponses = _chatPack[category];
    if (selectedResponses != null && selectedResponses.isNotEmpty) {
      return List.unmodifiable(selectedResponses);
    }

    final englishResponses = _englishChatPack[category];
    if (englishResponses != null && englishResponses.isNotEmpty) {
      return List.unmodifiable(englishResponses);
    }

    return [getFallbackResponse()];
  }

  String getFallbackResponse() {
    final selectedFallback = _chatPack['fallback'];
    if (selectedFallback != null && selectedFallback.isNotEmpty) {
      return selectedFallback.first;
    }

    final englishFallback = _englishChatPack['fallback'];
    if (englishFallback != null && englishFallback.isNotEmpty) {
      return englishFallback.first;
    }

    return t('error_general');
  }

  String _supportedOrDefault(String code) {
    final normalized = _normalizeLanguageCode(code);
    return supportedLanguageCodes.contains(normalized)
        ? normalized
        : defaultLanguageCode;
  }

  String _normalizeLanguageCode(String code) {
    final normalized = code.trim().toLowerCase();
    switch (normalized) {
      case 'english':
        return 'en';
      case 'luganda':
      case 'ganda':
        return 'lg';
      case 'kiswahili':
      case 'swahili':
        return 'sw';
      default:
        return normalized;
    }
  }

  Future<Map<String, String>> _loadLanguagePack(String code) async {
    final raw = await rootBundle.loadString('$_languagePackPath/$code.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<Map<String, List<String>>> _loadChatPack(String code) async {
    final raw = await rootBundle.loadString('$_chatPackPath/${code}_chat.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) {
      final responses =
          value is List
              ? value.map((item) => item.toString()).toList()
              : <String>[value.toString()];
      return MapEntry(key, responses);
    });
  }
}
