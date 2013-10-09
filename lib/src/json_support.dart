part of pigeon;

const int _PIGEON_MAP_CAT=0;
const int _PRIMITIVE_CAT=1;
const int _LIST_CAT=2;
const int _GENERIC_MAP_CAT=3;

jsonString2Pigeon(jsonString, type, catalog) {
  var listener=new PigeonJsonListener(type, catalog);
  new JsonParser(jsonString,listener).parse();
  return listener.result;
}
final _specialTypes= {
   "DateTime": _DATE_TIME,
   "Uint8List": _UINT8_LIST,
   "Uint16List": _UINT16_LIST,
   "Uint32List": _UINT32_LIST,
   "Uint64List": _UINT64_LIST,
   "Int8List": _INT8_LIST,
   "Int16List": _INT16_LIST,
   "Int32List": _INT32_LIST,
   "Int64List": _INT64_LIST,
   "Float32List": _FLOAT32_LIST,
   "Float64List": _FLOAT64_LIST
};
class PigeonJsonListener extends BuildJsonListener {
  
  String rootType;
  var catalog;
  var currentMetadata;
  String currentType;
  PigeonJsonListener(this.rootType, this.catalog); 
  _print(msg) {
    print("$msg key=$key value=$value cont.type=${currentContainer.runtimeType}");
  }
  _reviveObject(value, type) { 
    //print("reviving key $key value $value");
    int tag=_specialTypes[type];
    if (tag==null) return value;
    switch (tag) {
      case _DATE_TIME: 
        return DateTime.parse(value);
      case _UINT8_LIST:
        return new Uint8List(value.length)..setRange(0, value.length, value, 0);
      case _UINT16_LIST:
        return new Uint16List(value.length)..setRange(0, value.length, value, 0);  
      case _UINT32_LIST:
        return new Uint32List(value.length)..setRange(0, value.length, value, 0);   
      case _UINT64_LIST:
        return new Uint64List(value.length)..setRange(0, value.length, value, 0);    
      case _INT8_LIST:
        return new Int8List(value.length)..setRange(0, value.length, value, 0);  
      case _INT16_LIST:
        return new Int16List(value.length)..setRange(0, value.length, value, 0);  
      case _INT32_LIST:
        return new Int32List(value.length)..setRange(0, value.length, value, 0);   
      case _INT64_LIST:
        return new Int64List(value.length)..setRange(0, value.length, value, 0);  
      case _FLOAT32_LIST:
        return new Float32List(value.length)..setRange(0, value.length, value, 0);   
      case _FLOAT64_LIST:
        return new Float64List(value.length)..setRange(0, value.length, value, 0);      
    }

  } 
  void pushContainer() {
    //_print("pushContainer");
    if (currentContainer is Map) stack.add(key);
    stack.add(currentContainer);
    stack.add(currentType);
  }
  void propertyValue() {
    Map map = currentContainer;
    // heuristic first
    if (value is List || (value is String && value.length>0 && value.codeUnitAt(0) <= 50))
      value=_reviveObject(value, currentContainer.nameSet.getSlotType(key));
    //print("property value called for $currentType $value");
    map[key] = value;
    key = value = null;
  }
  void popContainer() {
    //_print("popContainer");
    value = currentContainer;
    String type=stack.removeLast();

    currentContainer = stack.removeLast();
    if (currentContainer is Map) key = stack.removeLast();
    //_print("type $type level ${stack.length}");
    if (stack.length!=0)
      setCurrentType(type);
  }

  setCurrentType(String type) {
    if (type==currentType) return;
    currentType=type;
    currentMetadata=catalog[currentType];
    assert(currentMetadata!=null);
    //print("setting current type $currentType");
  }
  beginChildObject() {
    int cat=currentMetadata.category;
    setCurrentType(cat==_PIGEON_MAP_CAT? currentContainer.nameSet.getSlotType(key) :
        currentMetadata.childType);
    currentContainer=currentMetadata.constructor();
  }
  void beginObject() {
    //_print("beginObject");
    pushContainer();
    if (currentType==null) {
      setCurrentType(rootType);
      //_print(currentMetadata);
      currentContainer=currentMetadata.constructor();
      
    }  
    else beginChildObject();
    /*
    if (currentContainer is! Map)
      throw "not a map $key";
    */  
  }
  void arrayElement() {
    List list = currentContainer;
    // heuristic 
    if (value is List || (value is String && value.length>=18 && value.codeUnitAt(0) <= 50))
      value=_reviveObject(value, currentMetadata.childType);
    currentContainer.add(value);
    value = null;
  }
  void beginArray() {
    //_print("beginArray");
    pushContainer();
    beginChildObject();
    /*
    if (currentContainer is! List)
      throw "not a list $key";
    */  
  }


  /** Read out the final result of parsing a JSON string. */
  get result {
    assert(currentContainer == null);
    return value;
  }
}
