import "package:unittest/unittest.dart";
import "dart:math";
import "../lib/pigeon.dart";
import "stuff.dart";
import "dart:typed_data";
init(List list, num initValue) {
  for (int i=0; i<list.length; i++)
    list[i]=initValue+i;
  return list;
}
class StuffTest {
  static checkAll(s, s1) {
    expect(s1.x.runtimeType.toString(), equals("double"));
    expect(s1.u8.runtimeType.toString(), equals("Uint8List"));
    expect(s1.i8.runtimeType.toString(), equals("Int8List"));
    expect(s1.u16.runtimeType.toString(), equals("Uint16List"));
    expect(s1.i16.runtimeType.toString(), equals("Int16List"));
    expect(s1.u32.runtimeType.toString(), equals("Uint32List"));
    expect(s1.i32.runtimeType.toString(), equals("Int32List"));
    expect(s1.u64.runtimeType.toString(), equals("Uint64List"));
    expect(s1.i64.runtimeType.toString(), equals("Int64List"));
    expect(s1.f32.runtimeType.toString(), equals("Float32List"));
    expect(s1.f64.runtimeType.toString(), equals("Float64List"));
    expect(s1.dt.runtimeType.toString(), equals("DateTime"));
    expect(s, equals(s1));
  }
  static testMain() {
    Stuff s=new Stuff();
    s.x=12345.67890;
    s.u8=init(new Uint8List(2), 0);
    s.u16=init(new Uint16List(256), 25);
    s.u32=init(new Uint32List(3), 100);
    s.u64=init(new Uint64List(3), 200);
    s.f32=init(new Float32List(3), 1.5);
    s.f64=init(new Float64List(3), -10.5);
    s.dt=new DateTime.now();
    s.i8=init(new Int8List(5), -2);
    s.i16=init(new Int16List(55), -22);
    s.i32=init(new Int32List(55), -22);
    s.i64=init(new Int64List(55), -22);
    var jsonString  =s.toJsonString();
    var s1=new Stuff.parseJsonString(jsonString);
    checkAll(s, s1);
 
    var pgsonBytes=s.toPgsonMessage();
    var s2=new Stuff.fromPgsonMessage(pgsonBytes);
    checkAll(s, s2);
  }
}

main() {
  // right now, there's a bug in editor that hangs on exceptions
  // need to hangle them explicitly
  try {
    StuffTest.testMain();
  } catch (e, s) {
    print(e);
    print(s);
  }
}