//TODO: we need to make values allowing pass them as inches
// and transform to emu
import '../sdk.dart';

class DocumentMargins {
  const DocumentMargins({
    required this.top,
    required this.right,
    required this.left,
    required this.bottom,
    required this.header,
    required this.footer,
    required this.gutter,
  });

  DocumentMargins.fromInches({
    required num top,
    required num right,
    required num left,
    required num bottom,
    required num header,
    required num footer,
    required num gutter,
  })  : top = top.toDxaFromPixels(),
        right = right.toDxaFromPixels(),
        left = left.toDxaFromPixels(),
        bottom = bottom.toDxaFromPixels(),
        header = header.toDxaFromPixels(),
        footer = footer.toDxaFromPixels(),
        gutter = gutter.toDxaFromPixels();

  DocumentMargins toInches() {
    return DocumentMargins(
      top: top.toInchesFromDxa(),
      right: right.toInchesFromDxa(),
      left: left.toInchesFromDxa(),
      bottom: bottom.toInchesFromDxa(),
      header: header.toInchesFromDxa(),
      footer: footer.toInchesFromDxa(),
      gutter: gutter.toInchesFromDxa(),
    );
  }

  final num top;
  final num right;
  final num left;
  final num bottom;
  final num header;
  final num footer;
  final num gutter;
}
