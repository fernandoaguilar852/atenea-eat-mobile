import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/resoluciones_response_dto.dart';

abstract class ResolucionesRemoteDatasource {
  Future<ResolucionesResponseDto> getResoluciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
    String? startDate,
    String? endDate,
  });

  Future<void> crearResolucion({
    required int clienteId,
    required String prefijo,
    required int numeroDesde,
    required int numeroHasta,
    required int numeroActual,
    required String numeroResolucion,
    required String fechaResolucion,
    required String fechaVencimiento,
    required bool activo,
  });
}

class ResolucionesRemoteDatasourceImpl implements ResolucionesRemoteDatasource {
  final Dio dio;

  const ResolucionesRemoteDatasourceImpl({required this.dio});

  @override
  Future<ResolucionesResponseDto> getResoluciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
    String? startDate,
    String? endDate,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    // Solo agregar parámetros opcionales si tienen valor
    if (activo != null) {
      queryParameters['activo'] = activo;
    }
    if (startDate != null) {
      queryParameters['startDate'] = startDate;
    }
    if (endDate != null) {
      queryParameters['endDate'] = endDate;
    }

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.resoluciones),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return ResolucionesResponseDto.fromJson(response.data);
    } else {
      throw Exception('Error al obtener resoluciones - Status: ${response.statusCode}');
    }
  }

  @override
  Future<void> crearResolucion({
    required int clienteId,
    required String prefijo,
    required int numeroDesde,
    required int numeroHasta,
    required int numeroActual,
    required String numeroResolucion,
    required String fechaResolucion,
    required String fechaVencimiento,
    required bool activo,
  }) async {
    final body = {
      'prefijo': prefijo,
      'numeroDesde': numeroDesde,
      'numeroHasta': numeroHasta,
      'numeroActual': numeroActual,
      'numeroResolucion': numeroResolucion,
      'fechaResolucion': fechaResolucion,
      'fechaVencimiento': fechaVencimiento,
      'activo': activo,
    };

    final response = await dio.post(
      ApiConstants.buildUrl('${ApiConstants.resoluciones}?clienteId=$clienteId'),
      data: body,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear resolución - Status: ${response.statusCode}');
    }
  }
}
