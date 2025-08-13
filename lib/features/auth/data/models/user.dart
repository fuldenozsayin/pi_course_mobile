import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class AppUser {
  final int id;
  final String email;
  final String username;
  final String role; // 'student' | 'tutor'

  AppUser({required this.id, required this.email, required this.username, required this.role});

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}
