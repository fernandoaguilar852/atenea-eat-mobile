class ApiConstants {
  // Base URL - Ajustar según ambiente
  static const String baseUrl = 'https://qb6rm2lu73.execute-api.us-east-1.amazonaws.com';
  static const String apiVersion = '/api/v1/pos';

  // Endpoints de Autenticación
  static const String login = '/usuarios/login';
  static const String logout = '/usuarios/logout';
  static const String refreshToken = '/usuarios/refresh-token';

  // Endpoints de Dashboard
  static const String dashboard = '/dashboard';
  static const String estadisticas = '/dashboard/estadisticas';

  // Helper para construir URLs
  static String buildUrl(String endpoint) {
    return '$baseUrl$apiVersion$endpoint';
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
