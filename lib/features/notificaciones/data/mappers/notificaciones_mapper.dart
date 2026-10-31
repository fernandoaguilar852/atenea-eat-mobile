import '../../domain/entities/notificacion.dart';
import '../../domain/entities/pagination.dart';
import '../models/notificaciones_response_dto.dart';

class NotificacionesMapper {
  static Notificacion fromDto(NotificacionDto dto) {
    return Notificacion(
      notificacionId: dto.notificacionId,
      clienteId: dto.clienteId,
      tipo: dto.tipo,
      titulo: dto.titulo,
      mensaje: dto.mensaje,
      prioridad: dto.prioridad,
      estado: dto.estado,
      resolucionId: dto.resolucionId,
      metadata: dto.metadata,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
      leidaAt: dto.leidaAt != null ? DateTime.parse(dto.leidaAt!) : null,
      archivadaAt: dto.archivadaAt != null ? DateTime.parse(dto.archivadaAt!) : null,
    );
  }

  static Pagination paginationFromDto(PaginationDto dto) {
    return Pagination(
      totalElement: dto.totalElement,
      pageSize: dto.pageSize,
      pageNumber: dto.pageNumber,
      hasMoreElements: dto.hasMoreElements,
    );
  }
}
