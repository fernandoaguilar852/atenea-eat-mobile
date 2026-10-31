class ChatQueryRequestDto {
  final String message;

  const ChatQueryRequestDto({required this.message});

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
