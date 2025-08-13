import 'package:json_annotation/json_annotation.dart';
part 'tutor.g.dart';

@JsonSerializable()
class Tutor {
  final int id;
  final String name;
  final List<MiniSubject> subjects;

  @JsonKey(fromJson: _toInt)
  final int hourly_rate;

  @JsonKey(fromJson: _toDouble)
  final double rating;

  final String bio;

  Tutor({
    required this.id,
    required this.name,
    required this.subjects,
    required this.hourly_rate,
    required this.rating,
    required this.bio,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) => _$TutorFromJson(json);
  Map<String, dynamic> toJson() => _$TutorToJson(this);

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final asInt = int.tryParse(v);
      if (asInt != null) return asInt;
      final asDouble = double.tryParse(v);
      if (asDouble != null) return asDouble.toInt();
    }
    throw ArgumentError('hourly_rate is not a number: $v');
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    throw ArgumentError('rating is not a number: $v');
  }
}

@JsonSerializable()
class MiniSubject {
  final int id;
  final String name;
  MiniSubject({required this.id, required this.name});

  factory MiniSubject.fromJson(Map<String, dynamic> json) => _$MiniSubjectFromJson(json);
  Map<String, dynamic> toJson() => _$MiniSubjectToJson(this);
}
