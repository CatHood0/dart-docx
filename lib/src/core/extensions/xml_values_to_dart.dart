extension DeserializerExt on String {
  static final List<String> _trueFalseList = List<String>.from(
    <String>['true', 'false'],
  );
  num? toNum() {
    final double? dValue = double.tryParse(this);
    if (dValue != null) return dValue;
    final int? iValue = int.tryParse(this);
    if (iValue != null) return iValue;
    return null;
  }

  bool? toBoolean() {
    // we prefer not assuming that this is a boolean value
    // just check if it is, and then, this makes the comparison
    final bool contains = _trueFalseList.contains(this);
    if (!contains) return null;
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
