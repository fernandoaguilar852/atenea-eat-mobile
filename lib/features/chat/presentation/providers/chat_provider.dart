import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/send_message_usecase.dart';

// Provider del repositorio de chat
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final datasource = ChatRemoteDatasourceImpl(dio: dio);

  return ChatRepositoryImpl(remoteDatasource: datasource);
});

// Provider del UseCase
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return SendMessageUseCase(repository);
});

// Estado de chat
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier de chat
class ChatNotifier extends StateNotifier<ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  static const _uuid = Uuid();

  ChatNotifier({
    required this.sendMessageUseCase,
  }) : super(const ChatState());

  /// Envía un mensaje al chat IA
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Crear mensaje del usuario
    final userMessage = ChatMessage.fromUser(
      id: _uuid.v4(),
      content: message.trim(),
    );

    // Agregar mensaje del usuario a la lista
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Llamar al API
      final assistantMessage = await sendMessageUseCase.call(message: message);

      // Agregar respuesta del asistente
      state = ChatState(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Limpia el historial de mensajes
  void clearMessages() {
    state = const ChatState();
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider del notifier
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final sendMessageUseCase = ref.watch(sendMessageUseCaseProvider);

  return ChatNotifier(
    sendMessageUseCase: sendMessageUseCase,
  );
});
