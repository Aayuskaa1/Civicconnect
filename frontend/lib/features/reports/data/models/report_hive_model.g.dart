// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportHiveModelAdapter extends TypeAdapter<ReportHiveModel> {
  @override
  final int typeId = 1;

  @override
  ReportHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportHiveModel(
      reportId: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      status: fields[4] as String,
      imageUrl: fields[5] as String?,
      location: fields[6] as String,
      submittedBy: fields[7] as String,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReportHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.submittedBy)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
