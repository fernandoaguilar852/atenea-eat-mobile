import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/ventas_reporte_dto.dart';
import '../models/inventario_reporte_dto.dart';
import '../models/arqueo_reporte_dto.dart';
import '../models/stock_productos_reporte_dto.dart';
import '../models/stock_insumos_reporte_dto.dart';
import '../models/costo_beneficio_reporte_dto.dart';
import '../models/producto_dto.dart';
import '../models/consumidor_dto.dart';
import '../models/tipo_producto_dto.dart';
import '../models/caja_dto.dart';
import '../models/usuario_dto.dart';
import '../models/operador_dto.dart';
import '../models/insumo_dto.dart';

abstract class ReportesRemoteDatasource {
  Future<VentasReporteResponseDto> getReporteVentas({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    int? consumidorId,
    int? categoriaId,
    int? cajaId,
    int? operadorId,
    required int pageSize,
    required int pageNumber,
  });

  Future<InventarioReporteResponseDto> getReporteInventarioConsumido({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? tipoMovimiento,
    int? productoId,
    int? insumoId,
    required int pageSize,
    required int pageNumber,
  });

  Future<ArqueoReporteResponseDto> getReporteArqueoCaja({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? tipoPago,
    int? cajaId,
    required int pageSize,
    required int pageNumber,
  });

  Future<StockProductosReporteResponseDto> getReporteStockProductos({
    required int clienteId,
    String? nombreProducto,
    int? tipoProductoId,
    String? activo,
    String? stockBajo,
    required int pageSize,
    required int pageNumber,
  });

  Future<StockInsumosReporteResponseDto> getReporteStockInsumos({
    required int clienteId,
    String? nombreInsumo,
    String? activo,
    String? stockBajo,
    required int pageSize,
    required int pageNumber,
  });

  Future<CostoBeneficioReporteResponseDto> getReporteCostoBeneficio({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    int? tipoProductoId,
    String? activo,
    required int pageSize,
    required int pageNumber,
  });

  Future<ProductosResponseDto> searchProductos({
    required int clienteId,
    required String search,
    int pageSize = 10,
    int pageNumber = 1,
  });

  Future<ConsumidoresResponseDto> searchConsumidores({
    required int clienteId,
    required String search,
    int pageSize = 10,
    int pageNumber = 1,
  });

  Future<TiposProductoResponseDto> getTiposProducto({
    required int clienteId,
    bool activo = true,
    int pageSize = 100,
    int pageNumber = 1,
  });

  Future<CajasResponseDto> getCajas({
    required int clienteId,
    int pageSize = 10,
    int pageNumber = 1,
  });

  Future<UsuarioDto> getUsuario({
    required int usuarioId,
    required int clienteId,
  });

  Future<OperadoresResponseDto> getOperadores({
    required int clienteId,
    int pageSize = 100,
    int pageNumber = 1,
  });

  Future<InsumosResponseDto> searchInsumos({
    required int clienteId,
    required String nombre,
    int pageSize = 20,
    int pageNumber = 1,
  });
}

class ReportesRemoteDatasourceImpl implements ReportesRemoteDatasource {
  final Dio dio;

  ReportesRemoteDatasourceImpl({required this.dio});

  @override
  Future<VentasReporteResponseDto> getReporteVentas({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    int? consumidorId,
    int? categoriaId,
    int? cajaId,
    int? operadorId,
    required int pageSize,
    required int pageNumber,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'startDate': startDate,
      'endDate': endDate,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    if (productoId != null) queryParameters['productoId'] = productoId;
    if (consumidorId != null) queryParameters['consumidorId'] = consumidorId;
    if (categoriaId != null) queryParameters['categoriaId'] = categoriaId;
    if (cajaId != null) queryParameters['cajaId'] = cajaId;
    if (operadorId != null) queryParameters['operadorId'] = operadorId;

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteVentas),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      // Combinar data y pagination para el fromJson
      final combinedData = {
        ...data,
        'pagination': pagination,
      };

      return VentasReporteResponseDto.fromJson(combinedData);
    } else {
      throw Exception('Error al obtener reporte de ventas - Status: ${response.statusCode}');
    }
  }

  @override
  Future<InventarioReporteResponseDto> getReporteInventarioConsumido({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? tipoMovimiento,
    int? productoId,
    int? insumoId,
    required int pageSize,
    required int pageNumber,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'startDate': startDate,
      'endDate': endDate,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    if (tipoMovimiento != null) queryParameters['tipoMovimiento'] = tipoMovimiento;
    if (productoId != null) queryParameters['productoId'] = productoId;
    if (insumoId != null) queryParameters['insumoId'] = insumoId;

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteInventarioConsumido),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>?;
      final pagination = response.data['pagination'] as Map<String, dynamic>?;

      if (data == null) {
        throw Exception('Error: data es null en la respuesta del reporte de inventario');
      }

      if (pagination == null) {
        throw Exception('Error: pagination es null en la respuesta del reporte de inventario');
      }

      final combinedData = {
        ...data,
        'pagination': pagination,
      };

      return InventarioReporteResponseDto.fromJson(combinedData);
    } else {
      throw Exception('Error al obtener reporte de inventario - Status: ${response.statusCode}');
    }
  }

  @override
  Future<ArqueoReporteResponseDto> getReporteArqueoCaja({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? tipoPago,
    int? cajaId,
    required int pageSize,
    required int pageNumber,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'startDate': startDate,
      'endDate': endDate,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    if (tipoPago != null) queryParameters['tipoPago'] = tipoPago;
    if (cajaId != null) queryParameters['cajaId'] = cajaId;

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteArqueoCaja),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      final combinedData = {
        ...data,
        'pagination': pagination,
      };

      return ArqueoReporteResponseDto.fromJson(combinedData);
    } else {
      throw Exception('Error al obtener reporte de arqueo - Status: ${response.statusCode}');
    }
  }

  @override
  Future<StockProductosReporteResponseDto> getReporteStockProductos({
    required int clienteId,
    String? nombreProducto,
    int? tipoProductoId,
    String? activo,
    String? stockBajo,
    required int pageSize,
    required int pageNumber,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    if (nombreProducto != null) queryParameters['nombreProducto'] = nombreProducto;
    if (tipoProductoId != null) queryParameters['tipoProductoId'] = tipoProductoId;
    if (activo != null) queryParameters['activo'] = activo;
    if (stockBajo != null) queryParameters['stockBajo'] = stockBajo;

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteStockProductos),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      final combinedData = {
        ...data,
        'pagination': pagination,
      };

      return StockProductosReporteResponseDto.fromJson(combinedData);
    } else {
      throw Exception('Error al obtener reporte de stock productos - Status: ${response.statusCode}');
    }
  }

  @override
  Future<StockInsumosReporteResponseDto> getReporteStockInsumos({
    required int clienteId,
    String? nombreInsumo,
    String? activo,
    String? stockBajo,
    required int pageSize,
    required int pageNumber,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    if (nombreInsumo != null) queryParameters['nombreInsumo'] = nombreInsumo;
    if (activo != null) queryParameters['activo'] = activo;
    if (stockBajo != null) queryParameters['stockBajo'] = stockBajo;

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteStockInsumos),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>?;
      final pagination = response.data['pagination'] as Map<String, dynamic>?;

      if (data == null) {
        throw Exception('Error: data es null en la respuesta del reporte de stock insumos');
      }

      if (pagination == null) {
        throw Exception('Error: pagination es null en la respuesta del reporte de stock insumos');
      }

      final combinedData = {
        ...data,
        'pagination': pagination,
      };

      return StockInsumosReporteResponseDto.fromJson(combinedData);
    } else {
      throw Exception('Error al obtener reporte de stock insumos - Status: ${response.statusCode}');
    }
  }

  @override
  Future<CostoBeneficioReporteResponseDto> getReporteCostoBeneficio({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    int? tipoProductoId,
    String? activo,
    required int pageSize,
    required int pageNumber,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'startDate': startDate,
      'endDate': endDate,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    if (productoId != null) queryParameters['productoId'] = productoId;
    if (tipoProductoId != null) queryParameters['tipoProductoId'] = tipoProductoId;
    if (activo != null) queryParameters['activo'] = activo;

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteCostoBeneficio),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      final combinedData = {
        ...data,
        'pagination': pagination,
      };

      return CostoBeneficioReporteResponseDto.fromJson(combinedData);
    } else {
      throw Exception('Error al obtener reporte de costo-beneficio - Status: ${response.statusCode}');
    }
  }

  @override
  Future<ProductosResponseDto> searchProductos({
    required int clienteId,
    required String search,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
      'search': search,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.products),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      final combinedData = {
        ...data,
        'pagination': pagination,
      };

      return ProductosResponseDto.fromJson(combinedData);
    } else {
      throw Exception('Error al buscar productos - Status: ${response.statusCode}');
    }
  }

  @override
  Future<ConsumidoresResponseDto> searchConsumidores({
    required int clienteId,
    required String search,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'search': search,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.consumidores),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return ConsumidoresResponseDto.fromJson(response.data);
    } else {
      throw Exception('Error al buscar consumidores - Status: ${response.statusCode}');
    }
  }

  @override
  Future<TiposProductoResponseDto> getTiposProducto({
    required int clienteId,
    bool activo = true,
    int pageSize = 100,
    int pageNumber = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'activo': activo,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.tiposProducto),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return TiposProductoResponseDto.fromJson(response.data);
    } else {
      throw Exception('Error al obtener tipos de producto - Status: ${response.statusCode}');
    }
  }

  @override
  Future<CajasResponseDto> getCajas({
    required int clienteId,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.cajas),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return CajasResponseDto.fromJson(response.data);
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
      return UsuarioDto.fromJson(response.data['data']);
    } else {
      throw Exception('Error al obtener usuario - Status: ${response.statusCode}');
    }
  }

  @override
  Future<OperadoresResponseDto> getOperadores({
    required int clienteId,
    int pageSize = 100,
    int pageNumber = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.operadores),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return OperadoresResponseDto.fromJson(response.data);
    } else {
      throw Exception('Error al obtener operadores - Status: ${response.statusCode}');
    }
  }

  @override
  Future<InsumosResponseDto> searchInsumos({
    required int clienteId,
    required String nombre,
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'nombre': nombre,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.insumos),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return InsumosResponseDto.fromJson(response.data);
    } else {
      throw Exception('Error al buscar insumos - Status: ${response.statusCode}');
    }
  }
}
