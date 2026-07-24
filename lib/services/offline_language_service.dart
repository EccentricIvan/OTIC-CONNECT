import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class ContentEntry {
  const ContentEntry({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.keywords,
    required this.phrases,
  });

  factory ContentEntry.fromJson(Map<String, dynamic> json) {
    final question = json['question']?.toString().trim() ?? '';
    return ContentEntry(
      id: json['id']?.toString().trim() ?? question,
      category: json['category']?.toString().trim() ?? '',
      question: question,
      answer: json['answer']?.toString().trim() ?? '',
      keywords: _readStringList(json['keywords']),
      phrases: _readStringList(json['phrases']),
    );
  }

  final String id;
  final String category;
  final String question;
  final String answer;
  final List<String> keywords;
  final List<String> phrases;

  static List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    final singleValue = value?.toString().trim();
    return singleValue == null || singleValue.isEmpty
        ? const []
        : [singleValue];
  }
}

class _ScoredContentEntry {
  const _ScoredContentEntry(this.entry, this.score);

  final ContentEntry entry;
  final double score;
}

class OfflineLanguageService extends ChangeNotifier {
  OfflineLanguageService._();

  static final OfflineLanguageService instance = OfflineLanguageService._();

  static const defaultLanguageCode = 'en';
  static const prefsKey = 'app_locale';
  static const supportedLanguageCodes = {'en', 'lg', 'sw'};

  static const _languagePackPath = 'assets/language_packs';
  static const _chatPackPath = 'assets/chat_packs';
  static const _contentPackPath = 'assets/content_packs';
  static const _minimumSearchScore = 12.0;

  String _currentLanguageCode = defaultLanguageCode;
  Map<String, String> _languagePack = {};
  Map<String, String> _englishLanguagePack = {};
  Map<String, List<String>> _chatPack = {};
  Map<String, List<String>> _englishChatPack = {};
  List<ContentEntry> _contentEntries = [];

  String get currentLanguageCode => _currentLanguageCode;

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await loadLanguage(prefs.getString(prefsKey) ?? defaultLanguageCode);
  }

  Future<void> loadLanguage(String code) async {
    final selectedCode = _supportedOrDefault(code);

    final englishLanguagePack = await _loadLanguagePack(defaultLanguageCode);
    final englishChatPack = await _loadChatPack(defaultLanguageCode);
    final selectedContentPack = await _loadContentPack(selectedCode);

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
    _contentEntries = selectedContentPack;

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

  List<ContentEntry> getContentEntries() {
    return List.unmodifiable(_contentEntries);
  }

  List<ContentEntry> searchContent(String userMessage, {int limit = 3}) {
    if (limit <= 0 || _contentEntries.isEmpty) return const [];

    final normalizedMessage = _normalizeForSearch(userMessage);
    if (normalizedMessage.isEmpty) return const [];

    final messageTerms = _searchTerms(normalizedMessage);
    final scoredEntries = <_ScoredContentEntry>[];

    for (final entry in _contentEntries) {
      final score = _scoreContentEntry(
        entry,
        normalizedMessage,
        messageTerms,
      );
      if (score >= _minimumSearchScore && entry.answer.trim().isNotEmpty) {
        scoredEntries.add(_ScoredContentEntry(entry, score));
      }
    }

    scoredEntries.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      return scoreComparison == 0
          ? a.entry.id.compareTo(b.entry.id)
          : scoreComparison;
    });

    return List.unmodifiable(
      scoredEntries.take(limit).map((scored) => scored.entry),
    );
  }

  String getOfflineChatReply(String userMessage) {
    final matches = searchContent(userMessage, limit: 1);
    if (matches.isNotEmpty) {
      return matches.first.answer;
    }

    return _firstChatResponse(_chatPack, 'general_help') ??
        getFallbackResponse();
  }

  String buildGroqContext(String userMessage) {
    final entries = searchContent(userMessage, limit: 3);
    if (entries.isEmpty) return '';

    final buffer =
        StringBuffer()
          ..writeln(
            'Human-reviewed Africa AI Connect reference context for the '
            'selected language ($_currentLanguageCode).',
          )
          ..writeln(
            'Use these entries as grounding when they are relevant. Answer '
            'naturally in the selected language and do not contradict this '
            'context.',
          );

    for (var index = 0; index < entries.length; index += 1) {
      final entry = entries[index];
      buffer
        ..writeln()
        ..writeln('Reference ${index + 1}')
        ..writeln('Category: ${entry.category}')
        ..writeln('Question: ${entry.question}')
        ..writeln('Answer: ${entry.answer}');

      if (entry.keywords.isNotEmpty) {
        buffer.writeln('Keywords: ${entry.keywords.join(', ')}');
      }
    }

    return buffer.toString().trim();
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

  String? _firstChatResponse(
    Map<String, List<String>> chatPack,
    String category,
  ) {
    final responses = chatPack[category];
    if (responses == null || responses.isEmpty) return null;

    final first = responses.first.trim();
    return first.isEmpty ? null : first;
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

  Future<List<ContentEntry>> _loadContentPack(String code) async {
    try {
      final raw = await rootBundle.loadString(
        '$_contentPackPath/${code}_content.json',
      );
      final decoded = jsonDecode(raw);
      final entriesJson =
          decoded is Map<String, dynamic> ? decoded['entries'] : decoded;

      if (entriesJson is! List) return const [];

      return entriesJson
          .whereType<Map>()
          .map((item) => ContentEntry.fromJson(Map<String, dynamic>.from(item)))
          .where((entry) => entry.answer.trim().isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  double _scoreContentEntry(
    ContentEntry entry,
    String normalizedMessage,
    Set<String> messageTerms,
  ) {
    var score = 0.0;

    score += _phraseScore(entry.question, normalizedMessage, 70, 30, 16);

    for (final phrase in entry.phrases) {
      score += _phraseScore(phrase, normalizedMessage, 60, 42, 16);
    }

    final normalizedCategory = _normalizeForSearch(entry.category);
    if (normalizedCategory.isNotEmpty &&
        normalizedMessage.contains(normalizedCategory)) {
      score += 24;
    }
    score += _cappedOverlapScore(
      messageTerms,
      _searchTerms(entry.category),
      8,
      24,
    );

    for (final keyword in entry.keywords) {
      final normalizedKeyword = _normalizeForSearch(keyword);
      if (normalizedKeyword.isEmpty) continue;

      if (normalizedKeyword == normalizedMessage) {
        score += 35;
      } else if (normalizedKeyword.length > 1 &&
          normalizedMessage.contains(normalizedKeyword)) {
        score += 22;
      } else {
        score += _cappedOverlapScore(
          messageTerms,
          _searchTerms(normalizedKeyword),
          7,
          14,
        );
      }
    }

    score += _cappedOverlapScore(
      messageTerms,
      _searchTerms(entry.question),
      5,
      30,
    );
    score += _cappedOverlapScore(
      messageTerms,
      _searchTerms(entry.answer),
      2,
      14,
    );

    return score;
  }

  double _phraseScore(
    String value,
    String normalizedMessage,
    double exactScore,
    double containsScore,
    double reverseContainsScore,
  ) {
    final normalizedValue = _normalizeForSearch(value);
    if (normalizedValue.isEmpty) return 0;

    if (normalizedValue == normalizedMessage) return exactScore;
    if (normalizedValue.length > 1 &&
        normalizedMessage.contains(normalizedValue)) {
      return containsScore;
    }
    if (normalizedMessage.length >= 8 &&
        normalizedValue.contains(normalizedMessage)) {
      return reverseContainsScore;
    }

    return 0;
  }

  double _cappedOverlapScore(
    Set<String> first,
    Set<String> second,
    double weight,
    double cap,
  ) {
    if (first.isEmpty || second.isEmpty) return 0;

    var count = 0;
    for (final term in first) {
      if (second.contains(term)) count += 1;
    }

    final score = count * weight;
    return score > cap ? cap : score.toDouble();
  }

  Set<String> _searchTerms(String value) {
    final normalized = _normalizeForSearch(value);
    if (normalized.isEmpty) return const {};

    return normalized
        .split(' ')
        .where((term) => term.length > 1 && !_stopWords.contains(term))
        .toSet();
  }

  String _normalizeForSearch(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[_\-/]'), ' ')
        .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
        .replaceAll("'", ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static const _stopWords = {
    'a',
    'about',
    'again',
    'am',
    'an',
    'and',
    'are',
    'as',
    'at',
    'be',
    'can',
    'do',
    'does',
    'for',
    'from',
    'have',
    'help',
    'how',
    'i',
    'in',
    'is',
    'it',
    'me',
    'my',
    'of',
    'on',
    'or',
    'please',
    'should',
    'that',
    'the',
    'this',
    'to',
    'want',
    'what',
    'when',
    'where',
    'with',
    'you',
    'your',
    'za',
    'ya',
    'na',
    'kwa',
    'ku',
    'ni',
    'nini',
    'nina',
    'nifanye',
    'jinsi',
    'gani',
    'au',
    'wa',
    'la',
    'cha',
    'vya',
    'katika',
    'kwenye',
    'nga',
    'oba',
    'era',
    'mu',
    'kuva',
    'ki',
    'kiki',
    'nze',
    'gwe',
    'okukola',
    'okufuna',
    'okuyamba',
    'tya',
  };
}
