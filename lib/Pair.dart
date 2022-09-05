enum PreStave { none, front, middle, end }

class Pair {
  List pair = [];

  void add(var p) {
    if (pair.length >= 2) {
      pair.clear();
    }
    pair.add(p);
  }

  void clear() {
    pair.clear();
  }
}
