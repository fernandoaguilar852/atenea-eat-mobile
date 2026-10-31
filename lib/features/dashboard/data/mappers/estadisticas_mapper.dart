import '../../domain/entities/estadisticas.dart';
import '../models/estadisticas_response_dto.dart';

class EstadisticasMapper {
  static Estadisticas fromDto(EstadisticasResponseDto dto) {
    return Estadisticas(
      ventasDia: dto.data.ventasDia,
      cantidadFacturas: dto.data.cantidadFacturas,
      totalIngresos: dto.data.totalIngresos.toDouble(),
      cantidadAlertas: dto.data.cantidadAlertas,
      totalReservas: dto.data.totalReservas,
      totalReservasConfirmadas: dto.data.totalReservasConfirmadas,
      totalOrdenesAbiertas: dto.data.totalOrdenesAbiertas,
      totalOrdenesEnProceso: dto.data.totalOrdenesEnProceso,
      totalOrdenesCerradas: dto.data.totalOrdenesCerradas,
      totalMesas: dto.data.totalMesas,
      totalMesasOcupadas: dto.data.totalMesasOcupadas,
      totalMesasLibres: dto.data.totalMesasLibres,
      totalComandasPendientes: dto.data.totalComandasPendientes,
      totalComandasEnPreparacion: dto.data.totalComandasEnPreparacion,
      totalComandasListas: dto.data.totalComandasListas,
    );
  }
}
