
extension DeserializerExt on String {
  num? toNum() {
    return num.tryParse(this);
  }

  bool? toBoolean() {
    // we prefer not assuming that this is a boolean value
    // just check if it is, and then, this makes the comparison
    final bool? contains = bool.tryParse(this);
    if (contains == null) return null;
    return this == 'true';
  }

  Object toExactValueFromXml() {
    final num? number = toNum();
    if (number != null) return number;
    final bool? boolean = toBoolean();
    if (boolean != null) return boolean;
    return this;
  }
}
