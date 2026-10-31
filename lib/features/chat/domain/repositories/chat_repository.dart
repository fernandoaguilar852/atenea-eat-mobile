import '../entities/chat_message.dart';

abstract class ChatRepository {
  /// Envía un mensaje al chat IA y obtiene una respuesta
  ///
  /// [message] El mensaje del usuario
  /// Retorna un ChatMessage con la respuesta del asistente
  Future<ChatMessage> sendMessage({required String message});
}
