import 'package:json_annotation/json_annotation.dart';
part 'subject.g.dart';

@JsonSerializable()
class Subject {
  final int id;
  final String name;
  Subject({required this.id, required this.name});

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
