import '../../../reportes/domain/entities/pagination.dart';
import 'insumo.dart';

class InsumosResponse {
  final List<Insumo> insumos;
  final Pagination pagination;

  InsumosResponse({
    required this.insumos,
    required this.pagination,
  });
}
