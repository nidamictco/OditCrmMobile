class AdditionalFieldModel {
  final String? id;
  final String fieldName;
  final DateTime? createdAt;

  AdditionalFieldModel({
    this.id,
    required this.fieldName,
    this.createdAt,
  });

  AdditionalFieldModel copyWith({
    String? id,
    String? fieldName,
    DateTime? createdAt,
  }) {
    return AdditionalFieldModel(
      id: id ?? this.id,
      fieldName: fieldName ?? this.fieldName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fieldName': fieldName,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory AdditionalFieldModel.fromMap(Map<String, dynamic> map, String docId) {
    return AdditionalFieldModel(
      id: docId,
      fieldName: map['fieldName'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'AdditionalFieldModel(id: $id, fieldName: $fieldName, createdAt: $createdAt)';
}