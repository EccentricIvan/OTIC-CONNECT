class ApiConfig {
  static const String _groqKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  static String get groqKey => _groqKey.trim();

  static bool get hasGroqKey {
    final key = groqKey;
    return key.isNotEmpty &&
        !key.contains('YOUR_API_KEY') &&
        !key.contains('TODO') &&
        !key.contains('PASTE');
  }
}
