
part of pigeon;
const Prototype = 42;
String readSource() {
  return new File(Platform.script).readAsStringSync();
}
void writeSource(str) {
  new File(Platform.script).writeAsStringSync(str);
}
class Slice {
  String str;
  int start;
  int end;
  Slice(this.start,this.end, this.str);
  
  String toString() => str;
}
class Attribute {
  String type;
  String name;
  Attribute(this.name,this.type);
  toString() => "{'type': '$type', 'name': '$name'}";
}
class Proto {
  String className;
  var attributes = new List<Attribute>();
  
}
class ClassDef {
  String name;
  List<Attribute> attributes=new List<Attribute>();
  static ClassDef parse(str) {
    var cd=new ClassDef();
    var regexp1=new RegExp(r"class\s+([\w\d_]+)\s*{");
    cd.name=regexp1.firstMatch(str)[1];
    str=str.substring(regexp1.firstMatch(str)[0].length+1);
    var regexp2=new RegExp(r"\n\s*(\S+)\s+([^;]+);", multiLine:true);
    for (Match match in regexp2.allMatches(str)) {
      cd.attributes.add(new Attribute(match[2], match[1]));
    }
    return cd;
  }
  toString() => "{'type': '${name}', 'attributes': $attributes}";
}
class _SerializationMetadata {
  String type;
  String constructor;
  String childType;
  int category;
  
  toString() => "$type constructor=$constructor child=$childType";
}
var _pigeonTypeCatalog = new LinkedHashMap<String,_SerializationMetadata>();
List<Slice> findPrototypes(str) {
  var slices=new List<Slice>();
  var regexp=new RegExp(r"@Prototype\s+class\s+\S+\s*\{[^\}]+\}", multiLine:true);
  for (Match match in regexp.allMatches(str)) {
    Slice s=new Slice(match.start, match.end, match[0]);
    slices.add(s);
  }
  return slices;
}
addMetadata(String type) {
  isPrimitiveType(type) => ["int","double","num","bool","String",""].contains(type);
  isPigeonMap(type) => true; // TODO: implement it
  stripEnclosure(String type, prefix) {
    int s=type.indexOf(prefix), e=type.lastIndexOf(">");
    return (s<0 || e<0) ? throw new ArgumentError("wrong type syntax $type") : type.substring(s+prefix.length, e);
  }
  var currentMetadata=new _SerializationMetadata();
  type=type.replaceAll(" ", "");
  currentMetadata.type=type;
  currentMetadata.constructor= isPrimitiveType(type)? "null" : "() => new $type()";
  currentMetadata.childType = 
      type.startsWith("List<") ? stripEnclosure(type,"List<") :
      type.startsWith("Map<String,") ? stripEnclosure(type,"Map<String,") : 
      type.contains("<") ? throw new ArgumentError("unsupported type $type") :
      isPrimitiveType(type) ? null :   
      isPigeonMap(type) ? null : throw new ArgumentError("unsupported type $type");
  currentMetadata.category =   
      type.startsWith("List<") ? _LIST_CAT :
      type.startsWith("Map<String,") ? _GENERIC_MAP_CAT : 
      isPrimitiveType(type) ? _PRIMITIVE_CAT : 
      isPigeonMap(type) ? _PIGEON_MAP_CAT : throw new ArgumentError("unsupported type $type");
  _pigeonTypeCatalog[type]=currentMetadata;    
  if (currentMetadata.childType != null) 
    addMetadata(currentMetadata.childType);
}

class Generator {
  var sb=new StringBuffer();
  catalogToString() {
    
    var sb = new StringBuffer();
    sb.writeln("{");
    _pigeonTypeCatalog.forEach((k,v) {
      sb.writeln('  "$k" : new SerializationMetadata("${v.type}", ${v.constructor}, "${v.childType}", ${v.category}),');
    });
    sb.writeln("};");
    return sb.toString().replaceAll('"null"',"null");
  }
  addClass(ClassDef classDef) {
    var names=new List.from(classDef.attributes.map((a)=>a.name));
    names.sort((a, b) => a.compareTo(b));
    names=names.map((x)=>'"$x"');
    var className=classDef.name;
    addMetadata(classDef.name);
    for (Attribute attr in classDef.attributes) {
      addMetadata(attr.type);
    }
    
    sb.writeln("var _metadata_${className} = new PigeonStructMetadata(pigeonTypeCatalog,$classDef);");
    sb.writeln("class $className extends PigeonStruct {");

    sb.writeln('  factory $className.parseJsonString(str) => jsonString2Pigeon(str, "$className",pigeonTypeCatalog);');
    
    sb.writeln("  $className() : super(_metadata_${className}) {}");
    int i=0;
    for (Attribute attr in classDef.attributes) {
      
      sb.writeln("  ${attr.type} get ${attr.name} => _getValue($i);");
      sb.writeln("  void set ${attr.name}(${attr.type} val) => _setValue($i,val);");
      i++;
    }
    sb.writeln("}");
  }
  toString() => "var pigeonTypeCatalog = ${catalogToString()}\n$sb";
}

generate(fileName) {
  String source=readSource();
  //new File("c:/temp/newfile.txt").writeAsStringSync(source);
  var gen=new Generator();
  List<Slice> protos = findPrototypes(source); 
  for (Slice proto in protos) {
     var classDef=ClassDef.parse(proto.str);  
     gen.addClass(classDef);
  }
  //print(gen);
  var newSource = new StringBuffer();
  int lastPos=0;
  for (var proto in protos) {
    newSource.write(source.substring(lastPos, proto.start));
    if (lastPos==0)
      newSource.write(gen.toString());
    lastPos=proto.end;
  }
  newSource.write(source.substring(lastPos));
  new File(fileName).writeAsStringSync(newSource.toString());
}
