import '../../domain/entities/memory_item.dart';

class MemoryItemModel extends MemoryItem {
  MemoryItemModel({
    required super.id,
    required super.content,
    required super.createdAt,
    super.lastUsedAt,
    super.importance = 0.5,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'lastUsedAt': lastUsedAt?.toIso8601String(),
        'importance': importance,
      };

  factory MemoryItemModel.fromJson(Map<String, dynamic> json) {
    return MemoryItemModel(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
      importance: (json['importance'] as num?)?.toDouble() ?? 0.5,
    );
  }
}
