// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UploadTaskAdapter extends TypeAdapter<UploadTask> {
  @override
  final int typeId = 0;

  @override
  UploadTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UploadTask(
      id: fields[0] as String,
      filePath: fields[1] as String,
      teamId: fields[2] as String,
      sessionId: fields[3] as String,
      isExcuse: fields[4] as bool,
      message: fields[5] as String?,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UploadTask obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.teamId)
      ..writeByte(3)
      ..write(obj.sessionId)
      ..writeByte(4)
      ..write(obj.isExcuse)
      ..writeByte(5)
      ..write(obj.message)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
