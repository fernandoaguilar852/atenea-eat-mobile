import '../entities/venta_detallada.dart';
import '../repositories/ventas_repository.dart';

class GetVentaDetalleUseCase {
  final VentasRepository repository;

  GetVentaDetalleUseCase({required this.repository});

  Future<VentaDetallada> call({
    required int ventaId,
    required int clienteId,
  }) async {
    return await repository.getVentaDetalle(
      ventaId: ventaId,
      clienteId: clienteId,
    );
  }
}
