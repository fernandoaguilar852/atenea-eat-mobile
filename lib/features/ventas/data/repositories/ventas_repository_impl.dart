import '../../domain/entities/ventas_response.dart';
import '../../domain/entities/venta_detallada.dart';
import '../../domain/repositories/ventas_repository.dart';
import '../datasources/ventas_remote_datasource.dart';

class VentasRepositoryImpl implements VentasRepository {
  final VentasRemoteDatasource remoteDatasource;

  VentasRepositoryImpl({required this.remoteDatasource});

  @override
  Future<VentasResponse> getVentas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? startDate,
    String? endDate,
    String? estado,
    int? cajaId,
    int? operadorId,
  }) async {
    try {
      final dto = await remoteDatasource.getVentas(
        clienteId: clienteId,
        pageSize: pageSize,
        pageNumber: pageNumber,
        startDate: startDate,
        endDate: endDate,
        estado: estado,
        cajaId: cajaId,
        operadorId: operadorId,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<VentaDetallada> getVentaDetalle({
    required int ventaId,
    required int clienteId,
  }) async {
    try {
      final dto = await remoteDatasource.getVentaDetalle(
        ventaId: ventaId,
        clienteId: clienteId,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
