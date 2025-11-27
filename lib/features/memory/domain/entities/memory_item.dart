class MemoryItem {
  final String id;
  final String content;        // Hatırlanacak bilgi (ör: "Ahmet ketojenik diyet yapıyor")
  final DateTime createdAt;
  final DateTime? lastUsedAt;  // Prompt’ta en son ne zaman kullanıldı
  final double importance;     // 0.0 - 1.0 arası, ileride ranking için

  MemoryItem({
    required this.id,
    required this.content,
    required this.createdAt,
    this.lastUsedAt,
    this.importance = 0.5,
  });

  MemoryItem copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    double? importance,
  }) {
    return MemoryItem(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      importance: importance ?? this.importance,
    );
  }
}
