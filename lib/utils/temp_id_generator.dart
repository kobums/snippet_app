class TempIdGenerator {
  static int _counter = -1;

  static int generate() {
    return _counter--;
  }
}
