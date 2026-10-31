import '../entities/estadisticas.dart';
import '../repositories/dashboard_repository.dart';

class GetEstadisticasUseCase {
  final DashboardRepository _repository;

  GetEstadisticasUseCase(this._repository);

  /// Obtiene las estadísticas del día actual para un cliente
  ///
  /// [clienteId] ID del cliente obtenido del token JWT
  /// Si no se proporcionan fechas, usa la fecha actual
  Future<Estadisticas> call({
    required int clienteId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Si no se proporcionan fechas, usar fecha actual
    final now = DateTime.now();
    final start = startDate ?? DateTime(now.year, now.month, now.day);
    final end = endDate ?? DateTime(now.year, now.month, now.day);

    if (clienteId <= 0) {
      throw Exception('ID de cliente inválido');
    }

    return await _repository.getEstadisticas(
      clienteId: clienteId,
      startDate: start,
      endDate: end,
    );
  }
}
