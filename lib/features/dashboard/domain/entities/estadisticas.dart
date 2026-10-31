import 'package:equatable/equatable.dart';

class Estadisticas extends Equatable {
  final int ventasDia;
  final int cantidadFacturas;
  final double totalIngresos;
  final int cantidadAlertas;
  final int totalReservas;
  final int totalReservasConfirmadas;
  final int totalOrdenesAbiertas;
  final int totalOrdenesEnProceso;
  final int totalOrdenesCerradas;
  final int totalMesas;
  final int totalMesasOcupadas;
  final int totalMesasLibres;
  final int totalComandasPendientes;
  final int totalComandasEnPreparacion;
  final int totalComandasListas;

  const Estadisticas({
    required this.ventasDia,
    required this.cantidadFacturas,
    required this.totalIngresos,
    required this.cantidadAlertas,
    required this.totalReservas,
    required this.totalReservasConfirmadas,
    required this.totalOrdenesAbiertas,
    required this.totalOrdenesEnProceso,
    required this.totalOrdenesCerradas,
    required this.totalMesas,
    required this.totalMesasOcupadas,
    required this.totalMesasLibres,
    required this.totalComandasPendientes,
    required this.totalComandasEnPreparacion,
    required this.totalComandasListas,
  });

  @override
  List<Object?> get props => [
        ventasDia,
        cantidadFacturas,
        totalIngresos,
        cantidadAlertas,
        totalReservas,
        totalReservasConfirmadas,
        totalOrdenesAbiertas,
        totalOrdenesEnProceso,
        totalOrdenesCerradas,
        totalMesas,
        totalMesasOcupadas,
        totalMesasLibres,
        totalComandasPendientes,
        totalComandasEnPreparacion,
        totalComandasListas,
      ];

  // Getters útiles para la UI
  double get porcentajeMesasOcupadas {
    if (totalMesas == 0) return 0;
    return (totalMesasOcupadas / totalMesas) * 100;
  }

  int get totalComandas {
    return totalComandasPendientes +
        totalComandasEnPreparacion +
        totalComandasListas;
  }

  int get totalOrdenes {
    return totalOrdenesAbiertas +
        totalOrdenesEnProceso +
        totalOrdenesCerradas;
  }

  bool get hayAlertas => cantidadAlertas > 0;
}
