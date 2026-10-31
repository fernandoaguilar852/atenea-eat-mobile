import '../../domain/entities/notificacion.dart';
import '../../domain/entities/pagination.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../datasources/notificaciones_remote_datasource.dart';
import '../mappers/notificaciones_mapper.dart';

class NotificacionesRepositoryImpl implements NotificacionesRepository {
  final NotificacionesRemoteDatasource remoteDatasource;

  NotificacionesRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<(List<Notificacion>, Pagination)> getNotificaciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    required String estado,
  }) async {
    try {
      final response = await remoteDatasource.getNotificaciones(
        clienteId: clienteId,
        pageSize: pageSize,
        pageNumber: pageNumber,
        estado: estado,
      );

      final notificaciones = response.data.notificaciones
          .map((dto) => NotificacionesMapper.fromDto(dto))
          .toList();

      final pagination = NotificacionesMapper.paginationFromDto(response.pagination);

      return (notificaciones, pagination);
    } catch (e) {
      throw Exception('Error al obtener notificaciones: $e');
    }
  }

  @override
  Future<void> marcarComoLeida({
    required int notificacionId,
    required int clienteId,
  }) async {
    try {
      await remoteDatasource.marcarComoLeida(
        notificacionId: notificacionId,
        clienteId: clienteId,
      );
    } catch (e) {
      throw Exception('Error al marcar notificación como leída: $e');
    }
  }

  @override
  Future<void> eliminarNotificacion({
    required int notificacionId,
    required int clienteId,
  }) async {
    try {
      await remoteDatasource.eliminarNotificacion(
        notificacionId: notificacionId,
        clienteId: clienteId,
      );
    } catch (e) {
      throw Exception('Error al eliminar notificación: $e');
    }
  }
}
