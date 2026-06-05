// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComplaintHiveModelAdapter extends TypeAdapter<ComplaintHiveModel> {
  @override
  final int typeId = 2;

  @override
  ComplaintHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComplaintHiveModel(
      complaintId: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      status: fields[4] as String?,
      userEmail: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ComplaintHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.complaintId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.userEmail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
