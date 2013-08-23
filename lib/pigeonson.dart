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

class Pigeonson {

   Uint8List buf;
   int bufPos=0;
   int redZone;
   serialize(PigeonMap map) {
     buf=new Uint8List(1000);
     redZone=buf.lengthInBytes-20;
     writePigeon(map, map.nameSet.type);
     return new Uint8List.view(buf.buffer, 0, bufPos);
   }
   
   writePigeon(obj, objtype) {
     writeType(obj,_PIGEON);
     if (obj==null) return;
     var slotTypes=obj.nameSet.pigeonsonSlotTypes;
     var len=obj.nameSet.length;
     writeString(objtype);
     var iType=0, iSlot=0;
     while (iSlot<len) {
       var value=obj._getValue(iSlot++);
       var type=slotTypes[iType];
       var subtype=slotTypes[iType+1];
       iType+=2;
       writeGeneric(value, type, subtype);
     }
   }  
  writeType(value,type) {
    buf[bufPos++] = value==null? 0xFF : type;
  }  
  _writeInt(value) {
    buf[bufPos]=value;
    buf[bufPos+1]=value>>8;
    buf[bufPos+2]=value>>16;
    buf[bufPos+3]=value>>24;
    bufPos+=4;
  }
  writeInt(value) {
    writeType(value,_INT);
    if (value==null) return;
    _writeInt(value);
  }
  writeDouble(value) {
    writeType(value,_DOUBLE);
    if (value==null) return;
    throw "not implemented";
    //buf.setFloat64(bufPos,value,  Endianness.HOST_ENDIAN);
    //bufPos+=8; 
  } 
  writeBool(value) {
    writeType(value,_BOOL);
    if (value==null) return;
    buf[bufPos++]= value?1:0;
  }
  writeLength(length) {
    _writeInt(length); 
  }  
  writeString(value) {
    // optimistically, 1 byte per char
    int firstPos=bufPos;
    writeType(value,_STRING1);
    if (value==null) return;
    writeLength(value.length);
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
    writeType(value,_STRING2);
    writeLength(value.length);
    for (int i=0; i<value.length; i++) {
      var codeUnit=value.codeUnitAt(i);
      buf[bufPos]= codeUnit;
      buf[bufPos+1]= codeUnit>>8;
      bufPos+=2;
    }  
  } 
  writeList(value, type, subtype) {
    writeType(value,_LIST_GENERIC);
    if (value==null) return;
    writeLength(value.length);
    
    for (int i=0; i<value.length; i++)
      writeGeneric(value[i], type, subtype);
  }
  writeListInt(value) {
    writeType(value,_LIST_INT);
    if (value==null) return;
    writeLength(value.length);
    
    for (int i=0; i<value.length; i++)
      writeInt(value[i]);
  }
  writeListString(value) {
    writeType(value,_LIST_STRING);
    if (value==null) return;
    writeLength(value.length);
    
    for (int i=0; i<value.length; i++)
      writeString(value[i]);
  }
  writeMap(value, type, subtype) {
    writeType(value,_MAP_GENERIC);
    if (value==null) return;
    writeLength(value.length);
    value.forEach((k,v){ writeString(k); writeGeneric(v, type, subtype); });
  }
  writeGeneric(value, type, subtype) {
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
      default: throw "unsupported type $sel";
    }
    
  }
}
