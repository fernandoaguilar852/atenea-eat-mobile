import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/alerta.dart';

class AlertaCard extends StatelessWidget {
  final Alerta alerta;

  const AlertaCard({
    super.key,
    required this.alerta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: _getColorByPercentage(alerta.porcentajeStock),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  alerta.nombre,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInfoRow('Stock Actual', '${alerta.stockActual}'),
          _buildInfoRow('Stock Mínimo', '${alerta.stockMinimo}'),
          _buildInfoRow(
            'Porcentaje',
            '${alerta.porcentajeStock}%',
            valueColor: _getColorByPercentage(alerta.porcentajeStock),
          ),
          _buildInfoRow('Días en Alerta', '${alerta.diasEnAlerta}'),
          _buildInfoRow(
            'Fecha Alerta',
            _formatDate(alerta.fechaAlerta),
          ),
          if (!alerta.activa)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF198754).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Resuelta',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF198754),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getColorByPercentage(int percentage) {
    if (percentage <= 25) return const Color(0xFFdc3545); // Rojo
    if (percentage <= 50) return const Color(0xFFffc107); // Amarillo/Naranja
    return const Color(0xFFffc107); // Amarillo
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
