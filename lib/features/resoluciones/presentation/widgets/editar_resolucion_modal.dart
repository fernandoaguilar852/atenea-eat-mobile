import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/resolucion.dart';
import '../providers/resoluciones_provider.dart';

class EditarResolucionModal extends ConsumerStatefulWidget {
  final Resolucion resolucion;

  const EditarResolucionModal({
    super.key,
    required this.resolucion,
  });

  @override
  ConsumerState<EditarResolucionModal> createState() => _EditarResolucionModalState();
}

class _EditarResolucionModalState extends ConsumerState<EditarResolucionModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _prefijoController;
  late final TextEditingController _numeroHastaController;
  late final TextEditingController _numeroActualController;

  late DateTime _fechaVencimiento;
  late bool _activo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Prellenar los campos con los datos actuales
    _prefijoController = TextEditingController(text: widget.resolucion.prefijo);
    _numeroHastaController = TextEditingController(text: widget.resolucion.numeroHasta.toString());
    _numeroActualController = TextEditingController(text: widget.resolucion.numeroActual.toString());
    _fechaVencimiento = DateTime.parse(widget.resolucion.fechaVencimiento);
    _activo = widget.resolucion.activo;
  }

  @override
  void dispose() {
    _prefijoController.dispose();
    _numeroHastaController.dispose();
    _numeroActualController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectFechaVencimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento,
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

  Future<void> _actualizarResolucion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que numeroActual no sea mayor que numeroHasta
    final numeroActual = int.parse(_numeroActualController.text);
    final numeroHasta = int.parse(_numeroHastaController.text);

    if (numeroActual > numeroHasta) {
      _showErrorDialog('El número actual no puede ser mayor que el número hasta');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final error = await ref.read(resolucionesProvider.notifier).updateResolucion(
      resolucionId: widget.resolucion.resolucionId,
      prefijo: _prefijoController.text.trim(),
      numeroHasta: numeroHasta,
      numeroActual: numeroActual,
      fechaVencimiento: _formatDate(_fechaVencimiento),
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
                      Icons.edit,
                      color: const Color(0xFF0d6efd),
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Editar Resolución',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Campos NO editables (solo lectura)
                Text(
                  'Datos fijos (no editables)',
                  style: TextStyle(
                    color: const Color(0xFF808080),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),

                // Número Desde (readonly)
                _buildReadOnlyField(
                  label: 'Número Desde',
                  value: widget.resolucion.numeroDesde.toString(),
                ),
                SizedBox(height: 12.h),

                // Número Resolución (readonly)
                _buildReadOnlyField(
                  label: 'Número Resolución',
                  value: widget.resolucion.numeroResolucion,
                ),
                SizedBox(height: 12.h),

                // Fecha Resolución (readonly)
                _buildReadOnlyField(
                  label: 'Fecha Resolución',
                  value: _formatDate(DateTime.parse(widget.resolucion.fechaResolucion)),
                ),
                SizedBox(height: 24.h),

                // Campos EDITABLES
                Text(
                  'Datos editables',
                  style: TextStyle(
                    color: const Color(0xFF0d6efd),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),

                // Prefijo
                TextFormField(
                  controller: _prefijoController,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Prefijo *',
                    labelStyle: TextStyle(color: const Color(0xFF808080), fontSize: 14.sp),
                    filled: true,
                    fillColor: const Color(0xFF0a0a0a),
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
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el prefijo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),

                // Número Hasta
                TextFormField(
                  controller: _numeroHastaController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Número Hasta *',
                    labelStyle: TextStyle(color: const Color(0xFF808080), fontSize: 14.sp),
                    filled: true,
                    fillColor: const Color(0xFF0a0a0a),
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
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el número hasta';
                    }
                    final numero = int.tryParse(value);
                    if (numero == null || numero <= 0) {
                      return 'Debe ser un número válido mayor a 0';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),

                // Número Actual
                TextFormField(
                  controller: _numeroActualController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Número Actual *',
                    labelStyle: TextStyle(color: const Color(0xFF808080), fontSize: 14.sp),
                    filled: true,
                    fillColor: const Color(0xFF0a0a0a),
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
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el número actual';
                    }
                    final numero = int.tryParse(value);
                    if (numero == null || numero < 0) {
                      return 'Debe ser un número válido mayor o igual a 0';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),

                // Fecha Vencimiento
                InkWell(
                  onTap: _selectFechaVencimiento,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0a0a0a),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFF404040)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha Vencimiento *',
                              style: TextStyle(
                                color: const Color(0xFF808080),
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _formatDate(_fechaVencimiento),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: const Color(0xFF0d6efd),
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Switch Activo
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0a0a0a),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFF404040)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estado Activo',
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
                        activeColor: const Color(0xFF0d6efd),
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
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: const BorderSide(color: Color(0xFF6c757d)),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: const Color(0xFF6c757d),
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _actualizarResolucion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0d6efd),
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
                                'Guardar Cambios',
                                style: TextStyle(fontSize: 16.sp),
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

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0a0a).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFF404040).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF808080),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
