import '../../domain/entities/caja.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/cajas_repository.dart';
import '../datasources/cajas_remote_datasource.dart';

class CajasRepositoryImpl implements CajasRepository {
  final CajasRemoteDatasource remoteDatasource;

  CajasRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<Caja>> getCajas({
    required int clienteId,
  }) async {
    try {
      final dtos = await remoteDatasource.getCajas(
        clienteId: clienteId,
      );
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Usuario> getUsuario({
    required int usuarioId,
    required int clienteId,
  }) async {
    try {
      final dto = await remoteDatasource.getUsuario(
        usuarioId: usuarioId,
        clienteId: clienteId,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
