import '../entities/caja.dart';
import '../entities/usuario.dart';

abstract class CajasRepository {
  Future<List<Caja>> getCajas({
    required int clienteId,
  });

  Future<Usuario> getUsuario({
    required int usuarioId,
    required int clienteId,
  });
}
