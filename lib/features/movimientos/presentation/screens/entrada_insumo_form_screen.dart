import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../insumos/domain/entities/insumo.dart';
import '../providers/movimientos_provider.dart';

class EntradaInsumoFormScreen extends ConsumerStatefulWidget {
  final Insumo insumo;

  const EntradaInsumoFormScreen({
    super.key,
    required this.insumo,
  });

  @override
  ConsumerState<EntradaInsumoFormScreen> createState() => _EntradaInsumoFormScreenState();
}

class _EntradaInsumoFormScreenState extends ConsumerState<EntradaInsumoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _proveedorIdController = TextEditingController();
  final _costoController = TextEditingController();
  final _impuestoController = TextEditingController();
  final _descuentoController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _observacionController = TextEditingController();
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = DateTime.now();
  }

  @override
  void dispose() {
    _proveedorIdController.dispose();
    _costoController.dispose();
    _impuestoController.dispose();
    _descuentoController.dispose();
    _cantidadController.dispose();
    _observacionController.dispose();
    super.dispose();
  }

  String _formatFechaForApi(DateTime fecha) {
    return DateFormat('yyyy-MM-dd').format(fecha);
  }

  Future<void> _selectFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
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
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _registrarEntrada() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona una fecha'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref.read(registrarMovimientoProvider.notifier).registrarMovimiento(
          insumoId: widget.insumo.insumoId,
          proveedorId: _proveedorIdController.text.isNotEmpty ? int.tryParse(_proveedorIdController.text) : null,
          tipo: 'entrada',
          costo: double.parse(_costoController.text),
          impuesto: double.parse(_impuestoController.text),
          descuentoUnidad: double.parse(_descuentoController.text),
          cantidad: int.parse(_cantidadController.text),
          observacion: _observacionController.text,
          fecha: _formatFechaForApi(_fechaSeleccionada!),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entrada registrada exitosamente'),
          backgroundColor: const Color(0xFF198754),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      final error = ref.read(registrarMovimientoProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error ?? "Desconocido"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrarState = ref.watch(registrarMovimientoProvider);
    final isLoading = registrarState.isLoading;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF198754), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF198754),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.white, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registrar Entrada',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.insumo.nombre,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                    iconSize: 20.sp,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Formulario
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cantidad y Proveedor en fila
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cantidad *', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                SizedBox(height: 6.h),
                                TextFormField(
                                  controller: _cantidadController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                  decoration: InputDecoration(
                                    hintText: 'Cant.',
                                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.sp),
                                    filled: true,
                                    fillColor: const Color(0xFF2a2a2a),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF404040))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF198754))),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                    isDense: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Requerido';
                                    if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Inválido';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Proveedor', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                SizedBox(height: 6.h),
                                TextFormField(
                                  controller: _proveedorIdController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                  decoration: InputDecoration(
                                    hintText: 'ID',
                                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.sp),
                                    filled: true,
                                    fillColor: const Color(0xFF2a2a2a),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF404040))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF198754))),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                    isDense: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Costo e Impuesto en fila
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Costo *', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                SizedBox(height: 6.h),
                                TextFormField(
                                  controller: _costoController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.sp),
                                    filled: true,
                                    fillColor: const Color(0xFF2a2a2a),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF404040))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF198754))),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                    isDense: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Requerido';
                                    if (double.tryParse(value) == null || double.parse(value) < 0) return 'Inválido';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Impuesto *', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                SizedBox(height: 6.h),
                                TextFormField(
                                  controller: _impuestoController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.sp),
                                    filled: true,
                                    fillColor: const Color(0xFF2a2a2a),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF404040))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF198754))),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                    isDense: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Requerido';
                                    if (double.tryParse(value) == null || double.parse(value) < 0) return 'Inválido';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Descuento
                      Text('Descuento *', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _descuentoController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.sp),
                          filled: true,
                          fillColor: const Color(0xFF2a2a2a),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF404040))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF198754))),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Requerido';
                          if (double.tryParse(value) == null || double.parse(value) < 0) return 'Inválido';
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),

                      // Fecha
                      Text('Fecha *', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 6.h),
                      InkWell(
                        onTap: _selectFecha,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2a2a2a),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: const Color(0xFF404040)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _fechaSeleccionada != null ? DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!) : 'Seleccionar',
                                style: TextStyle(color: _fechaSeleccionada != null ? Colors.white : Colors.white.withValues(alpha: 0.4), fontSize: 13.sp),
                              ),
                              Icon(Icons.calendar_today, color: const Color(0xFF198754), size: 16.sp),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Observación
                      Text('Observación *', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 6.h),
                      TextFormField(
                        controller: _observacionController,
                        maxLines: 2,
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                        decoration: InputDecoration(
                          hintText: 'Descripción',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.sp),
                          filled: true,
                          fillColor: const Color(0xFF2a2a2a),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF404040))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: const Color(0xFF198754))),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          isDense: true,
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                      SizedBox(height: 16.h),

                      // Botón
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _registrarEntrada,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF198754),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: isLoading
                              ? SizedBox(height: 18.h, width: 18.w, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('Registrar Entrada', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
