import 'consumidor.dart';
import 'pagination.dart';

class ConsumidoresResponse {
  final List<Consumidor> consumidores;
  final Pagination pagination;

  ConsumidoresResponse({
    required this.consumidores,
    required this.pagination,
  });
}
