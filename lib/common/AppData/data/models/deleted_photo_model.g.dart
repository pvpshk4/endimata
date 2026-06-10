// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_photo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedPhotoModelAdapter extends TypeAdapter<DeletedPhotoModel> {
  @override
  final int typeId = 2;

  @override
  DeletedPhotoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedPhotoModel(
      id: fields[0] as String,
      type: fields[1] as String,
      imageBase64: fields[2] as String,
      userName: fields[3] as String,
      category: fields[4] as String?,
      subcategory: fields[5] as String?,
      subSubcategory: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedPhotoModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.imageBase64)
      ..writeByte(3)
      ..write(obj.userName)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.subcategory)
      ..writeByte(6)
      ..write(obj.subSubcategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedPhotoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
