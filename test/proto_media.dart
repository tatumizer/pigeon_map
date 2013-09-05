import '../lib/pigeon.dart';
import "dart:typed_data";

@Prototype
class Message {
  Media media;
  List<Image> images;
}
@Prototype
class Media {
  String uri;
  String title;
  int width;
  int height;
  String format;
  int duration;
  int size;
  int bitrate;
  List<String> persons;
  String player;
  String copyright;
}
@Prototype
class Image {
  String uri; 
  String title; 
  int width;
  int height;
  String size;
}

@Prototype
class Foo {
  DateTime dateTime;
  Uint8List u8;
  int size;
}
main() {
  //new JsonParser(jsonString,new FakePigeonJsonListener()).parse();
  generate("media.dart");
 
}