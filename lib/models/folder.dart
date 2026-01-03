import 'package:uuid/uuid.dart';

/// Folder model for organizing topics in a tree structure
///
/// Folders can contain topics and sub-folders, creating a hierarchical
/// organization system for learning content.
class Folder {
  /// Unique identifier (UUID)
  final String id;

  /// Folder name
  final String name;

  /// Parent folder ID (null for root-level folders)
  final String? parentId;

  /// Date when folder was created
  final DateTime createdAt;

  /// Custom color for the folder (hex string, e.g., '#FF5733')
  final String? color;

  /// Custom icon name (Material icon name)
  final String? iconName;

  /// Whether the folder is expanded in the UI
  final bool isExpanded;

  /// Sort order for display
  final int sortOrder;

  /// UUID generator instance
  static const _uuid = Uuid();

  const Folder({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
    this.color,
    this.iconName,
    this.isExpanded = true,
    this.sortOrder = 0,
  });

  /// Create a new folder with a generated UUID
  factory Folder.create({
    required String name,
    String? parentId,
    String? color,
    String? iconName,
    int sortOrder = 0,
  }) {
    return Folder(
      id: _uuid.v4(),
      name: name,
      parentId: parentId,
      createdAt: DateTime.now(),
      color: color,
      iconName: iconName,
      isExpanded: true,
      sortOrder: sortOrder,
    );
  }

  /// Check if this is a root folder
  bool get isRoot => parentId == null;

  /// Create a copy with updated fields
  Folder copyWith({
    String? id,
    String? name,
    String? parentId,
    DateTime? createdAt,
    String? color,
    String? iconName,
    bool? isExpanded,
    int? sortOrder,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      isExpanded: isExpanded ?? this.isExpanded,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
      'iconName': iconName,
      'isExpanded': isExpanded,
      'sortOrder': sortOrder,
    };
  }

  /// Create from JSON
  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      color: json['color'] as String?,
      iconName: json['iconName'] as String?,
      isExpanded: json['isExpanded'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'Folder(id: $id, name: $name, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Folder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
