import 'package:json_annotation/json_annotation.dart';

part 'human_photo_response.g.dart';

@JsonSerializable()
class HumanPhotoResponse {
  final String status;
  final String message;
  final String imageBase64;

  HumanPhotoResponse({
    required this.status,
    required this.message,
    required this.imageBase64,
  });

  factory HumanPhotoResponse.fromJson(Map<String, dynamic> json) =>
      _$HumanPhotoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HumanPhotoResponseToJson(this);
}
