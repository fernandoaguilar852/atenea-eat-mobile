import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/ivas_response_dto.dart';

abstract class IvasRemoteDatasource {
  Future<IvasResponseDto> getIvas({
    required int pageSize,
    required int pageNumber,
  });
}

class IvasRemoteDatasourceImpl implements IvasRemoteDatasource {
  final Dio dio;

  IvasRemoteDatasourceImpl({required this.dio});

  @override
  Future<IvasResponseDto> getIvas({
    required int pageSize,
    required int pageNumber,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'pageSize': pageSize,
        'pageNumber': pageNumber,
      };

      final response = await dio.get(
        ApiConstants.buildUrl(ApiConstants.ivas),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return IvasResponseDto.fromJson(response.data);
      } else {
        throw Exception('Error al obtener IVAs - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
