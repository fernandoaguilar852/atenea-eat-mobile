import '../entities/notificacion.dart';
import '../entities/pagination.dart';

abstract class NotificacionesRepository {
  Future<(List<Notificacion>, Pagination)> getNotificaciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    required String estado,
  });

  Future<void> marcarComoLeida({
    required int notificacionId,
    required int clienteId,
  });

  Future<void> eliminarNotificacion({
    required int notificacionId,
    required int clienteId,
  });
}
