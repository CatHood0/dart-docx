extension NonNegative on num {
  num get nonNegative {
    return this is double
        ? this < 0
            ? 0.0
            : this
        : toInt() < 0
            ? 0
            : this;
  }
}

extension BoolToNum on bool {
  int toInt() {
    return this ? 1 : 0;
  }
}
