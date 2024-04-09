import 'dart:convert';
import 'dart:typed_data';

extension Integers on int{
  bool between(int min, int max)=>min<this && this<max;
  int normalize()=>this<0 ? -1 : 1;
}

extension Convert<K,V> on Iterable<MapEntry<K,V>>{
  Map<K,V> toMap()=>Map.fromEntries(this);
}
extension Iterables<E> on Iterable<E>{
  Map<K,V> toMap<K,V>(K Function(E element) key,V Function(E element) value)=>map((e) => MapEntry(key(e), value(e))).toMap();
}

extension Maps<K,V> on Map<K,V> {
  Map<K,V> where(bool Function(K key, V value) test)=>entries.where((e) => test(e.key,e.value)).toMap();
  Map<K2,V2> whereType<K2,V2>()=>entries.where((e) => e.key is K2 && e.value is V2).map((e) => MapEntry(e.key as K2, e.value as V2)).toMap();
  T fold<T>(T initial, T Function(T initialValue, K key,V value) combine)=>entries.fold(initial, (previous, e) => combine(previous, e.key,e.value));
  static Map<K,V> multiple<K,V>(List<Map<K,V>?> maps)=>maps.nonNulls.expand((e) => e.entries).toMap();
  String get encoded=>K is String ? json.encode(this) : json.encode(map((key, value) => MapEntry(key.toString(), value)));
}



extension StringData on Uint8List {
  String get string=>String.fromCharCodes(this);
}

extension JSON on String {
  dynamic get decoded=>json.decode(this);
}