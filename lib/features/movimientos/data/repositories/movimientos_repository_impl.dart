import '../../domain/entities/movimientos_response.dart';
import '../../domain/entities/movimiento.dart';
import '../../domain/repositories/movimientos_repository.dart';
import '../datasources/movimientos_remote_datasource.dart';
import '../models/registrar_movimiento_request_dto.dart';

class MovimientosRepositoryImpl implements MovimientosRepository {
  final MovimientosRemoteDatasource remoteDatasource;

  MovimientosRepositoryImpl({required this.remoteDatasource});

  @override
  Future<MovimientosResponse> getMovimientos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? fechaDesde,
    String? fechaHasta,
    int? productoId,
    int? insumoId,
  }) async {
    try {
      final dto = await remoteDatasource.getMovimientos(
        clienteId: clienteId,
        pageSize: pageSize,
        pageNumber: pageNumber,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        productoId: productoId,
        insumoId: insumoId,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Movimiento> registrarMovimiento({
    required int productoId,
    int? insumoId,
    required int usuarioId,
    required int clienteId,
    int? proveedorId,
    required String tipo,
    required double costo,
    required double impuesto,
    required double descuentoUnidad,
    required int cantidad,
    required String observacion,
    required String fecha,
  }) async {
    try {
      final request = RegistrarMovimientoRequestDto(
        productoId: productoId,
        insumoId: insumoId,
        usuarioId: usuarioId,
        clienteId: clienteId,
        proveedorId: proveedorId,
        tipo: tipo,
        costo: costo,
        impuesto: impuesto,
        descuentoUnidad: descuentoUnidad,
        cantidad: cantidad,
        observacion: observacion,
        fecha: fecha,
      );

      final dto = await remoteDatasource.registrarMovimiento(request: request);
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
