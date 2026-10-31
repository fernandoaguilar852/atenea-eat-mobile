import '../entities/estadisticas.dart';

abstract class DashboardRepository {
  /// Obtiene las estadísticas del día para un cliente específico
  ///
  /// [clienteId] ID del cliente obtenido del token JWT
  /// [startDate] Fecha de inicio del rango de consulta
  /// [endDate] Fecha de fin del rango de consulta
  Future<Estadisticas> getEstadisticas({
    required int clienteId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
