import 'package:json_annotation/json_annotation.dart';

part 'lesson_request.g.dart';

@JsonSerializable()
class LessonRequest {
  @JsonKey(fromJson: _toInt)
  final int id;

  // tutor: hem "tutor_id", hem de "tutor" (int ya da {"id":..,"name":..}) gelebilir
  @JsonKey(readValue: _readTutorId)
  final int tutorId;

  // subject: hem "subject_id", hem de "subject" (int ya da {"id":..,"name":..}) gelebilir
  @JsonKey(readValue: _readSubjectId)
  final int subjectId;

  @JsonKey(name: 'start_time', fromJson: _toStringNonNull)
  final String startTime;

  @JsonKey(name: 'duration_minutes', fromJson: _toInt)
  final int durationMinutes;

  final String? note;

  @JsonKey(fromJson: _toStringNonNull)
  final String status;

  @JsonKey(name: 'created_at', fromJson: _toStringNonNull)
  final String createdAt;

  // İsim alanları farklı şekillerde gelebilir
  @JsonKey(readValue: _readTutorName)
  final String? tutor_name;

  @JsonKey(readValue: _readSubjectName)
  final String? subject_name;

  final String? student_name;

  LessonRequest({
    required this.id,
    required this.tutorId,
    required this.subjectId,
    required this.startTime,
    required this.durationMinutes,
    required this.status,
    required this.createdAt,
    this.note,
    this.tutor_name,
    this.subject_name,
    this.student_name,
  });

  factory LessonRequest.fromJson(Map<String, dynamic> json) =>
      _$LessonRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LessonRequestToJson(this);

  // ----------------- helpers -----------------
  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final i = int.tryParse(v);
      if (i != null) return i;
      final d = double.tryParse(v);
      if (d != null) return d.toInt();
    }
    return 0;
  }

  static String _toStringNonNull(dynamic v) => v?.toString() ?? '';

  // readValue helpers (json_serializable)
  static Object? _get(Map json, String key) => json[key];

  static Object? _readTutorId(Map json, String key) {
    final v = _get(json, 'tutor_id') ?? _get(json, 'tutor');
    if (v is Map) return _toInt(v['id'] ?? v['pk']);
    return _toInt(v);
  }

  static Object? _readSubjectId(Map json, String key) {
    final v = _get(json, 'subject_id') ?? _get(json, 'subject');
    if (v is Map) return _toInt(v['id'] ?? v['pk']);
    return _toInt(v);
  }

  static Object? _readTutorName(Map json, String key) {
    // Öncelik explicit alan; yoksa nested objeden dene
    final explicit = _get(json, 'tutor_name');
    if (explicit != null) return explicit.toString();
    final t = _get(json, 'tutor');
    if (t is Map && t['name'] != null) return t['name'].toString();
    return null;
  }

  static Object? _readSubjectName(Map json, String key) {
    final explicit = _get(json, 'subject_name');
    if (explicit != null) return explicit.toString();
    final s = _get(json, 'subject');
    if (s is Map && s['name'] != null) return s['name'].toString();
    return null;
  }
}
