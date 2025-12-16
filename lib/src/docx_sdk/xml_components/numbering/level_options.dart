import '../../../../docx.dart';
import 'formats.dart';

class LevelOptions {
  LevelOptions({
    required this.level,
    required this.format,
    required this.text,
    this.alignment = Alignment.left,
    this.start = 1,
    this.suffix,
    this.isLegalNumberingStyle = false,
    this.paragraphStyle,
    this.runStyle,
  });

  final num level;
  final LevelFormat format;
  final String text;
  final Alignment alignment;
  final int start;
  final String? suffix;
  final bool isLegalNumberingStyle;

  final Style? paragraphStyle;
  final Style? runStyle;
}
