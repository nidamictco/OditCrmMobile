class LeadsModel {
  final String id;
  final String name;
  final String createdBy;
  final String idOfCreator; 
  final DateTime createdAt;
  final bool isDefault;

  const LeadsModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.idOfCreator,
    required this.createdAt,
    this.isDefault = false,
  });

  factory LeadsModel.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return LeadsModel(
      id: docId,
      name: data['name'].toString().toUpperCase(),
      createdBy: data['createdBy'] as String? ?? '',
      idOfCreator: data['idOfCreator'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate() as DateTime
          : DateTime.now(),
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdBy': createdBy,
      'idOfCreator': idOfCreator,
      'createdAt': createdAt,
      'isDefault': isDefault,
    };
  }

  LeadsModel copyWith({
    String? id,
    String? name,
    String? createdBy,
    String? idOfCreator,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return LeadsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      idOfCreator: idOfCreator ?? this.idOfCreator,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Compare all fields, not just id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeadsModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          createdBy == other.createdBy &&
          isDefault == other.isDefault;

  @override
  int get hashCode => Object.hash(id, name, createdBy, isDefault);
}