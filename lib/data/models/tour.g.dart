// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class _$_TourAdapter extends TypeAdapter<_$_Tour> {
  @override
  final typeId = 3;

  @override
  _$_Tour read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$_Tour(
      id: fields[0] as String,
      info: fields[1] as TourInfo,
      questions: (fields[2] as List)?.cast<Question>(),
    );
  }

  @override
  void write(BinaryWriter writer, _$_Tour obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.info)
      ..writeByte(2)
      ..write(obj.questions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$_TourAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
