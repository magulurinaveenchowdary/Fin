// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EMIAdapter extends TypeAdapter<EMI> {
  @override
  final int typeId = 2;

  @override
  EMI read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EMI(
      id: fields[0] as String,
      loanName: fields[1] as String,
      lenderName: fields[2] as String,
      principal: fields[3] as double,
      interestRate: fields[4] as double,
      tenureMonths: fields[5] as int,
      startDate: fields[6] as DateTime,
      emiAmount: fields[7] as double,
      paidMonths: (fields[8] as List).cast<String>(),
      isActive: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EMI obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.loanName)
      ..writeByte(2)
      ..write(obj.lenderName)
      ..writeByte(3)
      ..write(obj.principal)
      ..writeByte(4)
      ..write(obj.interestRate)
      ..writeByte(5)
      ..write(obj.tenureMonths)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.emiAmount)
      ..writeByte(8)
      ..write(obj.paidMonths)
      ..writeByte(9)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EMIAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
