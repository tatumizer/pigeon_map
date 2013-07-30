// we benchmark only the case here hashCodes of all keys are precomputed. This saves the same amount of time in pigeon map
// and native map. However, the ratio of timings would obviously be different if each had to compute hash code (pigeon will still be faster, but
// less dramatically so).

import "../lib/pigeon_map.dart";
import "dart:typed_data";
import "dart:math";

String getRandomString(int len) {
  var list=new List<int>(len);
  var r=new Random();
  for (int i=0; i<len; i++) 
    list[i]=32+r.nextInt(64);
  return new String.fromCharCodes(list);
}
List<String> getRandomNames(int n, int len) {
  var list=new List<String>(n);
  for (int i=0; i<n; i++) list[i]=getRandomString(len);
  return list;
}
checkSuccessRate(iterations, nNames, nameLength) {
  int failCount=0;
  for (int i=0; i<iterations; i++) {
    var names=getRandomNames(nNames, nameLength);
    var map = new PigeonMap(new NameSet(names));
    failCount+=map.isFast? 0 :1;
  }
  print("$failCount failures out of $iterations");
}
int searchMode=2;
_getPigeonMap(names) {
  var nameSet = new NameSet(names);
  nameSet.setSearchModeForTest(searchMode);
  return new PigeonMap(nameSet);
}
testMapWriteRead(iterations, nNames, nameLength, opt) {
  var names=getRandomNames(nNames, nameLength);
  var map = opt? _getPigeonMap(names) : new Map();
  
  int x = 0;
  for (int i=0; i<iterations; i++) {
    for (int j=0; j<nNames; j++) {
      var w=names[j];
      map[w]=w;
      x|=map[w].length;
    }
    map.clear();
  }
  return x;
}

testNewMapWriteRead(iterations, nNames, nameLength, opt) {
  var names=getRandomNames(nNames, nameLength);
  var nameSet = new NameSet(names);
  var map = opt? new PigeonMap(nameSet) : new Map();
  int x = 0;
  for (int i=0; i<iterations; i++) {
    for (int j=0; j<nNames; j++) {
      var w=names[j];
      map[w]=w;
      x|=map[w].length;
    }
    map = opt? new PigeonMap(nameSet) : new Map();
  }
  return x;
}
testEmptyLoop(iterations, _a, _b, _c) {
  for (int i=0; i<iterations; i++) {
    for (int j=0; j<256; j++)
      ;
  } 
  return 0;
}  
run(func, name, nNames, nameLength, opt) {
  const int ITERATIONS=1000000;
  var iter=[100, 1000, 10000, ITERATIONS];
  var tm;
  int x=0;
  for (int i=0; i<4; i++) {
    var w = new Stopwatch()..start();
    x|=func(iter[i], nNames, nameLength, opt); // warmups
    tm=w.elapsedMilliseconds;
    w.stop();
  }
  print("$name nKeys=$nNames keyLen=$nameLength : ${tm}ms");
}

main() {
  //checkSuccessRate(100000, 16, 16);
  //checkSuccessRate(100000, 32, 16);
  //checkSuccessRate(100000, 16, 12);
  run(testEmptyLoop, "Warmup", 0, 0, 0);
  run(testEmptyLoop, "Warmup", 0, 0, 0);
  run(testEmptyLoop, "Warmup", 0, 0, 0);
  run(testEmptyLoop, "Warmup", 0, 0, 0);
  
  print("reusing old map (calling clear before each iteration):");
  run (testMapWriteRead,"MapWriteRead(Perfect)", 8, 16, true);  
  run (testMapWriteRead,"MapWriteRead(Native)", 8, 16, false);  
  run (testMapWriteRead,"MapWriteRead(Perfect)", 16, 8, true);  
  run (testMapWriteRead,"MapWriteRead(Native)", 16, 8, false);  
  run (testMapWriteRead,"MapWriteRead(Perfect)", 16, 16, true);  
  run (testMapWriteRead,"MapWriteRead(Native)", 16, 16, false);  
  run (testMapWriteRead,"MapWriteRead(Perfect)", 32, 16, true);  
  run (testMapWriteRead,"MapWriteRead(Native)", 32, 16, false);  

  print("no map reuse (calling new before each iteration):");
  run (testNewMapWriteRead,"NewMapWriteRead(Perfect)", 8, 16, true);  
  run (testNewMapWriteRead,"NewMapWriteRead(Native)", 8, 16, false);  
  run (testNewMapWriteRead,"NewMapWriteRead(Perfect)", 16, 8, true);  
  run (testNewMapWriteRead,"NewMapWriteRead(Native)", 16, 8, false);  
  run (testNewMapWriteRead,"NewMapWriteRead(Perfect)", 16, 16, true);  
  run (testNewMapWriteRead,"NewMapWriteRead(Native)", 16, 16, false);  
  run (testNewMapWriteRead,"NewMapWriteRead(Perfect)", 32, 16, true);  
  run (testNewMapWriteRead,"NewMapWriteRead(Native)", 32, 16, false);  
  
//  // once we are at it, test how native map behaves by itself on larger key sets
//  print("testing native map only on larger values");
//  run (testMapWriteRead,"MapWriteRead(Native)", 64, 16, false);  
//  run (testMapWriteRead,"MapWriteRead(Native)", 128, 16, false);
//  
//  print("testing cutoff for linear/binary/hash modes");
//  for (searchMode=1; searchMode<=2; searchMode++) {
//    for (int n=2; n<=14; n++) {
//      run (testMapWriteRead,"MapWriteRead(Perfect)", n, 16, true); 
//      run (testMapWriteRead,"MapWriteRead(Native)", n, 16, false);  
//    }
//    run (testMapWriteRead,"MapWriteRead(Perfect)", 64, 16, true);  
//    run (testMapWriteRead,"MapWriteRead(Native)", 64, 16, false);  
//  }
  
}