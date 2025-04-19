// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class PageModelAdapter extends TypeAdapter<PageModel> {
  @override
  final int typeId = 0;

  @override
  PageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PageModel(
      uid: fields[0] as String,
      title: fields[1] as String,
      created: fields[2] as DateTime,
      fullText: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PageModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.created)
      ..writeByte(3)
      ..write(obj.fullText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
