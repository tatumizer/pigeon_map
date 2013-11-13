//>media.dart

import '../lib/src/generator.dart'; //-
//+ import '../lib/pigeon.dart';
@Prototype
class Message {
  Media media;
  List<Image> images;
  //asis+
  
  String testAsIs() {
    return "Message";
  }
  //asis-
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
  //asis+
  
  String testAsIs() {
    return "Media";
  }

  //asis-
}
@Prototype
class Image {
  String uri; 
  String title; 
  int width;
  int height;
  String size;
  //asis+
  
  String testAsIs() {
    return "Image";
  }
  //asis-
}


main() { //-
  preprocess(); //-
} //-