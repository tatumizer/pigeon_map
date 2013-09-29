

import "dart:io";
import "dart:collection";

// copy-paste from json_support!!!
// FIXIT!
const int _PIGEON_MAP_CAT=0;
const int _PRIMITIVE_CAT=1;
const int _LIST_CAT=2;
const int _GENERIC_MAP_CAT=3;

const int Prototype = 42;
String readSource(fileName) {
  return new File(fileName).readAsStringSync();
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
  String initValue;
  Attribute(this.name,this.type,this.initValue);
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
    var regexp2=new RegExp(r"\n\s*(\S+)\s+([^=;\s]+)\s*(=[^;]+)?;", multiLine:true);
    for (Match match in regexp2.allMatches(str)) {
      cd.attributes.add(new Attribute(match[2].trim(), match[1].trim(), match[3]==null?null:match[3].substring(1).trim()));
    }
    return cd;
  }
  toString() => "{'type': '${name}', 'attributes': $attributes}";
  sortAttributes() => attributes.sort((a, b) => a.name.compareTo(b.name));
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
  // these are quasi-primitives. Ugly, To be fixed later
  isPrimitiveType(type) => ["int","double","num","bool","DateTime", "String",""].contains(type) || 
      ["Uint8List", "Int8List", "Uint16List", "Int16List", "Uint32List", "Int32List", "Uint64List", "Int64List"].contains(type) ||
      ["Float32List", "Float64List"].contains(type);
  isPigeonMap(type) => true; // TODO: implement it
  stripEnclosure(String type, prefix) {
    int s=type.indexOf(prefix), e=type.lastIndexOf(">");
    return (s<0 || e<0) ? throw new ArgumentError("wrong type syntax $type") : type.substring(s+prefix.length, e);
  }
  var currentMetadata=new _SerializationMetadata();
  type=type.replaceAll(" ", "");
  currentMetadata.type=type;
  currentMetadata.constructor= 
      isPrimitiveType(type) && type.contains("Float") ?  "() => new List<double>()" :
      isPrimitiveType(type) && type.contains("List") ?  "() => new List<int>()" :
      isPrimitiveType(type)? "null" : "() => new $type()";
  currentMetadata.childType = 
      type.startsWith("List<") ? stripEnclosure(type,"List<") :
      type.startsWith("Map<String,") ? stripEnclosure(type,"Map<String,") : 
      type.contains("<") ? throw new ArgumentError("unsupported type $type") :
      isPrimitiveType(type) && type.contains("List") ? "int" :
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
  var catalogName;
  Generator(fileName) {
    var n = fileName.indexOf(".");
    catalogName="_${fileName.substring(0, n>0? n : fileName.length)}_pigeonTypeCatalog";;
  }
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
    classDef.sortAttributes();
    //var names=new List.from(classDef.attributes.map((a)=>a.name));
    //names.sort((a, b) => a.compareTo(b));
    //names=names.map((x)=>'"$x"');
    var className=classDef.name;
    addMetadata(classDef.name);
    for (Attribute attr in classDef.attributes) {
      addMetadata(attr.type);
    }
    
    
    sb.writeln("class $className extends PigeonStruct {");
    sb.writeln("  static final _metadata = new PigeonStructMetadata($catalogName,$classDef);");
    sb.writeln('  factory $className.parseJsonString(str) => jsonString2Pigeon(str, "$className",$catalogName);');
    sb.writeln('  factory $className.fromPgsonMessage(bytes) => pgsonMessage2Pigeon(bytes, "$className",$catalogName);');
    // compute list of default values for initialiation
    var defaultValues=[], refToDefaultValues="_defaultValues";
    bool hasExpression=false;
    for (Attribute attr in classDef.attributes) {
      var initValue=attr.initValue;
      hasExpression=hasExpression || (initValue!=null && initValue.contains("("));
      defaultValues.add(initValue);
    }
    if (!hasExpression) {
      sb.writeln("  static final _defaultValues=$defaultValues;");
    } else {
      sb.writeln("  static _defaultValues()=>$defaultValues;");
      refToDefaultValues+="()";
    }
    sb.writeln("  $className() : super(_metadata,$refToDefaultValues) {}");
    int i=0;
    for (Attribute attr in classDef.attributes) {
      
      sb.writeln("  ${attr.type} get ${attr.name} => getValue($i);");
      sb.writeln("  void set ${attr.name}(${attr.type} val) => setValue($i,val);");
      i++;
    }
    sb.writeln("}");
  }
  toString() => "final ${catalogName} = ${catalogToString()}\n$sb";
}
generate(String fileName) {
  throw "DEPRECATED! Use 'preprocess'method instead- see README"; 
}
preprocess([String srcFileName]) {
  if (srcFileName==null) srcFileName=Platform.script;
  srcFileName=srcFileName.replaceAll("\\","/");
  String source=readSource(srcFileName);
  if (!source.startsWith("//>")) throw "first line should be //>destinationFileName";
  int n=srcFileName.lastIndexOf("/");
  String dirName=".";
  if (n>=0) dirName=srcFileName.substring(0, n); 
  
  int eolIndex=source.indexOf("\n");
  var dstFileName=(dirName +"/"+ source.substring(3, eolIndex).trim()).replaceAll("\\","/");
  print("preprocessing $srcFileName ->  $dstFileName");
  if (dstFileName.contains("proto_")) throw "output file name $dstFileName is probably a mistake"; 
  //new File("c:/temp/newfile.txt").writeAsStringSync(source);
  var m = dstFileName.lastIndexOf("/");
  var simpleFileName = dstFileName.substring(m>=0?m+1 : 0);
  var gen=new Generator(simpleFileName);
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
  var lines=newSource.toString().split("\n");
  var newLines=[];
  newLines.add("//generated from prototype file $srcFileName");
  lines.forEach((line) {
    if (line.contains("//-") || line.contains("//>")) return;
    if (line.contains("//+")) line=line.replaceAll("//+","");
    newLines.add(line);
  });
  new File(dstFileName).writeAsStringSync(newLines.join("\n"));
}
