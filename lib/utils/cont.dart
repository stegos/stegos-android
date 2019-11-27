/// A pair of values.
class Pair<E, F> {
  Pair(this.first, this.second);

  E first;
  F second;

  @override
  String toString() => '($first, $second)';

  @override
  bool operator ==(other) {
    if (other is! Pair) return false;
    return other.first == first && other.second == second;
  }

  @override
  int get hashCode => first.hashCode ^ second.hashCode;
}
