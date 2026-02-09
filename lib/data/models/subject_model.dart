import '../../domain/entities/subject_entity.dart';

class SubjectModel extends Subject {
  const SubjectModel({
    required super.id,
    required super.userId,
    required super.name,
    super.code,
    super.description,
    super.color,
    super.semester,
    super.professorName,
    super.schedule,
    super.isArchived,
    super.syncStatus,
    super.serverId,
    super.colorHex,
    super.teacherName,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    // Usa 'color' de la BD para colorHex, y 'professor_name' para teacherName
    return SubjectModel(
      id: json['subject_id'],
      userId: json['user_id'],
      name: json['subject_name'],
      code: json['subject_code'],
      description: json['description'] ?? '',
      color: json['color'],
      semester: json['semester'],
      professorName: json['professor_name'],
      schedule: json['schedule'],
      isArchived: json['is_archived'] == 1,
      syncStatus: json['sync_status'] ?? 'synced',
      serverId: json['server_id'],
      // Mapear campos de BD a propiedades de la entidad
      colorHex: json['color'] ?? '#2196F3',
      teacherName: json['professor_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    // Solo guardar campos que existen en la BD
    // Usar colorHex -> color y teacherName -> professor_name
    return {
      'subject_id': id,
      'user_id': userId,
      'subject_name': name,
      'subject_code': code,
      'description': description,
      'color': colorHex, // Guardar colorHex en el campo 'color' de la BD
      'semester': semester,
      'professor_name': teacherName.isNotEmpty ? teacherName : professorName, // Usar teacherName si está presente
      'schedule': schedule,
      'is_archived': isArchived ? 1 : 0,
      'sync_status': syncStatus,
      'server_id': serverId,
    };
  }

  factory SubjectModel.fromEntity(Subject subject) {
    return SubjectModel(
      id: subject.id,
      userId: subject.userId,
      name: subject.name,
      code: subject.code,
      description: subject.description,
      color: subject.color,
      semester: subject.semester,
      professorName: subject.professorName,
      schedule: subject.schedule,
      isArchived: subject.isArchived,
      syncStatus: subject.syncStatus,
      serverId: subject.serverId,
      colorHex: subject.colorHex,
      teacherName: subject.teacherName,
    );
  }
}
