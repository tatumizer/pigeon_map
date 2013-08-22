part of pigeon;


class PigeonStruct extends PigeonMap {
  PigeonStruct(metadata): super(metadata){ }
  _setValue(n,val){_values[n]=val;}
  _getValue(n)=>_values[n];
  String toJsonString() => stringify(this);
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
      var hasPigeonLeaf=_getTypeId(leafType)==_PIGEON;
      all.add(hasPigeonLeaf? -q: q);
      // we have to strip down generic type to check whether if the leaf is a pigeon
      if (hasPigeonLeaf)
        all.add(leafType);
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
    else if (t=="String") return _STRING;
    else if (t=="List<int>") return _LIST_INT;
    else if (t=="List<String>") return _LIST_STRING;
    else if (t.startsWith("List<")) return _extractGeneric(t,"List<",_LIST_GENERIC);
    else if (t.startsWith("Map<String,")) return _extractGeneric(t,"Map<String",_MAP_GENERIC);
    else return _PIGEON;
    
  }
  getSlotType(key)=> slotTypes[key];
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
