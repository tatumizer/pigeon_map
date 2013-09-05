part of pigeon;

const _INT =1;
const _BOOL =2;
const _DOUBLE =3;
const _STRING1 =4;
const _PIGEON =5;
const _LIST_GENERIC=6;
const _LIST_STRING =7;
const _LIST_INT =8;
const _MAP_GENERIC=9;
const _STRING2 =10;
const _DATE_TIME =11;
const _UINT8_LIST=12;
const _UINT16_LIST=13;
const _INT8_LIST=14;
const _INT16_LIST=15;
const _UINT32_LIST=16;
const _INT32_LIST=17;
const _UINT64_LIST=18;
const _INT64_LIST=19;
const _FLOAT32_LIST=20;
const _FLOAT64_LIST=21;

PigeonStruct pgsonMessage2Pigeon(bytes, type, catalog) => new PigeonsonParser(type, catalog).parse(bytes);
class Pigeonson {

  var buf;
  int bufPos=0;
  int bufLength;
  serialize(PigeonStruct map) {
    bufLength=1024;
    buf=new Uint8List(bufLength);
    bufPos=0;
    writePigeon(map, map.nameSet.type);
    var result=new Uint8List(bufPos);
    //return new Uint8List.view(buf.buffer, 0, bufPos);
    result.setRange(0, bufPos, buf, 0);
    return result;
  }
  _ensureSpace(extraLength) {
    while (bufPos+extraLength>bufLength) {
      var newBuf=new Uint8List(bufLength*2);
      newBuf.setRange(0, bufPos, buf, 0);
      buf=newBuf;
      bufLength=newBuf.length;
    }
  }
  writePigeon(obj, objtype) {
    _ensureSpace(8);
    writeType(_PIGEON);
    var slotTypes=obj.nameSet.pigeonsonSlotTypes;
    var len=obj.nameSet.length;
    writeString(objtype);
    var iType=0, iSlot=0;
    while (iSlot<len) {
      var value=obj.getValue(iSlot++);
      var type=slotTypes[iType];
      var subtype=slotTypes[iType+1];
      iType+=2;
      writeGeneric(value, type, subtype);
    }
  } 
  
  writeType(type) {
    buf[bufPos++] = type&0x1F;
  }
  
  writeInt(value) {
    _ensureSpace(5);
    writeType(_INT);
    if (value>((1<<30)-1)) throw "ints bigger than 1<<31-1 not supported yet";
    if (value<0) throw "negative ints not supported yet";
    buf[bufPos]=value;
    buf[bufPos+1]=value>>8;
    buf[bufPos+2]=value>>16;
    buf[bufPos+3]=value>>24;
    bufPos+=4;
  }
  writeDouble(value) {
    _ensureSpace(9);
    writeType(_DOUBLE);
    var byteData=new ByteData.view(buf.buffer, bufPos, 8);
    byteData.setFloat64(0, value, Endianness.LITTLE_ENDIAN);
    bufPos+=8; 
  } 
  writeBool(value) {
    _ensureSpace(2);
    writeType(_BOOL);
    buf[bufPos++]= value?1:0;
  }
  writeTypeAndLength(type, length) {
    buf[bufPos++]=type&0x1F;
    if (length<=255) {
      buf[bufPos++] = length;
      return;
    }
    buf[bufPos-1]|=0x80;
    buf[bufPos]=length;
    buf[bufPos+1]=length>>8;
    buf[bufPos+2]=length>>16;
    buf[bufPos+3]=length>>24;
    bufPos+=4;
    
  }  
  writeString(value) {
    // optimistically, 1 byte per char
    int firstPos=bufPos;
    _ensureSpace(8+value.length*2);
    writeTypeAndLength(_STRING1, value.length);
    bool isOneByteString=true;
    for (int i=0; i<value.length; i++) {
      var codeUnit=value.codeUnitAt(i);
      buf[bufPos++]= codeUnit;
      if ((codeUnit&0xFF00)!=0) {
        isOneByteString=false;
        break;
      }
    }
    if (isOneByteString)
      return;
    bufPos=firstPos;
    writeTypeAndLength(_STRING2, value.length);
    for (int i=0; i<value.length; i++) {
      var codeUnit=value.codeUnitAt(i);
      buf[bufPos]= codeUnit;
      buf[bufPos+1]= codeUnit>>8;
      bufPos+=2;
    }  
  } 
  writeList(value, type, subtype) {
    _ensureSpace(8);
    writeTypeAndLength(_LIST_GENERIC, value.length);
    for (int i=0; i<value.length; i++)
      writeGeneric(value[i], type, subtype);
  }
  writeListInt(value) {
    _ensureSpace(8+value.length*4);
    writeTypeAndLength(_LIST_INT, value.length);
    
    for (int i=0; i<value.length; i++) {
      var val=value[i];
      if (val>((1<<30)-1)) throw "ints bigger than 1<<31-1 not supported yet";
      if (val<0) throw "negative ints not supported yet";
      buf[bufPos]=val;
      buf[bufPos+1]=val>>8;
      buf[bufPos+2]=val>>16;
      buf[bufPos+3]=val>>24;
      bufPos+=4;
    }
  }
  writeUint8List(value) {
    _ensureSpace(8+value.length);
    writeTypeAndLength(_UINT8_LIST, value.length);
    for (int i=0; i<value.length; i++) {
      var val=value[i];
      buf[bufPos++]=val;
    }
  }
  writeInt8List(value) {
    _ensureSpace(8+value.length);
    writeTypeAndLength(_INT8_LIST, value.length);
    for (int i=0; i<value.length; i++) {
      var val=value[i];
      buf[bufPos++]=val;
    }
  }
  writeUint16List(value) {
    _ensureSpace(8+2*value.length);
    writeTypeAndLength(_UINT16_LIST, value.length);
    for (int i=0; i<value.length; i++) {
      var val=value[i];
      buf[bufPos]=val;
      buf[bufPos+1]=val>>8;
      bufPos+=2;
    }
  }
  writeInt16List(value) {
    _ensureSpace(8+2*value.length);
    writeTypeAndLength(_INT16_LIST, value.length);
    for (int i=0; i<value.length; i++) {
      var val=value[i];
      buf[bufPos]=val;
      buf[bufPos+1]=val>>8;
      bufPos+=2;
    }
  }
  writeUint32List(value) {
    _ensureSpace(8+4*value.length);
    writeTypeAndLength(_UINT32_LIST, value.length);
    for (int i=0; i<value.length; i++) {
      var val=value[i];
      buf[bufPos]=val;
      buf[bufPos+1]=val>>8;
      buf[bufPos+2]=val>>16;
      buf[bufPos+3]=val>>24;
      bufPos+=4;
    }
  }
  writeInt32List(value) {
    _ensureSpace(8+4*value.length);
    writeTypeAndLength(_INT32_LIST, value.length);
    for (int i=0; i<value.length; i++) {
      var val=value[i];
      buf[bufPos]=val;
      buf[bufPos+1]=val>>8;
      buf[bufPos+2]=val>>16;
      buf[bufPos+3]=val>>24;
      bufPos+=4;
    }
  }
  writeUint64List(value) {
    _ensureSpace(8+8*value.length);
    writeTypeAndLength(_UINT64_LIST, value.length);
    for (int i=0; i<value.length; i++) {
      
      var val=value[i]&0xFFFFFFFF;
      buf[bufPos]=val;
      buf[bufPos+1]=val>>8;
      buf[bufPos+2]=val>>16;
      buf[bufPos+3]=val>>24;
      bufPos+=4;
      val=(value[i]>>32)&0xFFFFFFFF;
      buf[bufPos]=val;
      buf[bufPos+1]=val>>8;
      buf[bufPos+2]=val>>16;
      buf[bufPos+3]=val>>24;
      bufPos+=4;
    }
  }
  writeFloat32List(value) {
    _ensureSpace(8+4*value.length);
    var byteData=new ByteData.view(buf.buffer, 0, buf.length);
    writeTypeAndLength(_FLOAT32_LIST, value.length);
    for (int i=0; i<value.length; i++) {
      byteData.setFloat32(bufPos, value[i], Endianness.LITTLE_ENDIAN);
      bufPos+=4; 
    }  
  }
  writeFloat64List(value) {
    _ensureSpace(8+8*value.length);
    var byteData=new ByteData.view(buf.buffer, 0, buf.length);
    writeTypeAndLength(_FLOAT64_LIST, value.length);
    for (int i=0; i<value.length; i++) {
      byteData.setFloat64(bufPos, value[i], Endianness.LITTLE_ENDIAN);
      bufPos+=8; 
    }  
  }
  writeInt64List(value) {
    _ensureSpace(8+8*value.length);
    writeTypeAndLength(_INT64_LIST, value.length);
    for (int i=0; i<value.length; i++) {
      var val=value[i]&0xFFFFFFFF;
      buf[bufPos]=val;
      buf[bufPos+1]=val>>8;
      buf[bufPos+2]=val>>16;
      buf[bufPos+3]=val>>24;
      bufPos+=4;
      val=(value[i]>>32)&0xFFFFFFFF;
      buf[bufPos]=val;
      buf[bufPos+1]=val>>8;
      buf[bufPos+2]=val>>16;
      buf[bufPos+3]=val>>24;
      bufPos+=4;
    }
  }
  writeListString(value) {
    _ensureSpace(8);
    writeTypeAndLength(_LIST_STRING, value.length);
    
    for (int i=0; i<value.length; i++)
      writeString(value[i]);
  }
  writeDateTime(value) {
    _ensureSpace(32);
    var str=value.toString();
    writeType(_DATE_TIME);
    writeString(str);
  }
  writeMap(value, type, subtype) {
    _ensureSpace(8);
    writeTypeAndLength(_MAP_GENERIC, value.length);
    value.forEach((k,v){ writeString(k); writeGeneric(v, type, subtype); });
  }
  writeGeneric(value, type, subtype) {
    if (value==null) {
      _ensureSpace(8);
      buf[bufPos++]=0; // type=0 is null
      return;
    }
    int sel = (type&0x1F);
    switch (sel) {
      case 0: return;
      case _INT: writeInt(value); break;
      case _DOUBLE: writeDouble(value); break;
      case _BOOL: writeBool(value); break;
      case _STRING1: writeString(value); break;
      case _LIST_GENERIC: writeList(value, type>>5, subtype); break;
      case _MAP_GENERIC: writeMap(value, type>>5, subtype); break;
      case _PIGEON: writePigeon(value, subtype); break;
      case _LIST_INT: writeListInt(value); break;
      case _LIST_STRING: writeListString(value); break;
      case _DATE_TIME: writeDateTime(value); break;
      case _UINT8_LIST: writeUint8List(value); break;
      case _UINT16_LIST: writeUint16List(value); break;
      case _UINT32_LIST: writeUint32List(value); break;
      case _UINT64_LIST: writeUint64List(value); break;
      case _INT8_LIST: writeInt8List(value); break;
      case _INT16_LIST: writeInt16List(value); break;
      case _INT32_LIST: writeInt32List(value); break;
      case _INT64_LIST: writeInt64List(value); break;
      case _FLOAT32_LIST: writeFloat32List(value); break;
      case _FLOAT64_LIST: writeFloat64List(value); break;
      default: throw "unsupported type $sel";
    }
    
  }
}
class PigeonsonParser {
  String rootType;
  var catalog;
  Uint8List buf;
  int bufPos;
  int bufLength;
  PigeonsonParser(this.rootType, this.catalog) {
    
  }
  PigeonStruct parse(bytes) {
    this.buf=bytes;
    this.bufPos=0;
    this.bufLength=bytes.length;
    var result = readGeneric(_PIGEON, rootType);
    if (bufPos!=bufLength) throw "unparsed data";
    return result;
  }
  PigeonStruct readPigeon(objtype) {
    var metadata=catalog[objtype];
    var container=metadata.constructor();
    //var slotTypes=container.nameSet.slotTypes;
    var pgSlotTypes=container.nameSet.pigeonsonSlotTypes;
    var names=container.nameSet.names;
    var len = names.length;
    var iType=0;
    bufPos++; // string type
    String type=readString();
    if (type != objtype) throw "type mismatch $type $objtype";
    for (int i=0; i<len; i++) {
      String key=names[i]; // for debugging only
      var type=pgSlotTypes[iType++];
      var subtype=pgSlotTypes[iType++];
      var value=readGeneric(type, subtype);
      container.setValue(i, value);
    }
    return container;
  }
  readType(expectedType) {
    int t=buf[bufPos++]&0x1F;
    int e=expectedType&0x1F;
    if (t==e || t==0) return t;
    if (t==_STRING2 && e==_STRING1) return t;
    throw "expected type $e got $t at $bufPos ${buf.sublist(bufPos-1)}";
  }
  readInt() {
    
    var n = buf[bufPos] | (buf[bufPos+1]<<8) | (buf[bufPos+2]<<16) | (buf[bufPos+3]<<24);
    bufPos+=4;
    return n;
  }
  readBool() {
    return buf[bufPos++]==1;
  }
  readDouble() {
    var byteData=new ByteData.view(buf.buffer, bufPos, 8);
    double d=byteData.getFloat64(0, Endianness.LITTLE_ENDIAN);
    bufPos+=8;
    return d;
    
  }
  int readLength() {
    int mode=buf[bufPos-1]&0x80;
    if (mode==0) return buf[bufPos++];
    return readInt();
  }
  readString() {
    int type=buf[bufPos-1]&0x1F;
    return type==_STRING1 ? readString1(): readString2();
  }
  readString1() {
    int len=readLength();
    var list=new List<int>(len);
    //for (int i=0; i<len; i++) {
    //  list[i]=buf[bufPos++];
    //}
    // this variant is much faster:
    for (int from=0, to=len-1; from<=to; from++, to--) {
      list[from]=buf[bufPos+from];
      list[to]=buf[bufPos+to];
    }
    bufPos+=len;
    
    return new String.fromCharCodes(list);
  }

  readString2() {
    int len=readLength();
    var list=new List<int>(len);
    for (int i=0; i<len; i++, bufPos+=2)
      list[i]=buf[bufPos]|(buf[bufPos+1]<<8);
    return new String.fromCharCodes(list);
  }
  readList(type, subtype) {
    int len=readLength();
    var list=[];
    for (int i=0; i<len; i++)
      list.add(readGeneric(type, subtype));
    return list;
  }
  readMap(type, subtype) {
    int len=readLength();
    var map={};
    for (int i=0; i<len; i++) {
      map[readString()]=readGeneric(type, subtype);
    }  
    return map;
  }
  readListInt() {
    throw "not implemented";
  }
  readUint8List() {
    int len=readLength();
    Uint8List list=new Uint8List(len);
    for (int i=0; i<len; i++) {
      list[i]=buf[bufPos++];
    }
    return list;
  }
  readUint16List() {
    int len=readLength();
    Uint16List list=new Uint16List(len);
    for (int i=0; i<len; i++) {
      list[i]=buf[bufPos]+(buf[bufPos+1]<<8);
      bufPos+=2;
    }
    return list;
  }
  readUint32List() {
    int len=readLength();
    Uint32List list=new Uint32List(len);
    for (int i=0; i<len; i++) {
      list[i]=buf[bufPos]+(buf[bufPos+1]<<8)+(buf[bufPos+2]<<16)+(buf[bufPos+3]<<24);
      bufPos+=4;
    }
    return list;
  }
  readUint64List() {
    int len=readLength();
    Uint64List list=new Uint64List(len);
    for (int i=0; i<len; i++) {
      var lo=buf[bufPos]+(buf[bufPos+1]<<8)+(buf[bufPos+2]<<16)+(buf[bufPos+3]<<24);
      bufPos+=4;
      var hi=buf[bufPos]+(buf[bufPos+1]<<8)+(buf[bufPos+2]<<16)+(buf[bufPos+3]<<24);
      bufPos+=4;
      list[i]=(hi<<32)+lo;
    }
    return list;
  }
  readInt8List() {
    int len=readLength();
    Int8List list=new Int8List(len);
    for (int i=0; i<len; i++) {
      var v=buf[bufPos++];
      list[i]=v>=128 ? v-256: v;
    }
    return list;
  }
  readInt16List() {
    int len=readLength();
    Int16List list=new Int16List(len);
    for (int i=0; i<len; i++) {
      var v=buf[bufPos]+(buf[bufPos+1]<<8);
      bufPos+=2;
      list[i]=v>=32768 ? v-65536: v;
    }
    return list;
  }
  readInt32List() {
    int len=readLength();
    Int32List list=new Int32List(len);
    for (int i=0; i<len; i++) {
      var v=buf[bufPos]+(buf[bufPos+1]<<8)+(buf[bufPos+2]<<16)+(buf[bufPos+3]<<24);
      bufPos+=4;
      list[i]=v>=2147483648 ? v-4294967296: v;
    }
    return list;
  }
  readInt64List() {
    int len=readLength();
    Int64List list=new Int64List(len);
    for (int i=0; i<len; i++) {
      var v=buf[bufPos]+(buf[bufPos+1]<<8)+(buf[bufPos+2]<<16)+(buf[bufPos+3]<<24);
      bufPos+=4;
      var w=buf[bufPos]+(buf[bufPos+1]<<8)+(buf[bufPos+2]<<16)+(buf[bufPos+3]<<24);
      bufPos+=4;
      var x=(w<<32)+v;
      list[i]=w>=2147483648 ? x-(1<<64): x;
    }
    return list;
  }
  readFloat32List() {
    int len=readLength();
    Float32List list=new Float32List(len);
    var byteData=new ByteData.view(buf.buffer, 0, buf.length);
    for (int i=0; i<len; i++) {
      list[i]=byteData.getFloat32(bufPos,Endianness.LITTLE_ENDIAN);
      bufPos+=4; 
    }  
    return list;
  }
  readFloat64List() {
    int len=readLength();
    Float64List list=new Float64List(len);
    var byteData=new ByteData.view(buf.buffer, 0, buf.length);
    for (int i=0; i<len; i++) {
      list[i]=byteData.getFloat64(bufPos,Endianness.LITTLE_ENDIAN);
      bufPos+=8; 
    }  
    return list;
  }
  readListString() {
    int len = readLength(); 
    var list=new List<String>(len);  
    for (int i=0; i<len; i++) {
       readType(_STRING1); 
       list[i]=readString();
    }    
    
  }
  readDateTime() {
    readType(_STRING1);
    var str=readString();
    return DateTime.parse(str);
  }
  readGeneric(type, subtype) {
    int t=readType(type);
    if (t==0) return null;
    switch (t) {
      case 0: return;
      case _INT: return readInt();
      case _DOUBLE: return readDouble();
      case _BOOL: return readBool();
      case _STRING1: return readString1(); 
      case _STRING2: return readString2(); 
      case _LIST_GENERIC: return readList(type>>5, subtype);
      case _MAP_GENERIC: return readMap(type>>5, subtype);
      case _PIGEON: return readPigeon(subtype);
      case _LIST_INT: return readListInt();
      case _LIST_STRING: return readListString();
      case _DATE_TIME: return readDateTime();
      case _UINT8_LIST: return readUint8List();
      case _UINT16_LIST: return readUint16List();
      case _UINT32_LIST: return readUint32List();
      case _UINT64_LIST: return readUint64List();
      case _INT8_LIST: return readInt8List();
      case _INT16_LIST: return readInt16List();
      case _INT32_LIST: return readInt32List();
      case _INT64_LIST: return readInt64List();
      case _FLOAT32_LIST: return readFloat32List();
      case _FLOAT64_LIST: return readFloat64List();
      default: throw "unsupported type $t";
    }
  }
}
