Overview
========
Pigeon library provides implementation of memory- and performance-efficient map-backed data structures. These structures are efficiently serializable with  no extra 
boilerplate. Serialization doesn't rely on reflection and withstands dart2javascript conversion and minification.

Library consists of the following components:

1. pigeon map: something that looks like a map, but stores values in array of slots (much more efficient than standard map memory/performance-wise
2. pigeon struct - inherits pigeon map, but adds getters/setters for attributes so it looks like a normal class. In other words, pigeon struct is something that looks 
like a struct and a map at the same time. 
3. various serializers/deserializers (JSON and Pigeonson are supported in this version)
4. generator of pigeon structs. Very simple one. All it does is this: you write

```javascript
@Prototype
class Person {
  String firstName;
  String lastName;
  int yearOfBirth;
}
```

and program generates something like this:

```javascript
class Person extends PigeonStruct {
  Person() {/*...*/} 
  String get firstName => getValue(0);
  void set firstName(val) => setValue(0,val);
  String get lastName => getValue(1);
  void set lastName(val) => setValue(1,val);
  int get yearOfBirth => getValue(2);
  void set yearOfBirth(val) => setValue(2,val);
}
```

Pigeon Map
==========

Pigeon map is an implementation of standard Map interface for the case of attribute names known in advance.
E.g. if you are going to produce a lot of maps with just 3 attributes: "foo", "bar" and "baz",
you do the following:

```javascript

var nameSet = new NameSet(["foo", "bar", "baz"]);
var list = [];
for (int i=0; i<=1000; i++) { 
  var map = new PigeonMap(nameSet);  // same name set
  map["foo"]=i;
  map["bar"]="abcde"
  map["baz"]=true;
  list.add(map);
}
```

PigeonMap internally allocates an array for 3 values, which is as memory-efficient as it gets.
Though performance is not an immediate goal, pigeon map in fact faster than standard native map (by as much as 3 times) - mostly because the overhead of 
map creation is very low for PigeonMap, and very high for native map. But even ignoring map creation time, PigeonMap is faster by 20-30%. 

Note that PigeonMap implements standard map interface. E.g. you can put only "foo" value in a map:

```javascript
var map = new PigeonMap(nameSet);
map["foo"]=1;

print(map.containsKey("bar")); // prints false.
print(map.length); // prints 1
```

How it works
============

Obviously, if we find the function such that f("foo") = 0, f("bar") = 1, f("baz") =2, the problem is solved.
Such function is "officially" called minimal perfect hash (see wikipedia). Minimal perfect hash can be obtained in a trivial manner by auxiliary hashmap
that maps keys to positions directly. However, such method will be obviously slower than native hashMap (because it will use native hashMap as a subroutine).
 
To find a better hash function, we can first obtain "real" 31-bit hashCodes of the words from given set. These codes are almost always unique for the small set (see "birthday problem" in wikipedia).
If not, algo switches into slow mode (binary search).

Now let's consider an abstract problem. We have an array of N unique 31-bit numbers h[i], and we want to find a function f such as
f(h[i]) produces unique (!) values in the range, say, 0..255. Obvious way to do that is just to take 8 bits 0..7 from each h[i].
If they are unique, we are done. If not, we try bits 1..8, then 2..9 etc - after a number of attempts, we have a good chance to succeed (see below)

Now that we have unique small hashCodes, the task is trivial.

Suppose sh("foo")=0x15, sh("bar")=0xFE, sh("baz") = 0x2A, where sh(x) is a "small hash code".

We create a table of 256 entries initialized to -1, and set

table[0x15]=0; table[0xFE]=1; table[0x2A]=2

which is what we tried to achieve.

In general, the size of the table should be approximately a square of the number of names in the set (see wikipedia). (Consequently, bit size of small hash map is a
log2 of table size). During initialization, NameSet counts names, takes a square of this count, rounds up to nearest power of 2  - this is the table size. I found experimentally that with this choice of table size, 
the chance of NOT finding a mapping is about 1/10000.

One notable property of PigeonMaps is that the keys in NameSet and keys used for *reading* data are normally constant strings.
For constant strings, expenses for hashCode calculations are essentially zero, and comparison for equality is satisfied by identity check.
Since hashCode and equality is all that's needed here, and collisions are prevented, finding a slot for value boils down to shift and mask in typical case.
(Please refer to the source code for details, otherwise it sounds cryptic)

NOTE: PigeonMap supports up to 64 keys for NameSet. It's enough for most practical purposes. You can have as many NameSets as you wish. 

Use cases
=========

Example: you execute sql statement
select foo, bar, baz, name, address from customer;

Database driver has to return result set somehow (it can be large!)
PigeonMap is a solution: create (automatically, by parsing "select" statement or retrieving ResultSetMetadata) name set containing 5 attributes (foo, bar, baz, name, address) and return array of PigeonMaps - they are memory/performance efficient.
The main benefit of using PigeonMaps instead of regular maps: they use significantly less memory.

Other use cases involve PigeonStructs.

Pigeon Struct
=============

PigeonStruct is extension of PigeonMap that provides getters/setters for attributes, so it looks like a hybrid between map and struct. Good for value objects, 
DAO, DTO (those terms mean more or less the same).

Code generation is simple: create a file containing prototypes of your data structures (say, proto_person.dart), and main function that calls "preprocess":

```javascript
//>person.dart  // first line should start with //> 
import '../lib/generator.dart'; //-
//+ import '../lib/pigeon.dart';
@Prototype
class Person {
  String firstName;
  String lastName;
  int yearOfBirth;
}
// other @Prototype classes
main() {        //- lines that contain //- will not be copied into generated file
  preprocess(); //-
}               //-
```

Press CTRL/R to run it - generator will scan the file and generate another file here all @Prototypes are replaced by generated code. You file otherwise may contain
any code you like - it will be copied into generated file as is (only @Prototypes get replaced)
(Alternatively, you can include generation logic in build.dart -see example below).

Important rules:

1. Prototype file should have prefix "proto_" in its name to be recognized by build.dart

2. First line should be "//>" directive. e.g `//>person.dart` or `//>../generated/person.dart` or whatever.  

3. Lines that contain "//-" will not be copied into generated file

4. Lines that start with "//+" will be stripped of "//+" and copied into generated file. E.g., if generated file is supposed to be part of library,
include line `//+part of mylibrary;` in the source
  
Please see more complex example in test/proto_media.dart. When you run this file, it generates test/media.dart.

Since generated object inherits from PigeonMap, all properties of PigeonMap hold.

NOTE: program also generates small amount of metadata for mapping of struct keys to their types. Since keys are the same as attribute names, program uses another 
PigeonMap to efficiently store metadata.

JSON Serialization
==================

Since PigeonStruct is map-backed, all serializers that normally work for maps will be able to work with PigeonMaps and PigeonStructs.
For deserialization, there's additional problem of creating correct PigeonStruct types (e.g. object of type Person while deserializing encoded Person).
Currently implementation supports JSON serialization both ways without any extra boilerplate. Program currently supports the following data types defined
recursively:

- primitive types (int, double, bool, String) are supported

- if T - supported type, then `List<T>` and `Map<String,T>` are supported types

- typed_data classes are supported (Uint8List, Int8List, Uint16List, Int16List, Uint32List, Int32List, Uint64List, Int64List, 
Float32List, Float64List)

- class extending PigeonStruct is supported if all its attribute types are supported.

- DateTime is supported, but only as an attribute of PigeonStruct (this means that if you have, say, List<DateTime>, it won't work). This limitation is due to insufficient support
of custom classes in current JSON parser. (dart team agreed to fix it, but we don't know when).

 
To get JSON string, simply call toJsonString() method of any PigeonStruct. To parse JSON string, call `new Person.fromJsonString(str)`.
Performance of JSON toJsonString/fromJSONString is the same as for default JSON library, but you get typed structures for the same money.
(The reason why PigeonMaps are not faster for JSON is this: 95% of time is spent in parsing proper, not in map read/write) 
  
Binary serialization
====================

There's (very) fast binary serializer and (not so fast) deserializer. They support format similar to Bson, but optimized for pigeon structs.

Example of invocation
```javascript
bytes = person.toPgsonMessage();  // "bytes" is Uint8List
new Person.fromPgsonMessage(bytes);
```

Deserializer is 1.6-1.7 times slower than serializer (this ratio is normal for serializers).

Compared with corresponding Json methods discussed above, Pgson is faster by factor of 6-8(*) in serialization, and by factor of 2.5 in deserialization.
Generated byte message is approx. 2 times shorter than corresponding Json string.

(*) depends on type of processor and other factors


Example of build.dart
=====================

If you don't like pressing CTRL/R for generation, you can include preprocessing into build.dart. This script will be called each time you save your prototype file. Here is an example of build.dart

```javascript
import 'dart:io';
import "lib/generator.dart";

void main() {
  for (String arg in new Options().arguments) {
    if (arg.startsWith('--changed=')) {
      String fileName = arg.substring('--changed='.length);
      if (fileName.contains("proto_")) {
         preprocess(fileName);        
      }
    }
  }
}
```




 


  