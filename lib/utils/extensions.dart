extension ExtendedString on String {
  int asInt() => int.parse(this);

  double asDouble() => double.parse(this);
}

extension ExtendedList<T> on List<T> {
  T get firstOrNull => isNotEmpty ? first : null;

  List<T> sublistUpTo(int n) => sublist(0, n > length ? length : n);

  T removeFirst() => isNotEmpty ? removeAt(0) : null;
}

extension ExtendedMap<K> on Map<K, dynamic> {
  bool getBoolean(K key, [bool def]) => this[key] as bool ?? def;

  String getString(K key, [String def]) => this[key] as String ?? def;

  int getInt(K key, [int def]) => this[key]?.toString()?.asInt() ?? def;

  double getDouble(K key, [double def]) => this[key]?.toString()?.asDouble() ?? def;
}
