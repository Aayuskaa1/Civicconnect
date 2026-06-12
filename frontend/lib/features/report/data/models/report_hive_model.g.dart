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
      reportName: fields[1] as String,
      status: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReportHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.reportName)
      ..writeByte(2)
      ..write(obj.status);
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
