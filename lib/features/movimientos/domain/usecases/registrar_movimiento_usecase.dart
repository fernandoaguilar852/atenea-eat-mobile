import '../entities/movimiento.dart';
import '../repositories/movimientos_repository.dart';

class RegistrarMovimientoUseCase {
  final MovimientosRepository repository;

  RegistrarMovimientoUseCase(this.repository);

  Future<Movimiento> call({
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
  }) {
    return repository.registrarMovimiento(
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
  }
}
