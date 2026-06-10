// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhotoResponse _$PhotoResponseFromJson(Map<String, dynamic> json) =>
    PhotoResponse(
      status: json['status'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$PhotoResponseToJson(PhotoResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
    };
