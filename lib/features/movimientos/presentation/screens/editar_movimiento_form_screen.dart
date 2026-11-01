import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/movimiento_detalle.dart';
import '../../../proveedores/domain/entities/proveedor.dart';
import '../../../proveedores/presentation/widgets/proveedor_selector.dart';

class EditarMovimientoFormScreen extends ConsumerStatefulWidget {
  final MovimientoDetalle detalle;

  const EditarMovimientoFormScreen({
    super.key,
    required this.detalle,
  });

  @override
  ConsumerState<EditarMovimientoFormScreen> createState() => _EditarMovimientoFormScreenState();
}

class _EditarMovimientoFormScreenState extends ConsumerState<EditarMovimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _costoController;
  late final TextEditingController _impuestoController;
  late final TextEditingController _descuentoController;
  late final TextEditingController _cantidadController;
  late final TextEditingController _observacionController;
  DateTime? _fechaSeleccionada;
  Proveedor? _proveedorSeleccionado;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los valores del detalle
    _costoController = TextEditingController(text: widget.detalle.costo.toString());
    _impuestoController = TextEditingController(text: widget.detalle.impuesto.toString());
    _descuentoController = TextEditingController(text: widget.detalle.descuentoUnidad.toString());
    _cantidadController = TextEditingController(text: widget.detalle.cantidad.toString());
    _observacionController = TextEditingController(text: widget.detalle.observacion);
    _fechaSeleccionada = DateTime.parse(widget.detalle.fecha);
    // TODO: Cargar proveedor seleccionado si existe proveedorId

    // Mostrar alerta informativa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarAlertaInformativa();
    });
  }

  void _mostrarAlertaInformativa() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: const Color(0xFF0d6efd), width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: const Color(0xFF0d6efd), size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Información',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'El tipo de movimiento (${widget.detalle.tipo.toUpperCase()}) no se puede editar. Solo puedes modificar los demás campos.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14.sp,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0d6efd),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              'Entendido',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
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

  Future<void> _selectProveedor() async {
    final proveedor = await showDialog<Proveedor>(
      context: context,
      builder: (context) => const ProveedorSelector(),
    );

    if (proveedor != null) {
      setState(() {
        _proveedorSeleccionado = proveedor;
      });
    }
  }

  Future<void> _actualizarMovimiento() async {
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

    // TODO: Implementar llamada al API de actualización
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Actualización en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );

    // Por ahora solo cerramos el modal
    // Navigator.of(context).pop(true);
  }

  Color get _themeColor {
    if (widget.detalle.tipo == 'entrada') {
      return widget.detalle.productoId != null
          ? const Color(0xFF198754) // Verde para entrada producto
          : const Color(0xFF198754); // Verde para entrada insumo
    } else {
      return const Color(0xFFdc3545); // Rojo para salida
    }
  }

  IconData get _themeIcon {
    if (widget.detalle.tipo == 'entrada') {
      return Icons.add_circle_outline;
    } else {
      return Icons.remove_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _themeColor, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _themeColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(_themeIcon, color: Colors.white, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Editar ${widget.detalle.tipo.toUpperCase()}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.detalle.nombre,
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
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: _themeColor)),
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
                                InkWell(
                                  onTap: _selectProveedor,
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
                                        Expanded(
                                          child: Text(
                                            _proveedorSeleccionado?.nombre ?? (widget.detalle.proveedorId != null ? 'ID: ${widget.detalle.proveedorId}' : 'Seleccionar'),
                                            style: TextStyle(
                                              color: _proveedorSeleccionado != null ? Colors.white : Colors.white.withValues(alpha: 0.4),
                                              fontSize: 13.sp,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down, color: _themeColor, size: 20.sp),
                                      ],
                                    ),
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
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: _themeColor)),
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
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: _themeColor)),
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
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: _themeColor)),
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
                              Icon(Icons.calendar_today, color: _themeColor, size: 16.sp),
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
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r), borderSide: BorderSide(color: _themeColor)),
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
                          onPressed: _actualizarMovimiento,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _themeColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: Text('Actualizar Movimiento', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
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
