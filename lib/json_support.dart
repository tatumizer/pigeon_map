part of pigeon;

const _PIGEON_MAP_CAT=0;
const _PRIMITIVE_CAT=1;
const _LIST_CAT=2;
const _GENERIC_MAP_CAT=3;

jsonString2Pigeon(jsonString, type, catalog) {
  var listener=new PigeonJsonListener(type, catalog);
  new JsonParser(jsonString,listener).parse();
  return listener.result;
}
class PigeonJsonListener extends BuildJsonListener {
  String rootType;
  var catalog;
  var currentMetadata;
  String currentType;
  PigeonJsonListener(this.rootType, this.catalog); 
  _print(msg) {
    print("$msg key=$key value=$value cont.type=${currentContainer.runtimeType}");
  }
  void pushContainer() {
    //_print("pushContainer");
    if (currentContainer is Map) stack.add(key);
    stack.add(currentContainer);
    stack.add(currentType);
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
