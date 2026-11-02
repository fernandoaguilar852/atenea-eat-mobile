import 'package:dio/dio.dart';
import '../../../constants/api_constants.dart';
import '../models/caja_dto.dart';
import '../models/usuario_dto.dart';

abstract class CajasRemoteDatasource {
  Future<List<CajaDto>> getCajas({
    required int clienteId,
  });

  Future<UsuarioDto> getUsuario({
    required int usuarioId,
    required int clienteId,
  });
}

class CajasRemoteDatasourceImpl implements CajasRemoteDatasource {
  final Dio dio;

  CajasRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<CajaDto>> getCajas({
    required int clienteId,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': 100,
      'pageNumber': 1,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.cajas),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data']['cajas'] as List<dynamic>;
      return data.map((json) => CajaDto.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al obtener cajas - Status: ${response.statusCode}');
    }
  }

  @override
  Future<UsuarioDto> getUsuario({
    required int usuarioId,
    required int clienteId,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
    };

    final response = await dio.get(
      ApiConstants.buildUrl('${ApiConstants.usuarios}/$usuarioId'),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return UsuarioDto.fromJson(response.data['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Error al obtener usuario - Status: ${response.statusCode}');
    }
  }
}
