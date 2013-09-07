//generated from prototype file test/proto_stuff.dart
import '../lib/pigeon.dart';
import "dart:typed_data";
//test
var pigeonTypeCatalog = {
  "Stuff" : new SerializationMetadata("Stuff", () => new Stuff(), null, 0),
  "DateTime" : new SerializationMetadata("DateTime", null, null, 1),
  "Float32List" : new SerializationMetadata("Float32List", () => new List<double>(), "int", 1),
  "int" : new SerializationMetadata("int", null, null, 1),
  "Float64List" : new SerializationMetadata("Float64List", () => new List<double>(), "int", 1),
  "Int16List" : new SerializationMetadata("Int16List", () => new List<int>(), "int", 1),
  "Int32List" : new SerializationMetadata("Int32List", () => new List<int>(), "int", 1),
  "Int64List" : new SerializationMetadata("Int64List", () => new List<int>(), "int", 1),
  "Int8List" : new SerializationMetadata("Int8List", () => new List<int>(), "int", 1),
  "Uint16List" : new SerializationMetadata("Uint16List", () => new List<int>(), "int", 1),
  "Uint32List" : new SerializationMetadata("Uint32List", () => new List<int>(), "int", 1),
  "Uint64List" : new SerializationMetadata("Uint64List", () => new List<int>(), "int", 1),
  "Uint8List" : new SerializationMetadata("Uint8List", () => new List<int>(), "int", 1),
  "double" : new SerializationMetadata("double", null, null, 1),
};

var _metadata_Stuff = new PigeonStructMetadata(pigeonTypeCatalog,{'type': 'Stuff', 'attributes': [{'type': 'DateTime', 'name': 'dt'}, {'type': 'Float32List', 'name': 'f32'}, {'type': 'Float64List', 'name': 'f64'}, {'type': 'Int16List', 'name': 'i16'}, {'type': 'Int32List', 'name': 'i32'}, {'type': 'Int64List', 'name': 'i64'}, {'type': 'Int8List', 'name': 'i8'}, {'type': 'Uint16List', 'name': 'u16'}, {'type': 'Uint32List', 'name': 'u32'}, {'type': 'Uint64List', 'name': 'u64'}, {'type': 'Uint8List', 'name': 'u8'}, {'type': 'double', 'name': 'x'}]});
class Stuff extends PigeonStruct {
  factory Stuff.parseJsonString(str) => jsonString2Pigeon(str, "Stuff",pigeonTypeCatalog);
  factory Stuff.fromPgsonMessage(bytes) => pgsonMessage2Pigeon(bytes, "Stuff",pigeonTypeCatalog);
  Stuff() : super(_metadata_Stuff) {}
  DateTime get dt => getValue(0);
  void set dt(DateTime val) => setValue(0,val);
  Float32List get f32 => getValue(1);
  void set f32(Float32List val) => setValue(1,val);
  Float64List get f64 => getValue(2);
  void set f64(Float64List val) => setValue(2,val);
  Int16List get i16 => getValue(3);
  void set i16(Int16List val) => setValue(3,val);
  Int32List get i32 => getValue(4);
  void set i32(Int32List val) => setValue(4,val);
  Int64List get i64 => getValue(5);
  void set i64(Int64List val) => setValue(5,val);
  Int8List get i8 => getValue(6);
  void set i8(Int8List val) => setValue(6,val);
  Uint16List get u16 => getValue(7);
  void set u16(Uint16List val) => setValue(7,val);
  Uint32List get u32 => getValue(8);
  void set u32(Uint32List val) => setValue(8,val);
  Uint64List get u64 => getValue(9);
  void set u64(Uint64List val) => setValue(9,val);
  Uint8List get u8 => getValue(10);
  void set u8(Uint8List val) => setValue(10,val);
  double get x => getValue(11);
  void set x(double val) => setValue(11,val);
}

