import '../../domain/repositories/ivas_repository.dart';
import '../../domain/entities/ivas_response.dart';
import '../datasources/ivas_remote_datasource.dart';

class IvasRepositoryImpl implements IvasRepository {
  final IvasRemoteDatasource remoteDatasource;

  IvasRepositoryImpl({required this.remoteDatasource});

  @override
  Future<IvasResponse> getIvas({
    required int pageSize,
    required int pageNumber,
  }) async {
    final dto = await remoteDatasource.getIvas(
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
    return dto.toEntity();
  }
}
