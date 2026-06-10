import 'package:json_annotation/json_annotation.dart';

part 'photo_response.g.dart';

@JsonSerializable()
class PhotoResponse {
  final String status;
  final String message;

  PhotoResponse({required this.status, required this.message});

  factory PhotoResponse.fromJson(Map<String, dynamic> json) =>
      _$PhotoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PhotoResponseToJson(this);
}
