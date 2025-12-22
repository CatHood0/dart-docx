import 'dart:math';

const String _hexDigits = '0123456789ABCDEF';

String nanoid(int length, {String charset = _hexDigits}) {
  assert(
      charset.isNotEmpty,
      'current charset '
      '"$charset" is not '
      'valid for length $length');
  final Random random = Random.secure();
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < length; i++) {
    buffer.write(charset[random.nextInt(charset.length)]);
  }

  return buffer.toString();
}
