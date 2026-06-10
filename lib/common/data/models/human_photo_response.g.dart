// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'human_photo_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HumanPhotoResponse _$HumanPhotoResponseFromJson(Map<String, dynamic> json) =>
    HumanPhotoResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      imageBase64: json['imageBase64'] as String,
    );

Map<String, dynamic> _$HumanPhotoResponseToJson(HumanPhotoResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'imageBase64': instance.imageBase64,
    };
