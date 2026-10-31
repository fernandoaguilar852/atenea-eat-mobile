import '../repositories/notificaciones_repository.dart';

class MarcarNotificacionLeidaUseCase {
  final NotificacionesRepository repository;

  MarcarNotificacionLeidaUseCase(this.repository);

  Future<void> call({
    required int notificacionId,
    required int clienteId,
  }) async {
    return await repository.marcarComoLeida(
      notificacionId: notificacionId,
      clienteId: clienteId,
    );
  }
}
