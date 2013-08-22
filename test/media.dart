import '../lib/pigeon.dart';
var pigeonTypeCatalog = {
  "Message" : new SerializationMetadata("Message", () => new Message(), null, 0),
  "Media" : new SerializationMetadata("Media", () => new Media(), null, 0),
  "List<Image>" : new SerializationMetadata("List<Image>", () => new List<Image>(), "Image", 2),
  "Image" : new SerializationMetadata("Image", () => new Image(), null, 0),
  "String" : new SerializationMetadata("String", null, null, 1),
  "int" : new SerializationMetadata("int", null, null, 1),
  "List<String>" : new SerializationMetadata("List<String>", () => new List<String>(), "String", 2),
};

var _metadata_Message = new PigeonStructMetadata(pigeonTypeCatalog,{'type': 'Message', 'attributes': [{'type': 'Media', 'name': 'media'}, {'type': 'List<Image>', 'name': 'images'}]});
class Message extends PigeonStruct {
  factory Message.parseJsonString(str) => jsonString2Pigeon(str, "Message",pigeonTypeCatalog);
  Message() : super(_metadata_Message) {}
  Media get media => _getValue(0);
  void set media(Media val) => _setValue(0,val);
  List<Image> get images => _getValue(1);
  void set images(List<Image> val) => _setValue(1,val);
}
var _metadata_Media = new PigeonStructMetadata(pigeonTypeCatalog,{'type': 'Media', 'attributes': [{'type': 'String', 'name': 'uri'}, {'type': 'String', 'name': 'title'}, {'type': 'int', 'name': 'width'}, {'type': 'int', 'name': 'height'}, {'type': 'String', 'name': 'format'}, {'type': 'int', 'name': 'duration'}, {'type': 'int', 'name': 'size'}, {'type': 'int', 'name': 'bitrate'}, {'type': 'List<String>', 'name': 'persons'}, {'type': 'String', 'name': 'player'}, {'type': 'String', 'name': 'copyright'}]});
class Media extends PigeonStruct {
  factory Media.parseJsonString(str) => jsonString2Pigeon(str, "Media",pigeonTypeCatalog);
  Media() : super(_metadata_Media) {}
  String get uri => _getValue(0);
  void set uri(String val) => _setValue(0,val);
  String get title => _getValue(1);
  void set title(String val) => _setValue(1,val);
  int get width => _getValue(2);
  void set width(int val) => _setValue(2,val);
  int get height => _getValue(3);
  void set height(int val) => _setValue(3,val);
  String get format => _getValue(4);
  void set format(String val) => _setValue(4,val);
  int get duration => _getValue(5);
  void set duration(int val) => _setValue(5,val);
  int get size => _getValue(6);
  void set size(int val) => _setValue(6,val);
  int get bitrate => _getValue(7);
  void set bitrate(int val) => _setValue(7,val);
  List<String> get persons => _getValue(8);
  void set persons(List<String> val) => _setValue(8,val);
  String get player => _getValue(9);
  void set player(String val) => _setValue(9,val);
  String get copyright => _getValue(10);
  void set copyright(String val) => _setValue(10,val);
}
var _metadata_Image = new PigeonStructMetadata(pigeonTypeCatalog,{'type': 'Image', 'attributes': [{'type': 'String', 'name': 'uri'}, {'type': 'String', 'name': 'title'}, {'type': 'int', 'name': 'width'}, {'type': 'int', 'name': 'height'}, {'type': 'String', 'name': 'size'}]});
class Image extends PigeonStruct {
  factory Image.parseJsonString(str) => jsonString2Pigeon(str, "Image",pigeonTypeCatalog);
  Image() : super(_metadata_Image) {}
  String get uri => _getValue(0);
  void set uri(String val) => _setValue(0,val);
  String get title => _getValue(1);
  void set title(String val) => _setValue(1,val);
  int get width => _getValue(2);
  void set width(int val) => _setValue(2,val);
  int get height => _getValue(3);
  void set height(int val) => _setValue(3,val);
  String get size => _getValue(4);
  void set size(String val) => _setValue(4,val);
}



main() {
  //new JsonParser(jsonString,new FakePigeonJsonListener()).parse();
  generate("media.dart");
 
}