import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/single_decimal_input_formatter.dart';
import '../providers/insumos_provider.dart';

class CrearInsumoModal extends ConsumerStatefulWidget {
  const CrearInsumoModal({super.key});

  @override
  ConsumerState<CrearInsumoModal> createState() => _CrearInsumoModalState();
}

class _CrearInsumoModalState extends ConsumerState<CrearInsumoModal> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _stockActualController = TextEditingController(text: '0');
  final _stockMinimoController = TextEditingController(text: '0');
  final _costoPromedioController = TextEditingController(text: '0');

  String _unidadBaseSeleccionada = 'kg';
  bool _activo = true;
  bool _isLoading = false;

  final List<Map<String, String>> _unidadesBase = [
    {'label': 'Gramo', 'value': 'g'},
    {'label': 'Kilogramo', 'value': 'kg'},
    {'label': 'Mililitro', 'value': 'ml'},
    {'label': 'Litro', 'value': 'lt'},
    {'label': 'Unidad', 'value': 'und'},
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _stockActualController.dispose();
    _stockMinimoController.dispose();
    _costoPromedioController.dispose();
    super.dispose();
  }

  Future<void> _crearInsumo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await ref.read(insumosListProvider.notifier).createInsumo(
      nombre: _nombreController.text.trim(),
      unidadBase: _unidadBaseSeleccionada,
      stockActual: parseDecimal(_stockActualController.text)!,
      stockMinimo: parseDecimal(_stockMinimoController.text)!,
      costoPromedio: double.parse(_costoPromedioController.text),
      activo: _activo,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (error == null) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFdc3545),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1a1a1a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: 600.h),
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
                      Icons.add_circle,
                      color: const Color(0xFF0d6efd),
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Crear Nuevo Insumo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Nombre
                Text(
                  'Nombre *',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _nombreController,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Ej: Azúcar',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14.sp,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2d2d2d),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF0d6efd),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(
                        color: Color(0xFFdc3545),
                        width: 1,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Unidad Base
                Text(
                  'Unidad Base *',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _unidadBaseSeleccionada,
                  dropdownColor: const Color(0xFF2d2d2d),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2d2d2d),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF0d6efd),
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  items: _unidadesBase.map((unidad) {
                    return DropdownMenuItem<String>(
                      value: unidad['value'],
                      child: Text(
                        '${unidad['label']} (${unidad['value']})',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _unidadBaseSeleccionada = value);
                    }
                  },
                ),
                SizedBox(height: 16.h),

                // Stock Actual y Stock Mínimo
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock Actual *',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: _stockActualController,
                            style: TextStyle(color: Colors.white, fontSize: 14.sp),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              SingleDecimalInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14.sp,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF2d2d2d),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0d6efd),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFFdc3545),
                                  width: 1,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              final num = parseDecimal(value);
                              if (num == null || num < 0) {
                                return 'Inválido';
                              }
                              return null;
                            },
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
                            'Stock Mínimo *',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: _stockMinimoController,
                            style: TextStyle(color: Colors.white, fontSize: 14.sp),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              SingleDecimalInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14.sp,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF2d2d2d),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0d6efd),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFFdc3545),
                                  width: 1,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              final num = parseDecimal(value);
                              if (num == null || num < 0) {
                                return 'Inválido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Costo Promedio
                Text(
                  'Costo Promedio *',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _costoPromedioController,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14.sp,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2d2d2d),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF0d6efd),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(
                        color: Color(0xFFdc3545),
                        width: 1,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El costo promedio es requerido';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num < 0) {
                      return 'Debe ser un número válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Activo
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2d2d2d),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Estado Activo',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Switch(
                        value: _activo,
                        activeColor: const Color(0xFF198754),
                        onChanged: (value) {
                          setState(() => _activo = value);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: const Color(0xFF6c757d),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _crearInsumo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0d6efd),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Crear',
                                style: TextStyle(fontSize: 14.sp),
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
}
