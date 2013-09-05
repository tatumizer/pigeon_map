part of pigeon;


class PigeonStruct extends PigeonMap {
  
  PigeonStruct(metadata): super(metadata){ }
  setValue(n,val){_values[n]=val;}
  getValue(n) { var v= _values[n]; return identical(v, PigeonMap._undefined) ? null :v; }
  String toJsonString() {
    try { // UGLY HACK
      PigeonMap.jsonStringifyInEffect++;
      return stringify(this);
    } finally {
      PigeonMap.jsonStringifyInEffect--;
    }
  }
  Uint8List toPgsonMessage() => new Pigeonson().serialize(this);
}
class PigeonStructMetadata extends NameSet {
  static extractNameSet(info) {
    return new List<String>.from(info["attributes"].map((e)=>e["name"]));
  }
  var slotTypes;
  var pigeonsonSlotTypes;
  var catalog;
  String type;
  PigeonStructMetadata(this.catalog, info) : super(extractNameSet(info)) { 
    this.type=info["type"];
    slotTypes=new PigeonMap(this);
    info["attributes"].forEach((a)=>slotTypes[a["name"]] = a["type"]);
    if (!isFast)
      print("this Pigeon is defective");
    _computePigeonsonTypes();
  }
  _computePigeonsonTypes() {
    var all=pigeonsonSlotTypes=[]; // array of complex type ids
    for (var t in slotTypes.values) {
      int q = _getTypeId(t);
      var leafType = _getLeafType(t);
      // we have to strip down generic type to check whether if the leaf is a pigeon
      var hasPigeonLeaf=_getTypeId(leafType)==_PIGEON;
      all.add(q);
      all.add(hasPigeonLeaf? leafType: null);
    }
  }
  _getLeafType(t) {
    int n=t.lastIndexOf("<");
    if (n<0) return t;
    while(t.endsWith(">")) t=t.substring(0,t.length-1);
    return t.substring(n+1);
    
  }
  _extractGeneric(t, prefix, code) {
    int end=t.lastIndexOf(">");
    String subtype=t.substring(prefix.length, end);
    return (_getTypeId(subtype)<<5)+code;
  }
  _getTypeId(t) {
    if (t=="int") return _INT;
    else if (t=="bool") return _BOOL;
    else if (t=="double") return _DOUBLE;
    else if (t=="String") return _STRING1;
    else if (t=="DateTime") return _DATE_TIME;
    else if (t=="List<int>") return _LIST_INT;
    else if (t=="List<String>") return _LIST_STRING;
    else if (t=="Uint8List") return _UINT8_LIST;
    else if (t=="Uint16List") return _UINT16_LIST;
    else if (t=="Uint32List") return _UINT32_LIST;
    else if (t=="Uint64List") return _UINT64_LIST;
    else if (t=="Int8List") return _INT8_LIST;
    else if (t=="Int16List") return _INT16_LIST;
    else if (t=="Int32List") return _INT32_LIST;
    else if (t=="Int64List") return _INT64_LIST;
    else if (t=="Float32List") return _FLOAT32_LIST;
    else if (t=="Float64List") return _FLOAT64_LIST;
    else if (t.startsWith("List<")) return _extractGeneric(t,"List<",_LIST_GENERIC);
    else if (t.startsWith("Map<String,")) return _extractGeneric(t,"Map<String",_MAP_GENERIC);
    else return _PIGEON;
    
  }
  getSlotType(key)=> slotTypes[key];
  getSlotIndex(key)=> _getIndex(key);
}
class SerializationMetadata {
  String type;
  Function _constructor;
  String childType;
  int category;
  
  SerializationMetadata(this.type,this._constructor,this.childType,this.category);
  toString() => "$type constructor=$_constructor child=$childType";
  constructor() => _constructor();
}
