import '../entities/notificacion.dart';
import '../entities/pagination.dart';
import '../repositories/notificaciones_repository.dart';

class GetNotificacionesUseCase {
  final NotificacionesRepository repository;

  GetNotificacionesUseCase(this.repository);

  Future<(List<Notificacion>, Pagination)> call({
    required int clienteId,
    int pageSize = 10,
    int pageNumber = 1,
    String estado = 'PENDIENTE',
  }) async {
    return await repository.getNotificaciones(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
      estado: estado,
    );
  }
}
