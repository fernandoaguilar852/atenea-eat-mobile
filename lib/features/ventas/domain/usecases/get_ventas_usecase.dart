import '../entities/ventas_response.dart';
import '../repositories/ventas_repository.dart';

class GetVentasUseCase {
  final VentasRepository repository;

  GetVentasUseCase(this.repository);

  Future<VentasResponse> call({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? startDate,
    String? endDate,
    String? estado,
    int? cajaId,
    int? operadorId,
  }) {
    return repository.getVentas(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
      startDate: startDate,
      endDate: endDate,
      estado: estado,
      cajaId: cajaId,
      operadorId: operadorId,
    );
  }
}
