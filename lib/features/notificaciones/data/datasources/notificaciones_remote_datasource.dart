import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/notificaciones_response_dto.dart';

abstract class NotificacionesRemoteDatasource {
  Future<NotificacionesResponseDto> getNotificaciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    required String estado,
  });

  Future<void> marcarComoLeida({
    required int notificacionId,
    required int clienteId,
  });

  Future<void> eliminarNotificacion({
    required int notificacionId,
    required int clienteId,
  });
}

class NotificacionesRemoteDatasourceImpl implements NotificacionesRemoteDatasource {
  final Dio dio;

  NotificacionesRemoteDatasourceImpl({required this.dio});

  @override
  Future<NotificacionesResponseDto> getNotificaciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    required String estado,
  }) async {
    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.notificaciones),
      queryParameters: {
        'clienteId': clienteId,
        'pageSize': pageSize,
        'pageNumber': pageNumber,
        'estado': estado,
      },
    );

    if (response.statusCode == 200) {
      return NotificacionesResponseDto.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Error al obtener notificaciones');
    }
  }

  @override
  Future<void> marcarComoLeida({
    required int notificacionId,
    required int clienteId,
  }) async {
    final response = await dio.patch(
      ApiConstants.buildUrl('${ApiConstants.notificaciones}/$notificacionId'),
      queryParameters: {
        'clienteId': clienteId,
      },
      data: {
        'estado': 'LEIDA',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al marcar notificación como leída');
    }
  }

  @override
  Future<void> eliminarNotificacion({
    required int notificacionId,
    required int clienteId,
  }) async {
    final response = await dio.delete(
      ApiConstants.buildUrl('${ApiConstants.notificaciones}/$notificacionId'),
      queryParameters: {
        'clienteId': clienteId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar notificación');
    }
  }
}
