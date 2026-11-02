import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final timeFormat = DateFormat('HH:mm');

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _messageController.addListener(() {
      setState(() {}); // Actualizar UI cuando cambia el texto
    });
  }

  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        debugPrint('Speech Error: $error');
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error de voz: ${error.errorMsg}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      onStatus: (status) {
        debugPrint('Speech Status: $status');
        // Detener cuando el reconocimiento termina
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _isListening = false);
          }
        }
      },
    );
    debugPrint('Speech available: $_speechAvailable');
    if (mounted && !_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reconocimiento de voz no disponible en este dispositivo'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    await ref.read(chatProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }

  Future<void> _toggleListening() async {
    debugPrint('Toggle listening pressed. Speech available: $_speechAvailable, Is listening: $_isListening');

    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reconocimiento de voz no disponible'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_isListening) {
      // Detener grabación
      debugPrint('Stopping speech recognition');
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      // Mostrar mensaje de inicio
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Iniciando grabación...'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Iniciar grabación (speech_to_text maneja TODOS los permisos automáticamente)
      debugPrint('Starting speech recognition');
      setState(() => _isListening = true);

      try {
        await _speech.listen(
          onResult: (result) {
            debugPrint('Speech result: ${result.recognizedWords}');
            setState(() {
              _messageController.text = result.recognizedWords;
            });
            // Si es el resultado final, detener
            if (result.finalResult) {
              _speech.stop();
              setState(() => _isListening = false);
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.dictation,
            partialResults: true,
            onDevice: false,
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 2), // Reducido a 2 segundos
            localeId: 'es_ES',
          ),
        );
        debugPrint('Speech listening started successfully');
      } catch (e) {
        debugPrint('Error starting speech: $e');
        setState(() => _isListening = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al iniciar reconocimiento de voz'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.w),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return _MessageBubble(
                        message: message,
                        timeFormat: timeFormat,
                      );
                    },
                  ),
          ),

          // Indicador de carga
          if (chatState.isLoading)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0d6efd),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Escribiendo...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF808080),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Error
          if (chatState.error != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFdc3545).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFFdc3545),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: const Color(0xFFdc3545),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFdc3545),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: const Color(0xFFdc3545),
                    iconSize: 20.sp,
                    onPressed: () {
                      ref.read(chatProvider.notifier).clearError();
                    },
                  ),
                ],
              ),
            ),

          // Input de mensaje
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1a1a1a),
              border: Border(
                top: BorderSide(
                  color: Color(0xFF363636),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF808080),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF262626),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    decoration: BoxDecoration(
                      color: _isListening
                          ? Colors.red
                          : (_messageController.text.isEmpty
                              ? const Color(0xFF198754)
                              : const Color(0xFF0d6efd)),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isListening
                            ? Icons.stop
                            : (_messageController.text.isEmpty
                                ? Icons.mic
                                : Icons.send),
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      onPressed: _messageController.text.isEmpty
                          ? _toggleListening
                          : (chatState.isLoading ? null : _sendMessage),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: const Color(0xFF0d6efd).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(
              Icons.smart_toy,
              size: 40.sp,
              color: const Color(0xFF0d6efd),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            '¡Hola! Soy tu asistente IA',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              'Pregúntame sobre ventas, inventario, facturas y más',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF808080),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: [
              _SuggestionChip(text: 'Ventas de hoy'),
              _SuggestionChip(text: 'Productos bajo stock'),
              _SuggestionChip(text: 'Total de facturas'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final DateFormat timeFormat;

  const _MessageBubble({
    required this.message,
    required this.timeFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFF0d6efd),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF0d6efd)
                    : const Color(0xFF262626),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 18.r : 4.r),
                  topRight: Radius.circular(isUser ? 4.r : 18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    timeFormat.format(message.timestamp),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF808080),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) SizedBox(width: 40.w),
          if (!isUser) SizedBox(width: 40.w),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;

  const _SuggestionChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFFB0B0B0),
        ),
      ),
    );
  }
}
