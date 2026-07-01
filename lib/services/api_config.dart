class ApiConfig {
  ApiConfig._();

  static const groqKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );
}
