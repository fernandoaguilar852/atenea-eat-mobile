import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../mappers/chat_mapper.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remoteDatasource;

  ChatRepositoryImpl({required this.remoteDatasource});

  @override
  Future<ChatMessage> sendMessage({required String message}) async {
    try {
      final response = await remoteDatasource.sendMessage(message: message);

      // Validar respuesta exitosa
      if (response.messageResponse.responseCode != '0000') {
        throw Exception(response.messageResponse.responseMessage);
      }

      // Convertir DTO a Entity
      return ChatMapper.fromDto(response);
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }
}
