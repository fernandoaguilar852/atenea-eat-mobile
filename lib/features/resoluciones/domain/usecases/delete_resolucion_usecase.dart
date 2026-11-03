import '../repositories/resoluciones_repository.dart';

class DeleteResolucionUseCase {
  final ResolucionesRepository repository;

  const DeleteResolucionUseCase({required this.repository});

  Future<void> call({
    required int resolucionId,
    required int clienteId,
  }) async {
    return await repository.deleteResolucion(
      resolucionId: resolucionId,
      clienteId: clienteId,
    );
  }
}
