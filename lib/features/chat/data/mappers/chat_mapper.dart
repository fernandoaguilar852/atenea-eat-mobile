import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../models/chat_query_response_dto.dart';

class ChatMapper {
  static const _uuid = Uuid();

  /// Convierte la respuesta del API a un ChatMessage del asistente
  static ChatMessage fromDto(ChatQueryResponseDto dto) {
    return ChatMessage.fromAssistant(
      id: _uuid.v4(),
      answer: dto.data.answer,
      data: dto.data.data,
      querySource: dto.data.querySource,
      explanation: dto.data.explanation,
      templateUsed: dto.data.templateUsed,
    );
  }
}
