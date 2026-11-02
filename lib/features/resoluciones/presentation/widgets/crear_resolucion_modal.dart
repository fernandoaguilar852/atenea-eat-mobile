import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/resoluciones_provider.dart';

class CrearResolucionModal extends ConsumerStatefulWidget {
  const CrearResolucionModal({super.key});

  @override
  ConsumerState<CrearResolucionModal> createState() => _CrearResolucionModalState();
}

class _CrearResolucionModalState extends ConsumerState<CrearResolucionModal> {
  final _formKey = GlobalKey<FormState>();
  final _prefijoController = TextEditingController();
  final _numeroDesdeController = TextEditingController();
  final _numeroHastaController = TextEditingController();
  final _numeroActualController = TextEditingController(text: '0');
  final _numeroResolucionController = TextEditingController();

  DateTime? _fechaResolucion;
  DateTime? _fechaVencimiento;
  bool _activo = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _prefijoController.dispose();
    _numeroDesdeController.dispose();
    _numeroHastaController.dispose();
    _numeroActualController.dispose();
    _numeroResolucionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectFechaResolucion() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaResolucion ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0d6efd),
              surface: Color(0xFF1a1a1a),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaResolucion = picked;
      });
    }
  }

  Future<void> _selectFechaVencimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0d6efd),
              surface: Color(0xFF1a1a1a),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaVencimiento = picked;
      });
    }
  }

  Future<void> _guardarResolucion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaResolucion == null || _fechaVencimiento == null) {
      _showErrorDialog('Por favor selecciona ambas fechas');
      return;
    }

    // Validar que fecha vencimiento sea mayor a fecha resolución
    if (_fechaVencimiento!.isBefore(_fechaResolucion!)) {
      _showErrorDialog('La fecha de vencimiento debe ser posterior a la fecha de resolución');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final error = await ref.read(resolucionesProvider.notifier).crearResolucion(
      prefijo: _prefijoController.text.trim(),
      numeroDesde: int.parse(_numeroDesdeController.text),
      numeroHasta: int.parse(_numeroHastaController.text),
      numeroActual: int.parse(_numeroActualController.text),
      numeroResolucion: _numeroResolucionController.text.trim(),
      fechaResolucion: _formatDate(_fechaResolucion!),
      fechaVencimiento: _formatDate(_fechaVencimiento!),
      activo: _activo,
    );

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      // Éxito
      if (mounted) {
        Navigator.of(context).pop(true); // Retornar true para indicar éxito
      }
    } else {
      // Error
      _showErrorDialog(error);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Text(
          'Error',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendido',
              style: TextStyle(
                color: const Color(0xFF0d6efd),
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1a1a1a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.85.sh),
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: const Color(0xFF0d6efd),
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Crear Resolución',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.white70,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Prefijo
                _buildTextField(
                  controller: _prefijoController,
                  label: 'Prefijo',
                  hint: 'Ej: TEST, FAC, etc.',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El prefijo es requerido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Número Resolución
                _buildTextField(
                  controller: _numeroResolucionController,
                  label: 'Número de Resolución',
                  hint: 'Ej: RES-DIAN-2026-001',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El número de resolución es requerido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Rango de numeración
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _numeroDesdeController,
                        label: 'Número Desde',
                        hint: '1',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Número inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField(
                        controller: _numeroHastaController,
                        label: 'Número Hasta',
                        hint: '1000',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          final hasta = int.tryParse(value);
                          if (hasta == null) {
                            return 'Número inválido';
                          }
                          final desde = int.tryParse(_numeroDesdeController.text);
                          if (desde != null && hasta <= desde) {
                            return 'Debe ser mayor';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Número Actual
                _buildTextField(
                  controller: _numeroActualController,
                  label: 'Número Actual',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El número actual es requerido';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Número inválido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Fechas
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha Resolución',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          InkWell(
                            onTap: _selectFechaResolucion,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2a2a2a),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFF404040),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _fechaResolucion != null
                                        ? _formatDate(_fechaResolucion!)
                                        : 'Seleccionar',
                                    style: TextStyle(
                                      color: _fechaResolucion != null
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: const Color(0xFF0d6efd),
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha Vencimiento',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          InkWell(
                            onTap: _selectFechaVencimiento,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2a2a2a),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFF404040),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _fechaVencimiento != null
                                        ? _formatDate(_fechaVencimiento!)
                                        : 'Seleccionar',
                                    style: TextStyle(
                                      color: _fechaVencimiento != null
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: const Color(0xFF0d6efd),
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Switch Activo
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF404040),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resolución Activa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                      Switch(
                        value: _activo,
                        onChanged: (value) {
                          setState(() {
                            _activo = value;
                          });
                        },
                        activeColor: const Color(0xFF198754),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Color(0xFF6c757d)),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _guardarResolucion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF198754),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Guardar',
                                style: TextStyle(fontSize: 15.sp),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: const Color(0xFF2a2a2a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF404040)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF404040)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF0d6efd)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFdc3545)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFdc3545)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          ),
        ),
      ],
    );
  }
}
