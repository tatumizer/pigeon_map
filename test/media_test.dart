import "dart:json";
import 'media.dart';
import '../lib/pigeon.dart';
import "dart:typed_data";
String jsonString=r"""{
"media" : {
"uri" : "http://javaone.com/keynote.mpg",
"title" : "Javaone Keynote",
"width" :640,
"height": 480,
"format" :"video/mpg4",
"duration" : 18000000,
"size": 58982400, 
"bitrate": 262144,
"persons": ["Bill Gates", "Steve Jobs"],
"player" : "Java",
"copyright" : "None"
},

"images" : [
{
"uri" : "http://javaone.com/keynote_large.jpg",
"title" : "Javaone Keynote",
"width" : 1024,
"height" : 768,
"size" : "Large"
},
{
"uri" : "http://javaone.com/keynote_small.jpg",
"title" : "Javaone Keynote",
"width" : 320,
"height" : 240,
"size" : "Small"
}
]
}""";
run(func, name) {
  const int ITERATIONS=100000;
  var iter=[100, 1000, 1000, ITERATIONS];
  var tm;
  int x=0;
  for (int i=0; i<4; i++) {
    var w = new Stopwatch()..start();
    x|=func(iter[i]); // warmups
    tm=w.elapsedMilliseconds;
    w.stop();
  }
  print("$name ${tm}ms ns/iter=${tm*1000000.0/100000}");
  if (x<0) print(x);
}
testEmptyLoop(iterations) {
  int x=0;
  for (int i=0; i<iterations; i++) {
    for (int j=0; j<256; j++)
      x=(x+j)&0xFF;
  } 
  return x;
}  
testStringifyNative(iterations) {
  int x=0;
  for (int i=0; i<iterations; i++) {
    String s=stringify(jsonObject);
    x=(x+s.length&0xff);
  }
  return x;
}
testStringifyPigeon(iterations) {
  int x=0;
  for (int i=0; i<iterations; i++) {
    String s=stringify(pigeonObject);
    x=(x+s.length&0xff);
  }
  return x;
}

testJsonStringNative(iterations) {
  int x=0;
  for (int i=0; i<iterations; i++) {
    var json=parse(jsonString);
    x+=json.length;
  }
  return x;
}
testJsonStringPigeon(iterations) {
  int x=0;
  for (int i=0; i<iterations; i++) {
    var message=new Message.parseJsonString(jsonString);
    x+=message.length;
  }
  return x;
}
testPigeonsonSerialize(iterations) {
  int x=0;
  for (int i=0; i<iterations; i++) {
    Uint8List buf=new Pigeonson().serialize(pigeonObject);
    x=(x+buf.length)&0xff;
  }
  return x;
}
testPigeonsonParse(iterations) {
  int x=0;
  for (int i=0; i<iterations; i++) {
    var obj=new PigeonsonParser("Message", pigeonTypeCatalog).parse(pigeonson);
    x=(x+obj.length)&0xff;
  }
  return x;
}
var jsonObject = parse(jsonString);
var pigeonObject=new Message.parseJsonString(jsonString);
var pigeonson = new Pigeonson().serialize(pigeonObject);
var revPigeonObject = new PigeonsonParser("Message", pigeonTypeCatalog).parse(pigeonson);
main() {
    
  print("source length ${jsonString.length}");
  print("pigeonson length ${pigeonson.length}");
  //print(revPigeonObject);
  run(testEmptyLoop, "Warmup");
  run(testEmptyLoop, "Warmup");
  run(testEmptyLoop, "Warmup");
  run(testEmptyLoop, "Warmup");
  run(testJsonStringNative, "parseJsonStringNative");
  run(testJsonStringPigeon, "parseJsonStringPigeon");
  run(testStringifyNative, "stringifyNative");
  run(testStringifyPigeon, "stringifyPigeon");
  run(testPigeonsonSerialize, "serializePigeonson");
  run(testPigeonsonParse, "parsePigeonson");

}