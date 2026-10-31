import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? data;
  final String? querySource;
  final String? explanation;
  final String? templateUsed;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.data,
    this.querySource,
    this.explanation,
    this.templateUsed,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        isUser,
        timestamp,
        data,
        querySource,
        explanation,
        templateUsed,
      ];

  /// Crea un mensaje del usuario
  factory ChatMessage.fromUser({
    required String id,
    required String content,
  }) {
    return ChatMessage(
      id: id,
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  /// Crea un mensaje del asistente (respuesta del API)
  factory ChatMessage.fromAssistant({
    required String id,
    required String answer,
    List<Map<String, dynamic>>? data,
    String? querySource,
    String? explanation,
    String? templateUsed,
  }) {
    return ChatMessage(
      id: id,
      content: answer,
      isUser: false,
      timestamp: DateTime.now(),
      data: data,
      querySource: querySource,
      explanation: explanation,
      templateUsed: templateUsed,
    );
  }
}
