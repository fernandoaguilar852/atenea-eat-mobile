import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../core/utils/single_decimal_input_formatter.dart';
import '../providers/productos_provider.dart';
import '../../../categorias/presentation/providers/categorias_provider.dart';
import '../../../ivas/presentation/providers/ivas_provider.dart';
import '../../domain/entities/producto.dart';

class EditarProductoModal extends ConsumerStatefulWidget {
  final Producto producto;

  const EditarProductoModal({
    super.key,
    required this.producto,
  });

  @override
  ConsumerState<EditarProductoModal> createState() => _EditarProductoModalState();
}

class _EditarProductoModalState extends ConsumerState<EditarProductoModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _codExternoController;
  late TextEditingController _codBarrasController;
  late TextEditingController _precioController;
  late TextEditingController _stockTotalController;
  late TextEditingController _stockMinimoController;

  late int _tipoProductoIdSeleccionado;
  late String _unidadMedidaSeleccionada;
  late int? _ivaIdSeleccionado;
  late bool _manejaStock;
  late bool _usaReceta;
  late bool _activo;
  bool _isLoading = false;
  bool _isCompressing = false;

  File? _imagenSeleccionada;
  String? _imagenBase64;
  String? _imagenTipo;
  bool _cambioImagen = false;

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
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _codExternoController = TextEditingController(text: widget.producto.codExterno);
    _codBarrasController = TextEditingController(text: widget.producto.codBarras);
    _precioController = TextEditingController(text: widget.producto.precio.toString());
    _stockTotalController = TextEditingController(text: formatDecimal(widget.producto.stockTotal));
    _stockMinimoController = TextEditingController(text: formatDecimal(widget.producto.stockMinimo));
    _tipoProductoIdSeleccionado = widget.producto.tipoProductoId;
    _unidadMedidaSeleccionada = widget.producto.unidadMedida;
    _ivaIdSeleccionado = widget.producto.ivaId;
    _manejaStock = widget.producto.manejaStock;
    _usaReceta = widget.producto.usaReceta;
    _activo = widget.producto.activo;

    // Cargar categorías e IVAs y seleccionar el primero
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final categoriasState = ref.read(categoriasProvider);
      if (categoriasState.categoriasResponse == null) {
        ref.read(categoriasProvider.notifier).loadCategorias();
      }

      final ivasState = ref.read(ivasProvider);
      if (ivasState.ivasResponse == null) {
        await ref.read(ivasProvider.notifier).loadIvas();
      }

      // Seleccionar el primer IVA de la lista si no hay uno seleccionado
      if (_ivaIdSeleccionado == null) {
        final ivasStateUpdated = ref.read(ivasProvider);
        if (ivasStateUpdated.ivasResponse != null) {
          final ivasActivos = ivasStateUpdated.ivasResponse!.ivas.where((iva) => iva.activo).toList();
          if (ivasActivos.isNotEmpty && mounted) {
            setState(() {
              _ivaIdSeleccionado = ivasActivos.first.ivaId;
            });
          }
        }
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
      // Seleccionar imagen de la galería
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (imagen == null) return;

      // Mostrar imagen inmediatamente (UI Optimista)
      if (mounted) {
        setState(() {
          _imagenSeleccionada = File(imagen.path);
          _isCompressing = true;
        });
      }

      // Comprimir imagen AGRESIVAMENTE para garantizar tamaño pequeño
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imagen.path,
        minWidth: 400,   // MÁS pequeño para garantizar velocidad
        minHeight: 400,
        quality: 40,     // Compresión muy agresiva
        format: CompressFormat.jpeg,  // JPEG es más compatible que WebP
      );

      if (compressedBytes == null) {
        throw Exception('Error al comprimir imagen');
      }

      // Validar que no sea muy grande (máximo 150 KB)
      if (compressedBytes.length > 150 * 1024) {
        if (mounted) {
          setState(() => _isCompressing = false);
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1a1a1a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: const Color(0xFFffc107),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Imagen muy grande',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                'La imagen comprimida pesa ${(compressedBytes.length / 1024).toStringAsFixed(0)} KB. Por favor selecciona una imagen más pequeña o toma una foto nueva.',
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
                  ),
                  child: Text(
                    'Entendido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return;
      }

      final base64String = base64Encode(compressedBytes);

      if (mounted) {
        setState(() {
          _imagenBase64 = base64String;
          _imagenTipo = 'image/jpeg';
          _cambioImagen = true;
          _isCompressing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCompressing = false);
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1a1a1a),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: const Color(0xFFdc3545),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Error al procesar imagen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
            content: Text(
              'Ocurrió un error al procesar la imagen. Por favor intenta con otra imagen.\n\nDetalle: ${e.toString()}',
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
                ),
                child: Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _actualizarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    final error = await ref.read(productosListProvider.notifier).updateProducto(
      productoId: widget.producto.productoId,
      tipoProductoId: _tipoProductoIdSeleccionado,
      nombre: _nombreController.text.trim(),
      codExterno: _codExternoController.text.trim(),
      codBarras: _codBarrasController.text.trim(),
      precio: double.parse(_precioController.text),
      unidadMedida: _unidadMedidaSeleccionada,
      stockTotal: parseDecimal(_stockTotalController.text)!,
      stockMinimo: parseDecimal(_stockMinimoController.text)!,
      manejaStock: _manejaStock,
      usaReceta: _usaReceta,
      activo: _activo,
      imagenBase64: _cambioImagen ? _imagenBase64 : null,
      imagenTipo: _cambioImagen ? _imagenTipo : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (mounted) {
      if (error == null) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto actualizado exitosamente'),
            backgroundColor: Color(0xFF198754),
          ),
        );
      } else {
        // Mostrar diálogo con el error completo
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1a1a1a),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: const Color(0xFFdc3545),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Error al actualizar producto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                error,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14.sp,
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d6efd),
                ),
                child: Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
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
                      Icons.edit,
                      color: const Color(0xFF0d6efd),
                      size: 28.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Editar Producto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Selector de imagen
                Center(
                  child: GestureDetector(
                    onTap: _isCompressing ? null : _seleccionarImagen,
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
                      child: Stack(
                        children: [
                          if (_imagenSeleccionada != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.file(
                                _imagenSeleccionada!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          else if (widget.producto.imagen != null && widget.producto.imagen!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: CachedNetworkImage(
                                imageUrl: widget.producto.imagen!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0d6efd),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 40.sp,
                                      color: Colors.white.withValues(alpha: 0.5),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Cambiar imagen',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Column(
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
                          // Indicador de compresión
                          if (_isCompressing)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(
                                      color: Color(0xFF0d6efd),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Optimizando...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_cambioImagen && !_isCompressing)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Center(
                      child: Text(
                        'Nueva imagen seleccionada',
                        style: TextStyle(
                          color: const Color(0xFF198754),
                          fontSize: 12.sp,
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
                    if (value != null) {
                      setState(() => _tipoProductoIdSeleccionado = value);
                    }
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          SingleDecimalInputFormatter(),
                        ],
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
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField(
                        label: 'Stock Mínimo *',
                        controller: _stockMinimoController,
                        hint: '0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          SingleDecimalInputFormatter(),
                        ],
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
                          setState(() {
                            _manejaStock = value;
                            // Si se activa maneja stock, desactivar usa receta
                            if (value == true) {
                              _usaReceta = false;
                            }
                          });
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
                          setState(() {
                            _usaReceta = value;
                            // Si se activa usa receta, desactivar maneja stock
                            if (value == true) {
                              _manejaStock = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

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
                          'Producto Activo',
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
                        onPressed: _isLoading ? null : _actualizarProducto,
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
                                'Actualizar',
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
