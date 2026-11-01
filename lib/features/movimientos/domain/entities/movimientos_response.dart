import 'movimiento.dart';
import '../../../reportes/domain/entities/pagination.dart';

class MovimientosResponse {
  final List<Movimiento> movimientos;
  final Pagination pagination;

  MovimientosResponse({
    required this.movimientos,
    required this.pagination,
  });
}
