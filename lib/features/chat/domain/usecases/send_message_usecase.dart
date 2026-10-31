import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  /// Envía un mensaje al chat IA
  ///
  /// [message] El mensaje del usuario
  /// Retorna un ChatMessage con la respuesta del asistente
  Future<ChatMessage> call({required String message}) async {
    if (message.trim().isEmpty) {
      throw Exception('El mensaje no puede estar vacío');
    }

    return await _repository.sendMessage(message: message.trim());
  }
}
