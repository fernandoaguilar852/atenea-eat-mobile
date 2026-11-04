import '../entities/ivas_response.dart';

abstract class IvasRepository {
  Future<IvasResponse> getIvas({
    required int pageSize,
    required int pageNumber,
  });
}
