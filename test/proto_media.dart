//>media.dart

import '../lib/pigeon.dart';

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


main() { //-
  preprocess(); //-
} //-