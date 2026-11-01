class ApiConstants {
  // Base URL - AWS Lambda API Gateway
  static const String baseUrl = 'https://qb6rm2lu73.execute-api.us-east-1.amazonaws.com';
  static const String apiVersion = '/Prod/v1/pos';

  // Endpoints de Autenticación
  static const String login = '/login';
  static const String logout = '/login/logout';
  static const String refreshToken = '/refresh-token';

  // Endpoints de Dashboard y Reportes
  static const String dashboard = '/dashboard';
  static const String consultaEstadisticas = '/reportes/consulta-estadisticas';
  static const String reportes = '/reportes';
  static const String reporteVentas = '/reportes/ventas';
  static const String reporteInventarioConsumido = '/reportes/inventario-consumido';
  static const String reporteArqueoCaja = '/reportes/arqueo-caja';
  static const String reporteStockProductos = '/reportes/stock-productos';
  static const String reporteStockInsumos = '/reportes/stock-insumos';
  static const String reporteCostoBeneficio = '/reportes/costo-beneficio';

  // Endpoints de Chat IA
  static const String chatQuery = '/chat/query';

  // Endpoints de Notificaciones
  static const String notificaciones = '/notificaciones';

  // Endpoints de Productos
  static const String products = '/products';
  static const String tiposProducto = '/tipos-producto';

  // Endpoints de Consumidores
  static const String consumidores = '/consumidores';

  // Endpoints de Cajas
  static const String cajas = '/cajas';

  // Endpoints de Usuarios
  static const String usuarios = '/usuarios';

  // Endpoints de Operadores
  static const String operadores = '/operadores';

  // Endpoints de Insumos
  static const String insumos = '/insumos';

  // Endpoints de Movimientos
  static const String movimientosInventario = '/movimientos-inventario';

  // Endpoints de Proveedores
  static const String proveedores = '/proveedores';

  // Endpoints de Ventas
  static const String ventas = '/ventas';

  // Headers requeridos por la API
  static const String headerContentType = 'Content-Type';
  static const String headerMessageUuid = 'message-uuid';
  static const String headerRequestAppId = 'request-app-id';
  static const String headerAuthorization = 'Authorization';

  // App ID por defecto
  static const String defaultAppId = '550e8400-e29b-41d4-a716-446655440001';

  // Helper para construir URLs
  static String buildUrl(String endpoint) {
    return '$baseUrl$apiVersion$endpoint';
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
