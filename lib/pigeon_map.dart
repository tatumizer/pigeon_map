library pigeon_map;
import "dart:collection";
import "dart:typed_data";

class NameSet {
  static const int _LINEAR = 0, _BINARY = 1, _HASH = 2;
  List<String> _names;
  int _shift;
  int _searchMode = _HASH;
  Int8List _table; 
  
  NameSet(List<String> names) {
    _names=new List<String>.from(names, growable: false);
    _names.sort((a, b) => a.compareTo(b));
    var len = _names.length;
    if (new HashSet<String>.from(_names).length != len) throw new ArgumentError("repeating names in the list");
    var hashCodes=new List<int>.from(_names.map((key) => key.hashCode));
    // check uniqueness of hash codes
    if (new HashSet<int>.from(hashCodes).length != len) return;

    var pair =[[16, 256], [22, 512], [32, 1024], [45, 2048], [64, 4096]]
        .firstWhere((p)=> len <= p[0], orElse:()=>null);
    if (pair == null) throw new ArgumentError("pigeon map of this size ($len) not supported");
    if (!_tuneUp(hashCodes, pair[1])) {
      _searchMode = len < 10 ? _LINEAR : _BINARY;
      _table = null;
    }
  }
  // the goal is to find a way to produce unique small hash codes for keys
  // small hash code should be in the range [0..2^k-1]
  // I'm trying first to form small hash code from bits 0..k-1 of real hash code 
  // If they are not unique, trying bits 1..k, etc. If I fail after 16 iterations (unlikely)
  // I try bigger k. In total, 32 attempts are made. The probability of not finding unique
  // mapping overall is ~1/10000 (found experimentally)
  bool _tuneUp(hashCodes, tableSize) {
    for (int i = 0; i <= 1 && tableSize <= 4096; i++, tableSize*= 2) {
       _table = new Int8List(tableSize);
       for (_shift = 0; _shift < 16; _shift++) {
         if (_initTable(hashCodes))
           return true;
       }
    }
    return false;
  }
  bool _initTable(hashCodes) {
    _table.fillRange(0, _table.length, -1);
    int mask = _table.length -1;
    for (int i = 0; i < hashCodes.length; i++) {
      int h = (hashCodes[i] >> _shift) & mask;
      if (_table[h] >= 0) return false;
      _table[h] = i;
    }
    return true;
  }
  int _getIndex(String key) {
    int n = _searchMode == _HASH ? _table[(key.hashCode >> _shift)&(_table.length-1)] :
            _searchMode == _LINEAR ? _getIndexByLinearSearch(key) :
            _getIndexByBinarySearch(key);  
    // fast track for identical makes things faster in typical case        
    return n>=0 && (identical(_names[n], key) || _names[n] == key) ? n : -1;
  }
  int _getIndexByBinarySearch(String key) {
      int lo = 0;
      int hi = _names.length - 1;
      if (hi < 0) return -1;
      while (lo <= hi) {
        // Key, if present, is in [lo..hi]
        int mid = lo + ((hi - lo) >> 1);
        int comp = key.compareTo(_names[mid]);
        if      (comp <0) hi = mid - 1;
        else if (comp >0) lo = mid + 1;
        else return mid;
      }
      return -1;
  }
  int _getIndexByLinearSearch(String key) {
    return _names.indexOf(key);
  }
  List<String> get names => _names;
  int get length => _names.length;
  bool get isFast => _table!=null;
  setSearchModeForTest (mode) => _searchMode = mode;
}

class PigeonMap implements Map<String, dynamic> {
  static final _undefined = new Object();
  NameSet _nameSet;
  int _length = 0;
  List _values;

  PigeonMap(this._nameSet) {
    _values = new List.filled(_nameSet.length, _undefined);
  }
  _keyError(key) => throw new ArgumentError("name '$key' is not in the NameSet");
  operator []=(String key, dynamic v) {
    int n = _nameSet._getIndex(key);
    if (n<0) _keyError(key);
    if (identical(_values[n], _undefined)) _length++;
    _values[n] = v;
  }

  operator [](String key) {
    int n = _nameSet._getIndex(key);
    if (n<0) _keyError(key);
    var v = _values[n];
    return identical(v, _undefined) ? null :v;
  }

  bool containsKey(String key) {
    int n = _nameSet._getIndex(key);
    return n>=0 && !identical(_values[n], _undefined);
  }

  void addAll(Map<String, dynamic> other) => other.forEach((k, v) => this[k] = v);
  
  void clear() {
    _values.fillRange(0, _values.length, _undefined);
    _length = 0;
  }
  

  bool containsValue(Object value) {
    return _values.indexOf(value) >= 0;
  }

  void forEach(void f(String key, dynamic value)) {
     Maps.forEach(this, f);
  }

  bool get isEmpty => _length == 0;
  
  bool get isNotEmpty => _length != 0;
  // we have to use strange algo to detect concurrent modification
  Iterable<String> get keys { 
    int i = -1;
    var names=_nameSet._names;
    return _values.map((v) { 
      i++; 
      return identical(v, _undefined) ? null : names[i]; 
    }).where((k) => k!=null);
  }
  
  int get length => _length;
  bool get isFast => _nameSet.isFast;
  putIfAbsent(String key, dynamic ifAbsent()) {
    int n = _nameSet._getIndex(key);
    if (n<0) _keyError(key);
    var old=_values[n];
    if (identical(old, _undefined)) {
      _values[n] = ifAbsent();
      _length++;
      return null;
    }
    return old;
  }

  dynamic remove(String key) {
    int n = _nameSet._getIndex(key);
    if (n<0 || identical(_values[n], _undefined)) return null;
    var old = _values[n];
    _values[n] = _undefined;
    if (identical(old, _undefined)) return null;
    _length--;
    return old;
    
  }
  
  String toString() {
    return Maps.mapToString(this);
  }

  Iterable get values => _values.where((v) => !identical(v, _undefined));
}
