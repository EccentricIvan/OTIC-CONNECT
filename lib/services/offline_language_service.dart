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

@immutable
class OfflineChatResult {
  const OfflineChatResult({
    required this.answer,
    required this.suggestedQuestions,
    this.matchedEntryId,
    this.matchedCategory,
  });

  final String answer;
  final List<String> suggestedQuestions;
  final String? matchedEntryId;
  final String? matchedCategory;
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

  List<ContentEntry> searchContent(
    String userMessage, {
    int limit = 3,
    Iterable<String> contextMessages = const [],
  }) {
    if (limit <= 0 || _contentEntries.isEmpty) return const [];

    final normalizedMessage = _normalizeForSearch(userMessage);
    final normalizedContext = _normalizeForSearch(contextMessages.join(' '));
    if (normalizedMessage.isEmpty && normalizedContext.isEmpty) return const [];

    final messageTerms = _searchTerms(normalizedMessage);
    final contextTerms = _searchTerms(normalizedContext);
    final isFollowUp = isFollowUpMessage(normalizedMessage);
    final contextWeight =
        isFollowUp && !_hasTopicHint(messageTerms) ? 0.85 : 0.35;
    final scoredEntries = <_ScoredContentEntry>[];

    for (final entry in _contentEntries) {
      final messageScore =
          normalizedMessage.isEmpty
              ? 0.0
              : _scoreContentEntry(entry, normalizedMessage, messageTerms);
      final contextScore =
          normalizedContext.isEmpty
              ? 0.0
              : _scoreContentEntry(entry, normalizedContext, contextTerms);
      final score = messageScore + (contextScore * contextWeight);
      final minimumScore = isFollowUp ? 8.0 : _minimumSearchScore;

      if (score >= minimumScore && entry.answer.trim().isNotEmpty) {
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

  String getOfflineChatReply(
    String userMessage, {
    Iterable<String> contextMessages = const [],
  }) {
    return getOfflineChatResult(
      userMessage,
      contextMessages: contextMessages,
    ).answer;
  }

  OfflineChatResult getOfflineChatResult(
    String userMessage, {
    Iterable<String> contextMessages = const [],
    String? previousEntryId,
    String? previousCategory,
  }) {
    final matches = searchContent(
      userMessage,
      contextMessages: contextMessages,
      limit: 6,
    );
    final isFollowUp = isFollowUpMessage(userMessage);
    final primary = _selectPrimaryEntry(
      matches,
      isFollowUp: isFollowUp,
      previousEntryId: previousEntryId,
      previousCategory: previousCategory,
    );

    if (primary == null) {
      final answer =
          _firstChatResponse(_chatPack, 'general_help') ??
          _helpfulFallbackAnswer();
      return OfflineChatResult(
        answer: answer,
        suggestedQuestions: getOfflineSuggestedQuestions(
          userMessage,
          contextMessages: contextMessages,
        ),
      );
    }

    final related = _relatedEntries(
      primary,
      matches,
      excludedIds: {
        primary.id,
        if (isFollowUp && previousEntryId != null) previousEntryId,
      },
      limit: 2,
    );
    return OfflineChatResult(
      answer: _composeOfflineAnswer(
        primary,
        related,
        isFollowUp: isFollowUp,
        isRepeatedTopic: primary.id == previousEntryId,
      ),
      suggestedQuestions: getOfflineSuggestedQuestions(
        userMessage,
        contextMessages: contextMessages,
      ),
      matchedEntryId: primary.id,
      matchedCategory: primary.category,
    );
  }

  List<String> getOfflineSuggestedQuestions(
    String userMessage, {
    Iterable<String> contextMessages = const [],
    int limit = 3,
  }) {
    if (limit <= 0 || _contentEntries.isEmpty) return const [];

    final matches = searchContent(
      userMessage,
      contextMessages: contextMessages,
      limit: 5,
    );
    final suggestions = <String>[];

    void addQuestion(ContentEntry entry) {
      final question = entry.question.trim();
      if (question.isEmpty) return;

      final normalizedQuestion = _normalizeForSearch(question);
      final normalizedMessage = _normalizeForSearch(userMessage);
      final alreadyAdded = suggestions.any(
        (item) => _normalizeForSearch(item) == normalizedQuestion,
      );

      if (alreadyAdded || normalizedQuestion == normalizedMessage) return;

      suggestions.add(question);
    }

    if (matches.isNotEmpty) {
      final topicTerms = _searchTerms(matches.first.category);
      for (final entry in _contentEntries) {
        if (suggestions.length >= limit) break;
        if (entry.id == matches.first.id) continue;
        if (_hasTermOverlap(topicTerms, _searchTerms(entry.category))) {
          addQuestion(entry);
        }
      }

      for (final entry in matches) {
        if (suggestions.length >= limit) break;
        addQuestion(entry);
      }
    }

    for (final entry in _contentEntries) {
      if (suggestions.length >= limit) break;
      if (_normalizeForSearch(entry.category).contains('greeting') ||
          _normalizeForSearch(entry.category).contains('salamu') ||
          _normalizeForSearch(entry.category).contains('okulamusa')) {
        continue;
      }
      addQuestion(entry);
    }

    return List.unmodifiable(suggestions.take(limit));
  }

  String buildGroqContext(
    String userMessage, {
    Iterable<String> contextMessages = const [],
  }) {
    final entries = searchContent(
      userMessage,
      contextMessages: contextMessages,
      limit: 3,
    );
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

  ContentEntry? _selectPrimaryEntry(
    List<ContentEntry> matches, {
    required bool isFollowUp,
    String? previousEntryId,
    String? previousCategory,
  }) {
    if (matches.isEmpty) return null;

    if (!isFollowUp) return matches.first;

    if (previousCategory != null && previousCategory.trim().isNotEmpty) {
      final previousCategoryTerms = _searchTerms(previousCategory);
      for (final entry in matches) {
        if (entry.id == previousEntryId) continue;
        if (_hasTermOverlap(
          previousCategoryTerms,
          _searchTerms(entry.category),
        )) {
          return entry;
        }
      }
    }

    for (final entry in matches) {
      if (entry.id != previousEntryId) return entry;
    }

    return matches.first;
  }

  List<ContentEntry> _relatedEntries(
    ContentEntry primary,
    List<ContentEntry> matches, {
    required Set<String?> excludedIds,
    required int limit,
  }) {
    final related = <ContentEntry>[];
    final primaryTerms = _searchTerms(primary.category);

    void addEntry(ContentEntry entry) {
      if (related.length >= limit || excludedIds.contains(entry.id)) return;

      final alreadyAdded = related.any((item) => item.id == entry.id);
      if (!alreadyAdded) related.add(entry);
    }

    for (final entry in matches) {
      if (_hasTermOverlap(primaryTerms, _searchTerms(entry.category))) {
        addEntry(entry);
      }
    }

    for (final entry in _contentEntries) {
      if (related.length >= limit) break;
      if (_hasTermOverlap(primaryTerms, _searchTerms(entry.category))) {
        addEntry(entry);
      }
    }

    return List.unmodifiable(related);
  }

  String _composeOfflineAnswer(
    ContentEntry primary,
    List<ContentEntry> related, {
    required bool isFollowUp,
    required bool isRepeatedTopic,
  }) {
    final parts = <String>[];
    final bridge = _followUpBridge();

    if (isFollowUp && bridge.isNotEmpty) {
      parts.add(bridge);
    }

    if (!isRepeatedTopic || related.isEmpty) {
      parts.add(primary.answer);
    }

    final guidance = _categoryGuidance(primary.category);
    if (guidance.isNotEmpty) {
      parts.add(guidance);
    }

    if (related.isNotEmpty) {
      parts.add(
        '${_relatedLeadIn()} ${related.map((entry) => entry.answer).join(' ')}',
      );
    }

    return parts.where((part) => part.trim().isNotEmpty).join('\n\n');
  }

  String _followUpBridge() {
    switch (_currentLanguageCode) {
      case 'lg':
        return 'Ka tweyongere ku nsonga eyo.';
      case 'sw':
        return 'Tuendelee na mada hiyo.';
      default:
        return 'Building on that topic.';
    }
  }

  String _relatedLeadIn() {
    switch (_currentLanguageCode) {
      case 'lg':
        return 'Ekirala ekikwatagana nakyo:';
      case 'sw':
        return 'Jambo lingine linalohusiana:';
      default:
        return 'A related point:';
    }
  }

  String _helpfulFallbackAnswer() {
    switch (_currentLanguageCode) {
      case 'lg':
        return 'Nsobola okukuyamba ku busubuzi, bulimi, nsimbi, bulamu, mirimu, obukugu bwa ssimu, n\'ekibiina. Buuza ekibuuzo kimu mu bigambo ebyangu, nja kukuyamba mu mitendera.';
      case 'sw':
        return 'Ninaweza kusaidia kuhusu biashara, kilimo, pesa, afya, kazi, ujuzi wa simu, na jamii. Uliza swali moja kwa maneno rahisi, nami nitakusaidia kwa hatua.';
      default:
        return 'I can help with business, farming, money, health, jobs, digital skills, online selling, and community questions. Ask one clear question, and I will help step by step.';
    }
  }

  String _categoryGuidance(String category) {
    final normalized = _normalizeForSearch(category);

    if (_categoryContains(normalized, const [
      'business',
      'obusubuzi',
      'biashara',
    ])) {
      switch (_currentLanguageCode) {
        case 'lg':
          return 'Kino kikole mu ngeri eyangu: londa bakasitoma b\'oyagala okuweereza, manya ensaasaanya yo, teekawo bbeeyi ekuwa amagoba, era wandiika buli kyotunda.';
        case 'sw':
          return 'Ifanye kwa vitendo: tambua wateja unaowalenga, jua gharama zako, weka bei yenye faida, na andika kila unachouza.';
        default:
          return 'Make it practical: choose the customers you want to serve, know your costs, set a price that leaves profit, and record every sale.';
      }
    }

    if (_categoryContains(normalized, const [
      'financial',
      'savings',
      'money',
      'ensimbi',
      'fedha',
      'akiba',
      'mobile',
    ])) {
      switch (_currentLanguageCode) {
        case 'lg':
          return 'Tandika n\'akatono k\'osobola okukola buli kiseera. Yawula ssente z\'awaka ku z\'omulimu, era weekebereze ensaasaanya buli wiiki.';
        case 'sw':
          return 'Anza na kiasi kidogo unachoweza kurudia mara kwa mara. Tenganisha pesa ya nyumbani na ya kazi, kisha kagua matumizi kila wiki.';
        default:
          return 'Start with a small habit you can repeat. Separate home money from work money, then review spending every week.';
      }
    }

    if (_categoryContains(normalized, const [
      'farming',
      'agriculture',
      'obulimi',
      'kilimo',
    ])) {
      switch (_currentLanguageCode) {
        case 'lg':
          return 'Mu bulimi, tandika n\'ekitundu ekitono, goberera sizoni n\'amazzi g\'olina, era buuza omukugu w\'ebyobulimi nga tonnasaasaanya nnyo.';
        case 'sw':
          return 'Katika kilimo, anza na eneo dogo, fuata msimu na maji uliyonayo, na uliza afisa ugani kabla ya kutumia pesa nyingi.';
        default:
          return 'For farming, start with a small area, match the season and water you have, and ask an extension worker before spending heavily.';
      }
    }

    if (_categoryContains(normalized, const [
      'health',
      'nutrition',
      'obulamu',
      'afya',
    ])) {
      switch (_currentLanguageCode) {
        case 'lg':
          return 'Ku nsonga z\'obulamu, kola ku byangu ebikuuma: amazzi amayonjo, emmere ey\'enjawulo, okuwummula, n\'okufuna omusawo mangu obubonero bwe bweyongera.';
        case 'sw':
          return 'Kwa afya, shikilia mambo ya msingi: maji safi, chakula bora, kupumzika, na kutafuta mhudumu wa afya mapema dalili zikizidi.';
        default:
          return 'For health, focus on the basics: clean water, balanced meals, rest, and early care if symptoms worsen.';
      }
    }

    if (_categoryContains(normalized, const [
      'job',
      'career',
      'cv',
      'emirimu',
      'kazi',
    ])) {
      switch (_currentLanguageCode) {
        case 'lg':
          return 'Ku mirimu, tegeka CV ennyimpi, laga obukugu bw\'olina, saba emirimu egikukwatako, era oddemu okubuuza mu ngeri ey\'ekitiibwa.';
        case 'sw':
          return 'Kwa kazi, andaa CV fupi, onyesha ujuzi ulionao, omba kazi zinazokufaa, na fuatilia kwa heshima.';
        default:
          return 'For jobs, prepare a short CV, show the skills you already have, apply for suitable roles, and follow up politely.';
      }
    }

    if (_categoryContains(normalized, const [
      'digital',
      'phone',
      'internet',
      'obukugu',
      'ssimu',
      'simu',
      'intaneti',
      'yintaneeti',
    ])) {
      switch (_currentLanguageCode) {
        case 'lg':
          return 'Ku bukugu bwa ssimu, yiga ekintu kimu buli lunaku: okunoonyereza, obukuumi bwa PIN, okukuba ebifaananyi, oba okuwandiika ebiwandiiko ebyangu.';
        case 'sw':
          return 'Kwa ujuzi wa simu, jifunze jambo moja kila siku: kutafuta taarifa, kulinda PIN, kupiga picha wazi, au kuweka rekodi rahisi.';
        default:
          return 'For digital skills, practise one small thing each day: searching, PIN safety, clear photos, or simple records.';
      }
    }

    if (_categoryContains(normalized, const [
      'online',
      'selling',
      'marketplace',
      'okutunda',
      'kuuza',
      'mtandaoni',
    ])) {
      switch (_currentLanguageCode) {
        case 'lg':
          return 'Nga otunda ku mutimbagano, ebifaananyi bitegeerekeke, bbeeyi ebeere mu lwatu, era kakasa okusasulwa nga tonnatwala kintu.';
        case 'sw':
          return 'Unapouza mtandaoni, tumia picha zilizo wazi, bei iwe wazi, na thibitisha malipo kabla ya kupeleka bidhaa.';
        default:
          return 'When selling online, use clear photos, make the price clear, and confirm payment before delivery.';
      }
    }

    if (_categoryContains(normalized, const [
      'community',
      'group',
      'leadership',
      'ekibiina',
      'jamii',
      'kikundi',
    ])) {
      switch (_currentLanguageCode) {
        case 'lg':
          return 'Mu kibiina, amateeka amalambulukufu, ebiwandiiko eby\'amazima, n\'okusalawo mu lwatu biyamba abantu okwesigagana.';
        case 'sw':
          return 'Katika kikundi, sheria zilizo wazi, rekodi za kweli, na maamuzi ya wazi husaidia watu kuaminiana.';
        default:
          return 'In a group, clear rules, honest records, and open decisions help people trust each other.';
      }
    }

    if (_categoryContains(normalized, const [
      'wellbeing',
      'safety',
      'stress',
      'ustawi',
      'usalama',
      'msongo',
      'obukuumi',
      'situleesi',
    ])) {
      switch (_currentLanguageCode) {
        case 'lg':
          return 'Bw\'oba owulira situleesi oba obutali bukuumi, sooka ofune ekifo ekikuuma, yogera n\'omuntu gwe weesiga, era tuukirira obuyambi obwesigika.';
        case 'sw':
          return 'Ukihisi msongo au hauko salama, tafuta sehemu salama kwanza, zungumza na mtu unayemwamini, na wasiliana na msaada unaoaminika.';
        default:
          return 'If you feel stressed or unsafe, first move toward safety, talk to someone you trust, and contact trusted support.';
      }
    }

    return '';
  }

  bool _categoryContains(String normalizedCategory, List<String> terms) {
    return terms.any(normalizedCategory.contains);
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

  bool _hasTermOverlap(Set<String> first, Set<String> second) {
    if (first.isEmpty || second.isEmpty) return false;

    for (final term in first) {
      if (second.contains(term)) return true;
    }
    return false;
  }

  bool _hasTopicHint(Set<String> terms) {
    if (terms.isEmpty) return false;

    for (final term in terms) {
      if (_topicHints.contains(term)) return true;
    }
    return false;
  }

  Set<String> _searchTerms(String value) {
    final normalized = _normalizeForSearch(value);
    if (normalized.isEmpty) return const {};

    return normalized
        .split(' ')
        .where((term) => term.length > 1 && !_stopWords.contains(term))
        .toSet();
  }

  bool isFollowUpMessage(String message) {
    final normalizedMessage = _normalizeForSearch(message);
    if (normalizedMessage.isEmpty) return true;

    final terms = _searchTerms(normalizedMessage);
    if (terms.length <= 2 &&
        normalizedMessage.length <= 32 &&
        !_hasTopicHint(terms)) {
      return true;
    }

    return _followUpPhrases.any(normalizedMessage.contains);
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

  static const _followUpPhrases = {
    'explain more',
    'tell me more',
    'give examples',
    'more examples',
    'what about',
    'how can i start',
    'how do i start',
    'next step',
    'steps',
    'ekirala',
    'nnyonnyola',
    'ongera okunnyonnyola',
    'mpa ebyokulabirako',
    'ntandika ntya',
    'hatua',
    'eleza zaidi',
    'nipe mifano',
    'vipi kuhusu',
    'ninawezaje kuanza',
  };

  static const _topicHints = {
    'business',
    'entrepreneur',
    'customer',
    'profit',
    'sales',
    'market',
    'money',
    'saving',
    'savings',
    'budget',
    'mobile',
    'sacco',
    'farming',
    'agriculture',
    'crop',
    'crops',
    'soil',
    'pests',
    'health',
    'medical',
    'pregnancy',
    'nutrition',
    'job',
    'jobs',
    'career',
    'cv',
    'digital',
    'phone',
    'internet',
    'online',
    'community',
    'group',
    'safety',
    'stress',
    'biashara',
    'mjasiriamali',
    'faida',
    'fedha',
    'pesa',
    'akiba',
    'bajeti',
    'kilimo',
    'mazao',
    'udongo',
    'wadudu',
    'afya',
    'daktari',
    'ujauzito',
    'kazi',
    'ujuzi',
    'simu',
    'intaneti',
    'mtandaoni',
    'jamii',
    'kikundi',
    'usalama',
    'msongo',
    'obusubuzi',
    'bakasitoma',
    'magoba',
    'ensimbi',
    'ssente',
    'okutereka',
    'obulimi',
    'ebirime',
    'ettaka',
    'obuwuka',
    'obulamu',
    'omusawo',
    'olubuto',
    'emirimu',
    'obukugu',
    'ssimu',
    'yintaneeti',
    'mutimbagano',
    'ekibiina',
    'obukuumi',
    'situleesi',
  };

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
