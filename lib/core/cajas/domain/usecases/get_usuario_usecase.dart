import '../entities/usuario.dart';
import '../repositories/cajas_repository.dart';

class GetUsuarioUseCase {
  final CajasRepository repository;

  GetUsuarioUseCase(this.repository);

  Future<Usuario> call({
    required int usuarioId,
    required int clienteId,
  }) {
    return repository.getUsuario(
      usuarioId: usuarioId,
      clienteId: clienteId,
    );
  }
}
