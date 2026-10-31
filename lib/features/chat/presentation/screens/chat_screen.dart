import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('Chat IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(chatProvider.notifier).clearMessages();
            },
            tooltip: 'Limpiar conversación',
          ),
        ],
      ),
      body: Column(
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
                      color: const Color(0xFF0d6efd),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      onPressed: chatState.isLoading ? null : _sendMessage,
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
