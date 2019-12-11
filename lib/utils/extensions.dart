extension ExtendedString on String {
  int asInt() => int.parse(this);

  double asDouble() => double.parse(this);
}

extension ExtendedList<T> on List<T> {
  T get firstOrNull => isNotEmpty ? first : null;

  T get lastOrNull => isNotEmpty ? last : null;

  List<T> sublistUpTo(int n) => sublist(0, n > length ? length : n);

  T removeFirst() => isNotEmpty ? removeAt(0) : null;
}

extension ExtendedMap<K> on Map<K, dynamic> {
  bool getBoolean(K key, [bool def]) => this[key] as bool ?? def;

  String getString(K key, [String def]) => this[key] as String ?? def;

  int getInt(K key, [int def]) => this[key]?.toString()?.asInt() ?? def;

  double getDouble(K key, [double def]) => this[key]?.toString()?.asDouble() ?? def;
}

extension ExtendedDateTime on DateTime {
  static String _fourDigits(int n) {
    final absN = n.abs();
    final sign = n < 0 ? '-' : '';
    if (absN >= 1000) return '$n';
    if (absN >= 100) return '${sign}0$absN';
    if (absN >= 10) return '${sign}00$absN';
    return '${sign}000$absN';
  }

  static String _sixDigits(int n) {
    assert(n < -9999 || n > 9999);
    final absN = n.abs();
    final sign = n < 0 ? '-' : '+';
    if (absN >= 100000) return '$sign$absN';
    return '${sign}0$absN';
  }

  static String _threeDigits(int n) {
    if (n >= 100) return '${n}';
    if (n >= 10) return '0${n}';
    return '00${n}';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '${n}';
    return '0${n}';
  }

  String toIso8601StringV2() {
    final y = (year >= -9999 && year <= 9999) ? _fourDigits(year) : _sixDigits(year);
    final m = _twoDigits(month);
    final d = _twoDigits(day);
    final h = _twoDigits(hour);
    final min = _twoDigits(minute);
    final sec = _twoDigits(second);
    final ms = _threeDigits(millisecond);
    if (isUtc) {
      return '$y-$m-${d}T$h:$min:$sec.${ms}Z';
    } else {
      return '$y-$m-${d}T$h:$min:$sec.$ms';
    }
  }
}
