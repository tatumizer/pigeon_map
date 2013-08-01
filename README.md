Overview
========

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
If they are unqiue, we are done. If not, we try bits 1..8, then 2..9 etc - after a number of attempts, we have a good chance to succeed (see below)

Now that we have unique small hashCodes, the task is trivial.

Suppose sh("foo")=0x15, sh("bar")=0xFE, sh("baz") = 0x2A, whene sh(x) is a "small hash code".

We create a table of 256 entries initialized to -1, and set

table[0x15]=0; table[0xFE]=1; table[0x2A]=2

which is what we tried to achieve.

In general, the size of the table should be approximately a square of the number of names in the set (see wikipedia). (Consequently, bit size of small hash map is a
log2 of table size). During initialization, NameSet counts names, takes a square of this count, rounds up to nearest power of 2  - this is the table size. I found experimentally that with this choice of table size, 
the chance of NOT finding a mapping is about 1/10000.

One notable property of PigeonMaps is that the keys in NameSet and keys used for *reading* data are normally constant strings.
For constant strings, expenses for hashCode calculations are essentially zero, and comparison for equality is satisfied by identity check.
Since hashCode and equality is all that's needed here, and collisions are prevented, finding a slot for value bois down to shift and mask in typical case.
(Please refer to the source code for details, otherwise it sounds cryptic)

Limitations
===========

PigeonMap supports up to 64 keys for NameSet. It's enough for most practical purposes. You can have as many NameSets as you wish. 

Use cases
=========

PigeonMaps are good for keeping arrays of ad-hoc structures which otherwise would require code generation.
Example: you execute sql statement
select foo, bar, baz, name, address from customer;

Database driver has to return result set somehow (it can be large!)
PigeonMap is a solution: create (automatically, by parsing "select" statement or retrieving ResultSetMetadata) name set containing 5 attributes (foo, bar, baz, name, address) and return array of PigeonMaps - they are memory/performance efficient.

Similar problem occurs while parsing JSONs and in general, in every serialization/deserialization problem.

Because of memory/performance efficiency, pigeon maps can be good also as universal intermadiate format even if you have structs defined in dart - that is, instead of converting
JSON -> dart object directly (which can be messy), convert JSON -> pigeon map and call method that does second step (Pigeon map -> dart object)
That way, we can have N serialization formats and M deserialization formats without the need to write M*N special adapters.

There can be other uses, will cover later.
 