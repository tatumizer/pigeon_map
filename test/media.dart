//generated from prototype file proto_media.dart

 import '../lib/pigeon.dart';
final _media_pigeonTypeCatalog = {
  "Message" : new SerializationMetadata("Message", () => new Message(), null, 0),
  "List<Image>" : new SerializationMetadata("List<Image>", () => new List<Image>(), "Image", 2),
  "Image" : new SerializationMetadata("Image", () => new Image(), null, 0),
  "Media" : new SerializationMetadata("Media", () => new Media(), null, 0),
  "int" : new SerializationMetadata("int", null, null, 1),
  "String" : new SerializationMetadata("String", null, null, 1),
  "List<String>" : new SerializationMetadata("List<String>", () => new List<String>(), "String", 2),
};

class Message extends PigeonStruct {
  static final _metadata = new PigeonStructMetadata(_media_pigeonTypeCatalog,{'type': 'Message', 'attributes': [{'type': 'List<Image>', 'name': 'images'}, {'type': 'Media', 'name': 'media'}]});
  factory Message.parseJsonString(str) => jsonString2Pigeon(str, "Message",_media_pigeonTypeCatalog);
  factory Message.fromPgsonMessage(bytes) => pgsonMessage2Pigeon(bytes, "Message",_media_pigeonTypeCatalog);
  static final _defaultValues=[null, null];
  Message() : super(_metadata,_defaultValues) {}
  List<Image> get images => getValue(0);
  void set images(List<Image> val) => setValue(0,val);
  Media get media => getValue(1);
  void set media(Media val) => setValue(1,val);

  String toString() => "Tetsing asis: Message object";
  String testAsIs() {
    return "Message";
  }
  
}
class Media extends PigeonStruct {
  static final _metadata = new PigeonStructMetadata(_media_pigeonTypeCatalog,{'type': 'Media', 'attributes': [{'type': 'int', 'name': 'bitrate'}, {'type': 'String', 'name': 'copyright'}, {'type': 'int', 'name': 'duration'}, {'type': 'String', 'name': 'format'}, {'type': 'int', 'name': 'height'}, {'type': 'List<String>', 'name': 'persons'}, {'type': 'String', 'name': 'player'}, {'type': 'int', 'name': 'size'}, {'type': 'String', 'name': 'title'}, {'type': 'String', 'name': 'uri'}, {'type': 'int', 'name': 'width'}]});
  factory Media.parseJsonString(str) => jsonString2Pigeon(str, "Media",_media_pigeonTypeCatalog);
  factory Media.fromPgsonMessage(bytes) => pgsonMessage2Pigeon(bytes, "Media",_media_pigeonTypeCatalog);
  static final _defaultValues=[null, null, null, null, null, null, null, null, null, null, null];
  Media() : super(_metadata,_defaultValues) {}
  int get bitrate => getValue(0);
  void set bitrate(int val) => setValue(0,val);
  String get copyright => getValue(1);
  void set copyright(String val) => setValue(1,val);
  int get duration => getValue(2);
  void set duration(int val) => setValue(2,val);
  String get format => getValue(3);
  void set format(String val) => setValue(3,val);
  int get height => getValue(4);
  void set height(int val) => setValue(4,val);
  List<String> get persons => getValue(5);
  void set persons(List<String> val) => setValue(5,val);
  String get player => getValue(6);
  void set player(String val) => setValue(6,val);
  int get size => getValue(7);
  void set size(int val) => setValue(7,val);
  String get title => getValue(8);
  void set title(String val) => setValue(8,val);
  String get uri => getValue(9);
  void set uri(String val) => setValue(9,val);
  int get width => getValue(10);
  void set width(int val) => setValue(10,val);

  String toString() => "Tetsing asis: Media object";
  String testAsIs() {
    return "Media";
  }
  
}
class Image extends PigeonStruct {
  static final _metadata = new PigeonStructMetadata(_media_pigeonTypeCatalog,{'type': 'Image', 'attributes': [{'type': 'int', 'name': 'height'}, {'type': 'String', 'name': 'size'}, {'type': 'String', 'name': 'title'}, {'type': 'String', 'name': 'uri'}, {'type': 'int', 'name': 'width'}]});
  factory Image.parseJsonString(str) => jsonString2Pigeon(str, "Image",_media_pigeonTypeCatalog);
  factory Image.fromPgsonMessage(bytes) => pgsonMessage2Pigeon(bytes, "Image",_media_pigeonTypeCatalog);
  static final _defaultValues=[null, null, null, null, null];
  Image() : super(_metadata,_defaultValues) {}
  int get height => getValue(0);
  void set height(int val) => setValue(0,val);
  String get size => getValue(1);
  void set size(String val) => setValue(1,val);
  String get title => getValue(2);
  void set title(String val) => setValue(2,val);
  String get uri => getValue(3);
  void set uri(String val) => setValue(3,val);
  int get width => getValue(4);
  void set width(int val) => setValue(4,val);

  String toString() => "Tetsing asis: Image object";
  String testAsIs() {
    return "Image";
  }
  
}




