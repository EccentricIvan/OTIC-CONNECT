class ApiConfig {
  ApiConfig._();

  static const geminiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
}
