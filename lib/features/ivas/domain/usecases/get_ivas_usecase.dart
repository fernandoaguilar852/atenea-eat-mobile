import '../entities/ivas_response.dart';
import '../repositories/ivas_repository.dart';

class GetIvasUseCase {
  final IvasRepository repository;

  const GetIvasUseCase(this.repository);

  Future<IvasResponse> call({
    required int pageSize,
    required int pageNumber,
  }) async {
    return await repository.getIvas(
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }
}
