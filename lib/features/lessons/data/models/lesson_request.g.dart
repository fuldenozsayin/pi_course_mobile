// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonRequest _$LessonRequestFromJson(
  Map<String, dynamic> json,
) => LessonRequest(
  id: LessonRequest._toInt(json['id']),
  tutorId: (LessonRequest._readTutorId(json, 'tutorId') as num).toInt(),
  subjectId: (LessonRequest._readSubjectId(json, 'subjectId') as num).toInt(),
  startTime: LessonRequest._toStringNonNull(json['start_time']),
  durationMinutes: LessonRequest._toInt(json['duration_minutes']),
  status: LessonRequest._toStringNonNull(json['status']),
  createdAt: LessonRequest._toStringNonNull(json['created_at']),
  note: json['note'] as String?,
  tutor_name: LessonRequest._readTutorName(json, 'tutor_name') as String?,
  subject_name: LessonRequest._readSubjectName(json, 'subject_name') as String?,
  student_name: json['student_name'] as String?,
);

Map<String, dynamic> _$LessonRequestToJson(LessonRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tutorId': instance.tutorId,
      'subjectId': instance.subjectId,
      'start_time': instance.startTime,
      'duration_minutes': instance.durationMinutes,
      'note': instance.note,
      'status': instance.status,
      'created_at': instance.createdAt,
      'tutor_name': instance.tutor_name,
      'subject_name': instance.subject_name,
      'student_name': instance.student_name,
    };
