import 'package:dio/dio.dart';
import '../../../constants/api_constants.dart';
import '../models/operador_dto.dart';

abstract class OperadoresRemoteDatasource {
  Future<List<OperadorDto>> searchOperadores({
    required int clienteId,
    required String search,
    int pageSize = 100,
    int pageNumber = 1,
  });
}

class OperadoresRemoteDatasourceImpl implements OperadoresRemoteDatasource {
  final Dio dio;

  OperadoresRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<OperadorDto>> searchOperadores({
    required int clienteId,
    required String search,
    int pageSize = 100,
    int pageNumber = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
      'search': search,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.operadores),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data']['operadores'] as List<dynamic>;
      return data.map((json) => OperadorDto.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al buscar operadores - Status: ${response.statusCode}');
    }
  }
}
