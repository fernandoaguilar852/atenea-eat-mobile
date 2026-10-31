import '../../domain/entities/estadisticas.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../mappers/estadisticas_mapper.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource remoteDatasource;

  DashboardRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Estadisticas> getEstadisticas({
    required int clienteId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await remoteDatasource.getEstadisticas(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
      );

      // Validar respuesta exitosa
      if (response.messageResponse.responseCode != '0000') {
        throw Exception(response.messageResponse.responseDetails);
      }

      // Convertir DTO a Entity
      return EstadisticasMapper.fromDto(response);
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
}
