import '../sdk.dart';

int ensureInteger(num number) {
  if (number.isNaN || number.isInfinite) {
    throw Exception('Invalid value '
        '"$number" specified. '
        'Must be an integer.');
  }
  return number.toInt();
}

/// Generates a unique GUID string suitable for fontKey.
String generateFontGuid() {
  return '{${uuidV4.generate().toUpperCase()}}';
}
