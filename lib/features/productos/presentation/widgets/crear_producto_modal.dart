import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/productos_provider.dart';
import '../../../categorias/presentation/providers/categorias_provider.dart';
import '../../../ivas/presentation/providers/ivas_provider.dart';

class CrearProductoModal extends ConsumerStatefulWidget {
  const CrearProductoModal({super.key});

  @override
  ConsumerState<CrearProductoModal> createState() => _CrearProductoModalState();
}

class _CrearProductoModalState extends ConsumerState<CrearProductoModal> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codExternoController = TextEditingController();
  final _codBarrasController = TextEditingController();
  final _precioController = TextEditingController(text: '0');
  final _stockTotalController = TextEditingController(text: '0');
  final _stockMinimoController = TextEditingController(text: '0');

  int? _tipoProductoIdSeleccionado;
  String _unidadMedidaSeleccionada = 'UNIDAD';
  int? _ivaIdSeleccionado;
  bool _manejaStock = true;
  bool _usaReceta = false;
  bool _isLoading = false;

  File? _imagenSeleccionada;
  String? _imagenBase64;
  String? _imagenTipo;

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> _unidadesMedida = [
    {'label': 'Unidad', 'value': 'UNIDAD'},
    {'label': 'Kilogramo', 'value': 'KILOGRAMO'},
    {'label': 'Litro', 'value': 'LITRO'},
    {'label': 'Metro', 'value': 'METRO'},
    {'label': 'Caja', 'value': 'CAJA'},
    {'label': 'Par', 'value': 'PAR'},
    {'label': 'Paquete', 'value': 'PAQUETE'},
    {'label': 'Otro', 'value': 'OTRO'},
  ];

  @override
  void initState() {
    super.initState();
    // Cargar categorías e IVAs si no están cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriasState = ref.read(categoriasProvider);
      if (categoriasState.categoriasResponse == null) {
        ref.read(categoriasProvider.notifier).loadCategorias();
      }

      final ivasState = ref.read(ivasProvider);
      if (ivasState.ivasResponse == null) {
        ref.read(ivasProvider.notifier).loadIvas();
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codExternoController.dispose();
    _codBarrasController.dispose();
    _precioController.dispose();
    _stockTotalController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (imagen != null) {
        final bytes = await imagen.readAsBytes();
        final base64String = base64Encode(bytes);

        // Detectar tipo MIME
        String mimeType = 'image/jpeg';
        if (imagen.path.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (imagen.path.toLowerCase().endsWith('.jpg') ||
                   imagen.path.toLowerCase().endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        }

        setState(() {
          _imagenSeleccionada = File(imagen.path);
          _imagenBase64 = base64String;
          _imagenTipo = mimeType;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: const Color(0xFFdc3545),
          ),
        );
      }
    }
  }

  Future<void> _crearProducto() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tipoProductoIdSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una categoría'),
          backgroundColor: Color(0xFFdc3545),
        ),
      );
      return;
    }

    if (_ivaIdSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un IVA'),
          backgroundColor: Color(0xFFdc3545),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await ref.read(productosListProvider.notifier).createProducto(
      tipoProductoId: _tipoProductoIdSeleccionado!,
      nombre: _nombreController.text.trim(),
      codExterno: _codExternoController.text.trim(),
      codBarras: _codBarrasController.text.trim(),
      precio: double.parse(_precioController.text),
      unidadMedida: _unidadMedidaSeleccionada,
      stockTotal: int.parse(_stockTotalController.text),
      stockMinimo: int.parse(_stockMinimoController.text),
      manejaStock: _manejaStock,
      usaReceta: _usaReceta,
      ivaId: _ivaIdSeleccionado!,
      imagenBase64: _imagenBase64,
      imagenTipo: _imagenTipo,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (error == null) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto creado exitosamente'),
            backgroundColor: Color(0xFF198754),
          ),
        );
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
    final categoriasState = ref.watch(categoriasProvider);
    final categorias = categoriasState.categoriasResponse?.categorias ?? [];

    final ivasState = ref.watch(ivasProvider);
    final ivas = ivasState.ivasResponse?.ivas.where((iva) => iva.activo).toList() ?? [];

    return Dialog(
      backgroundColor: const Color(0xFF1a1a1a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: 700.h),
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
                      'Crear Nuevo Producto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Selector de imagen
                Center(
                  child: GestureDetector(
                    onTap: _seleccionarImagen,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2d2d2d),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: _imagenSeleccionada != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.file(
                                _imagenSeleccionada!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40.sp,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Agregar imagen',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Nombre
                _buildTextField(
                  label: 'Nombre *',
                  controller: _nombreController,
                  hint: 'Ej: Hamburguesa',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Categoría
                Text(
                  'Categoría *',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<int>(
                  value: _tipoProductoIdSeleccionado,
                  dropdownColor: const Color(0xFF2d2d2d),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: _inputDecoration('Seleccione categoría'),
                  items: categorias.map((categoria) {
                    return DropdownMenuItem<int>(
                      value: categoria.tipoProductoId,
                      child: Text(
                        categoria.nombre,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _tipoProductoIdSeleccionado = value);
                  },
                ),
                SizedBox(height: 16.h),

                // Código Externo y Código de Barras
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Código Externo *',
                        controller: _codExternoController,
                        hint: 'EXT-001',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField(
                        label: 'Código Barras *',
                        controller: _codBarrasController,
                        hint: '123456789',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Precio
                _buildTextField(
                  label: 'Precio *',
                  controller: _precioController,
                  hint: '0.00',
                  prefixText: '\$ ',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El precio es requerido';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num < 0) {
                      return 'Debe ser un número válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Unidad de Medida
                Text(
                  'Unidad de Medida *',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _unidadMedidaSeleccionada,
                  dropdownColor: const Color(0xFF2d2d2d),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: _inputDecoration('Seleccione unidad'),
                  items: _unidadesMedida.map((unidad) {
                    return DropdownMenuItem<String>(
                      value: unidad['value'],
                      child: Text(
                        unidad['label']!,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _unidadMedidaSeleccionada = value);
                    }
                  },
                ),
                SizedBox(height: 16.h),

                // Stock Total y Stock Mínimo
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Stock Total *',
                        controller: _stockTotalController,
                        hint: '0',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          final num = int.tryParse(value);
                          if (num == null || num < 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField(
                        label: 'Stock Mínimo *',
                        controller: _stockMinimoController,
                        hint: '0',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          final num = int.tryParse(value);
                          if (num == null || num < 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // IVA
                Text(
                  'IVA *',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<int>(
                  value: _ivaIdSeleccionado,
                  dropdownColor: const Color(0xFF2d2d2d),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: _inputDecoration('Seleccione IVA'),
                  items: ivas.map((iva) {
                    return DropdownMenuItem<int>(
                      value: iva.ivaId,
                      child: Text(
                        iva.descripcion,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _ivaIdSeleccionado = value);
                    }
                  },
                ),
                SizedBox(height: 16.h),

                // Maneja Stock
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
                          'Maneja Stock',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Switch(
                        value: _manejaStock,
                        activeColor: const Color(0xFF198754),
                        onChanged: (value) {
                          setState(() => _manejaStock = value);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Usa Receta
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
                          'Usa Receta',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Switch(
                        value: _usaReceta,
                        activeColor: const Color(0xFF198754),
                        onChanged: (value) {
                          setState(() => _usaReceta = value);
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
                        onPressed: _isLoading ? null : _crearProducto,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? prefixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
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
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    );
  }
}
