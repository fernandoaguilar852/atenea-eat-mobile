import '../../domain/entities/insumos_response.dart';
import '../../domain/entities/insumo.dart';
import '../../domain/repositories/insumos_repository.dart';
import '../datasources/insumos_remote_datasource.dart';

class InsumosRepositoryImpl implements InsumosRepository {
  final InsumosRemoteDatasource remoteDatasource;

  InsumosRepositoryImpl({required this.remoteDatasource});

  @override
  Future<InsumosResponse> getInsumos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
    String? nombre,
  }) async {
    try {
      final dto = await remoteDatasource.getInsumos(
        clienteId: clienteId,
        pageSize: pageSize,
        pageNumber: pageNumber,
        activo: activo,
        nombre: nombre,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Insumo> getInsumoDetail({
    required int insumoId,
    required int clienteId,
  }) async {
    try {
      final dto = await remoteDatasource.getInsumoDetail(
        insumoId: insumoId,
        clienteId: clienteId,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
