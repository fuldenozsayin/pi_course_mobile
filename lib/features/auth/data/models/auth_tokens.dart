import 'package:json_annotation/json_annotation.dart';
part 'auth_tokens.g.dart';

@JsonSerializable()
class AuthTokens {
  final String access;
  final String refresh;
  AuthTokens({required this.access, required this.refresh});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
}
