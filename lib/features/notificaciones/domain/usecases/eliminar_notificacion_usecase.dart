import '../repositories/notificaciones_repository.dart';

class EliminarNotificacionUseCase {
  final NotificacionesRepository repository;

  EliminarNotificacionUseCase(this.repository);

  Future<void> call({
    required int notificacionId,
    required int clienteId,
  }) async {
    return await repository.eliminarNotificacion(
      notificacionId: notificacionId,
      clienteId: clienteId,
    );
  }
}
