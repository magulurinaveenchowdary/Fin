// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalaryConfigAdapter extends TypeAdapter<SalaryConfig> {
  @override
  final int typeId = 8;

  @override
  SalaryConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalaryConfig(
      isEnabled: fields[0] as bool,
      amount: fields[1] as double,
      creditDay: fields[2] as int,
      currency: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SalaryConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.creditDay)
      ..writeByte(3)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
