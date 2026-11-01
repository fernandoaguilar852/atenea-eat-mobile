class Proveedor {
  final int proveedorId;
  final int clienteId;
  final String nombre;
  final String razonSocial;
  final String nit;
  final String digitoVerificacion;
  final String tipoPersona;
  final String regimen;
  final String codigoCiiu;
  final String telefono;
  final String email;
  final String direccion;
  final int ciudadId;
  final String codigoPostal;
  final int plazoPagoDias;
  final String contactoPrincipal;
  final bool activo;
  final String createdAt;

  Proveedor({
    required this.proveedorId,
    required this.clienteId,
    required this.nombre,
    required this.razonSocial,
    required this.nit,
    required this.digitoVerificacion,
    required this.tipoPersona,
    required this.regimen,
    required this.codigoCiiu,
    required this.telefono,
    required this.email,
    required this.direccion,
    required this.ciudadId,
    required this.codigoPostal,
    required this.plazoPagoDias,
    required this.contactoPrincipal,
    required this.activo,
    required this.createdAt,
  });
}
