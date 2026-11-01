import '../../domain/entities/movimientos_response.dart';
import '../../domain/entities/movimiento.dart';
import '../../domain/entities/movimiento_detalle.dart';
import '../../domain/repositories/movimientos_repository.dart';
import '../datasources/movimientos_remote_datasource.dart';
import '../models/registrar_movimiento_request_dto.dart';
import '../models/actualizar_movimiento_request_dto.dart';
import '../models/eliminar_movimiento_request_dto.dart';

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
    int? productoId,
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

  @override
  Future<MovimientoDetalle> getMovimientoDetalle({
    required int movimientoId,
    required int clienteId,
  }) async {
    try {
      final dto = await remoteDatasource.getMovimientoDetalle(
        movimientoId: movimientoId,
        clienteId: clienteId,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MovimientoDetalle> actualizarMovimiento({
    required int movimientoId,
    required int clienteId,
    required double cantidad,
    required String observacion,
    required int updatedByUsuarioId,
  }) async {
    try {
      final request = ActualizarMovimientoRequestDto(
        cantidad: cantidad,
        observacion: observacion,
        updatedByUsuarioId: updatedByUsuarioId,
      );

      final dto = await remoteDatasource.actualizarMovimiento(
        movimientoId: movimientoId,
        clienteId: clienteId,
        request: request,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> eliminarMovimiento({
    required int movimientoId,
    required int clienteId,
    required int deletedByUsuarioId,
    required String deleteReason,
  }) async {
    try {
      final request = EliminarMovimientoRequestDto(
        deletedByUsuarioId: deletedByUsuarioId,
        deleteReason: deleteReason,
      );

      await remoteDatasource.eliminarMovimiento(
        movimientoId: movimientoId,
        clienteId: clienteId,
        request: request,
      );
    } catch (e) {
      rethrow;
    }
  }
}
