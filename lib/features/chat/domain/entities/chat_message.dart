class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;
  final bool isStreaming;
  final bool isSavedToMemory; // NEW 🔥

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.isStreaming = false,
    this.isSavedToMemory = false,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? createdAt,
    bool? isStreaming,
    bool? isSavedToMemory,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
      isSavedToMemory: isSavedToMemory ?? this.isSavedToMemory,
    );
  }
}
