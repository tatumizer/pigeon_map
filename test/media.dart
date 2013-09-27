//generated from prototype file proto_media.dart

 import '../lib/pigeon.dart';
var pigeonTypeCatalog = {
  "Message" : new SerializationMetadata("Message", () => new Message(), null, 0),
  "List<Image>" : new SerializationMetadata("List<Image>", () => new List<Image>(), "Image", 2),
  "Image" : new SerializationMetadata("Image", () => new Image(), null, 0),
  "Media" : new SerializationMetadata("Media", () => new Media(), null, 0),
  "int" : new SerializationMetadata("int", null, null, 1),
  "String" : new SerializationMetadata("String", null, null, 1),
  "List<String>" : new SerializationMetadata("List<String>", () => new List<String>(), "String", 2),
};

var _metadata_Message = new PigeonStructMetadata(pigeonTypeCatalog,{'type': 'Message', 'attributes': [{'type': 'List<Image>', 'name': 'images'}, {'type': 'Media', 'name': 'media'}]});
class Message extends PigeonStruct {
  factory Message.parseJsonString(str) => jsonString2Pigeon(str, "Message",pigeonTypeCatalog);
  factory Message.fromPgsonMessage(bytes) => pgsonMessage2Pigeon(bytes, "Message",pigeonTypeCatalog);
  static final _defaultValues=[null, null];
  Message() : super(_metadata_Message,_defaultValues) {}
  List<Image> get images => getValue(0);
  void set images(List<Image> val) => setValue(0,val);
  Media get media => getValue(1);
  void set media(Media val) => setValue(1,val);
}
var _metadata_Media = new PigeonStructMetadata(pigeonTypeCatalog,{'type': 'Media', 'attributes': [{'type': 'int', 'name': 'bitrate'}, {'type': 'String', 'name': 'copyright'}, {'type': 'int', 'name': 'duration'}, {'type': 'String', 'name': 'format'}, {'type': 'int', 'name': 'height'}, {'type': 'List<String>', 'name': 'persons'}, {'type': 'String', 'name': 'player'}, {'type': 'int', 'name': 'size'}, {'type': 'String', 'name': 'title'}, {'type': 'String', 'name': 'uri'}, {'type': 'int', 'name': 'width'}]});
class Media extends PigeonStruct {
  factory Media.parseJsonString(str) => jsonString2Pigeon(str, "Media",pigeonTypeCatalog);
  factory Media.fromPgsonMessage(bytes) => pgsonMessage2Pigeon(bytes, "Media",pigeonTypeCatalog);
  static final _defaultValues=[null, null, null, null, null, null, null, null, null, null, null];
  Media() : super(_metadata_Media,_defaultValues) {}
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
}
var _metadata_Image = new PigeonStructMetadata(pigeonTypeCatalog,{'type': 'Image', 'attributes': [{'type': 'int', 'name': 'height'}, {'type': 'String', 'name': 'size'}, {'type': 'String', 'name': 'title'}, {'type': 'String', 'name': 'uri'}, {'type': 'int', 'name': 'width'}]});
class Image extends PigeonStruct {
  factory Image.parseJsonString(str) => jsonString2Pigeon(str, "Image",pigeonTypeCatalog);
  factory Image.fromPgsonMessage(bytes) => pgsonMessage2Pigeon(bytes, "Image",pigeonTypeCatalog);
  static final _defaultValues=[null, null, null, null, null];
  Image() : super(_metadata_Image,_defaultValues) {}
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
}




