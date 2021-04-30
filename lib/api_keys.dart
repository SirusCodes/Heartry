class APIKeys {
  static String get googleAuth =>
      const String.fromEnvironment("GOOGLE_AUTH_API");
}
