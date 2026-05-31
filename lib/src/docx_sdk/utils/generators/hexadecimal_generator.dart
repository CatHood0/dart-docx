import 'dart:math';

import '../../compiler/pipeline/docx_pipeline.dart';

const String _hexDigits = '0123456789ABCDEF';

int _count = 0;

String nanoid(
  int length, {
  String charset = _hexDigits,
  bool ignoreDebug = false,
}) {
  if (DocxElements.kDebugMode && !ignoreDebug) {
    return '${_count++}';
  }
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
