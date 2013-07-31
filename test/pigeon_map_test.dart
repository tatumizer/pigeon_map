// this test was shamelessly stolen from dart native library and modified
// Just in case, here's original copyright:
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// A subtest of the larger MapTest. Will eliminate once the full
// test is running.

import "package:unittest/unittest.dart";
import "dart:math";
import "../lib/pigeon_map.dart";

class MapTest {

  static void testDeletedElement(Map map) {
    map.clear();
    for (int i = 0; i < 100; i++) {
      map["value1"] = 2;
      expect(1, equals(map.length));
      int x = map.remove("value1");
      expect(2, equals(x));
      expect(0, equals(map.length));
    }
    expect(0, map.length);
    for (int i = 0; i < 100; i++) {
      String ikey="value${i%8+1}";
      map[ikey] = 2;
      expect(1, equals(map.length));
      int x = map.remove("value105");
      expect(null, equals(x));
      expect(1, equals(map.length));
      x = map.remove(ikey);
      expect(2, equals(x));
      expect(0, equals(map.length));
    }
    expect(0, equals(map.length));
    map.remove("value105");
  }
  
  static void test(Map map) {
    testDeletedElement(map);
    testMap(map, "value1", "value2", "value3", "value4", "value5",
            "value6", "value7", conflictingKey);
    map.clear();
    testMap(map, "value1", "value2", "value3", "value4", "value5",
            "value6", "value7", "value8");
  }

  static void testMap(Map map, key1, key2, key3, key4, key5, key6, key7, key8) {
     int value1 = 10;
     int value2 = 20;
     int value3 = 30;
     int value4 = 40;
     int value5 = 50;
     int value6 = 60;
     int value7 = 70;
     int value8 = 80;

     expect(0, map.length);

     map[key1] = value1;
     expect(value1, equals(map[key1]));
     map[key1] = value2;
     expect(false, equals(map.containsKey(key2)));
     expect(1, equals(map.length));

     map[key1] = value1;
     expect(value1, equals(map[key1]));
     // Add enough entries to make sure the table grows.
     map[key2] = value2;
     expect(value2, equals(map[key2]));
     expect(2, equals(map.length));
     map[key3] = value3;
     expect(value2, equals(map[key2]));
     expect(value3, equals(map[key3]));
     map[key4] = value4;
     expect(value3, equals(map[key3]));
     expect(value4, equals(map[key4]));
     map[key5] = value5;
     expect(value4, equals(map[key4]));
     expect(value5, equals(map[key5]));
     map[key6] = value6;
     expect(value5, equals(map[key5]));
     expect(value6, equals(map[key6]));
     map[key7] = value7;
     expect(value6, equals(map[key6]));
     expect(value7, equals(map[key7]));
     map[key8] = value8;
     expect(value1, equals(map[key1]));
     expect(value2, equals(map[key2]));
     expect(value3, equals(map[key3]));
     expect(value4, equals(map[key4]));
     expect(value5, equals(map[key5]));
     expect(value6, equals(map[key6]));
     expect(value7, equals(map[key7]));
     expect(value8, equals(map[key8]));
     expect(8, equals(map.length));

     map.remove(key4);
     expect(false, map.containsKey(key4));
     expect(7, map.length);

     // Test clearing the table.
     map.clear();
     expect(0, equals(map.length));
     expect(false, equals(map.containsKey(key1)));
     expect(false, equals(map.containsKey(key2)));
     expect(false, equals(map.containsKey(key3)));
     expect(false, equals(map.containsKey(key4)));
     expect(false, equals(map.containsKey(key5)));
     expect(false, equals(map.containsKey(key6)));
     expect(false, equals(map.containsKey(key7)));
     expect(false, equals(map.containsKey(key8)));

     // Test adding and removing again.
     map[key1] = value1;
     expect(value1, equals(map[key1]));
     expect(1, equals(map.length));
     map[key2] = value2;
     expect(value2, equals(map[key2]));
     expect(2, equals(map.length));
     map[key3] = value3;
     expect(value3, equals(map[key3]));
     map.remove(key3);
     expect(2, equals(map.length));
     map[key4] = value4;
     expect(value4, equals(map[key4]));
     map.remove(key4);
     expect(2, equals(map.length));
     map[key5] = value5;
     expect(value5, equals(map[key5]));
     map.remove(key5);
     expect(2, equals(map.length));
     map[key6] = value6;
     expect(value6, equals(map[key6]));
     map.remove(key6);
     expect(2, equals(map.length));
     map[key7] = value7;
     expect(value7, equals(map[key7]));
     map.remove(key7);
     expect(2, equals(map.length));
     map[key8] = value8;
     expect(value8, equals(map[key8]));
     map.remove(key8);
     expect(2, equals(map.length));

     expect(true, equals(map.containsKey(key1)));
     expect(true, equals(map.containsValue(value1)));

     // Test Map.forEach.
     Map other_map = newMap();
     void testForEachMap(key, value) {
       other_map[key] = value;
     }
     map.forEach(testForEachMap);
     expect(true, equals(other_map.containsKey(key1)));
     expect(true, equals(other_map.containsKey(key2)));
     expect(true, equals(other_map.containsValue(value1)));
     expect(true, equals(other_map.containsValue(value2)));
     expect(2, equals(other_map.length));

     other_map.clear();
     expect(0, equals(other_map.length));

     // Test Collection.keys.
     void testForEachCollection(value) {
       other_map[value] = value;
     }
     Iterable keys = map.keys;
     keys.forEach(testForEachCollection);
     expect(true, equals(other_map.containsKey(key1)));
     expect(true, equals(other_map.containsKey(key2)));
     expect(true, equals(other_map.containsValue(key1)));
     expect(true, equals(other_map.containsValue(key2)));
     expect(true, equals(!other_map.containsKey("foo")));
     expect(true, equals(!other_map.containsKey("bar")));
     expect(true, equals(!other_map.containsValue(value1)));
     expect(true, equals(!other_map.containsValue(value2)));
     expect(2, equals(other_map.length));
     other_map.clear();
     expect(0, equals(other_map.length));

     // Test Collection.values.
     Iterable values = map.values.map((v)=>"value${v~/10}");
     values.forEach(testForEachCollection);
     expect(true, equals(other_map.containsKey(key1)));
     expect(true, equals(other_map.containsKey(key2)));
     expect(true, equals(other_map.containsValue(key1)));
     expect(true, equals(other_map.containsValue(key2)));
     expect(true, equals(other_map.containsKey("value1")));
     expect(true, equals(other_map.containsKey("value2")));
     expect(true, equals(other_map.containsValue("value1")));
     expect(true, equals(other_map.containsValue("value2")));
     expect(2, equals(other_map.length));
     other_map.clear();
     expect(0, equals(other_map.length));

     // Test Map.putIfAbsent.
     map.clear();
     expect(false, equals(map.containsKey(key1)));
     map.putIfAbsent(key1, () => 10);
     expect(true, equals(map.containsKey(key1)));
     expect(10, equals(map[key1]));
     expect(10,
            equals(map.putIfAbsent(key1, () => 11)));
   }

  static testKeys(Map map) {
    map["value1"] = 101;
    map["value2"] = 102;
    Iterable k = map.keys;
    expect(2, equals(k.length));
    Iterable v = map.values;
    expect(2, equals(v.length));
    expect(true, equals(map.containsValue(101)));
    expect(true, equals(map.containsValue(102)));
    expect(false, equals(map.containsValue(103)));
  }
  static String conflictingKey=() {
    int h="value1".hashCode;
    for (int i=0; i<100000; i++) {
      var s=getRandomString(8);
      if ((s.hashCode&255)==(h&255))
        return s;
    }
    throw "cannot find conflicting hashCode";
  }();
  static String getRandomString(int len) {
    var list=new List<int>(len);
    var r=new Random();
    for (int i=0; i<len; i++) 
      list[i]=32+r.nextInt(64);
    return new String.fromCharCodes(list);
  }
  static PigeonMap newMap() {
    NameSet nameSet = new NameSet(["value1", "value2", "value3", "value4", "value5",
            "value6", "value7", "value8", conflictingKey]);
    nameSet.setSearchModeForTest(2);
    return new PigeonMap(nameSet);
  }
  static testMain() {
    test(newMap());
    testKeys(newMap());
  }
}


main() {
  // right now, there's a bug in editor that hangs on exceptions
  // need to hangle them explicitly
  try {
    MapTest.testMain();
  } catch (e, s) {
    print(e);
    print(s);
  }
}
