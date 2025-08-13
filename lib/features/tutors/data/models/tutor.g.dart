// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tutor _$TutorFromJson(Map<String, dynamic> json) => Tutor(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  subjects: (json['subjects'] as List<dynamic>)
      .map((e) => MiniSubject.fromJson(e as Map<String, dynamic>))
      .toList(),
  hourly_rate: Tutor._toInt(json['hourly_rate']),
  rating: Tutor._toDouble(json['rating']),
  bio: json['bio'] as String,
);

Map<String, dynamic> _$TutorToJson(Tutor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'subjects': instance.subjects,
  'hourly_rate': instance.hourly_rate,
  'rating': instance.rating,
  'bio': instance.bio,
};

MiniSubject _$MiniSubjectFromJson(Map<String, dynamic> json) =>
    MiniSubject(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$MiniSubjectToJson(MiniSubject instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
