import 'package:uuid/uuid.dart';

/// Represents a deck/collection of flashcards
class Deck {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final int cardCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final Map<String, dynamic>? metadata;

  Deck({
    String? id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.cardCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isArchived = false,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Copy with method for immutability
  Deck copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    int? cardCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    Map<String, dynamic>? metadata,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      cardCount: cardCount ?? this.cardCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'card_count': cardCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
      'metadata': metadata != null ? metadata.toString() : null,
    };
  }

  /// Create from JSON
  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      cardCount: json['card_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isArchived: (json['is_archived'] as int?) == 1,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'Deck(id: $id, name: $name, cards: $cardCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Deck && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
