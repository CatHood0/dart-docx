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

  DocumentMargins.fromCm({
    required num top,
    required num right,
    required num left,
    required num bottom,
    required num header,
    required num footer,
    required num gutter,
  })  : top = top.centimetersToDxa(),
        right = right.centimetersToDxa(),
        left = left.centimetersToDxa(),
        bottom = bottom.centimetersToDxa(),
        header = header.centimetersToDxa(),
        footer = footer.centimetersToDxa(),
        gutter = gutter.centimetersToDxa();

  DocumentMargins.fromPoints({
    required num top,
    required num right,
    required num left,
    required num bottom,
    required num header,
    required num footer,
    required num gutter,
  })  : top = top.ptToDxa(),
        right = right.ptToDxa(),
        left = left.ptToDxa(),
        bottom = bottom.ptToDxa(),
        header = header.ptToDxa(),
        footer = footer.ptToDxa(),
        gutter = gutter.ptToDxa();

  DocumentMargins.fromInches({
    required num top,
    required num right,
    required num left,
    required num bottom,
    required num header,
    required num footer,
    required num gutter,
  })  : top = top.inchesToDxa(),
        right = right.inchesToDxa(),
        left = left.inchesToDxa(),
        bottom = bottom.inchesToDxa(),
        header = header.inchesToDxa(),
        footer = footer.inchesToDxa(),
        gutter = gutter.inchesToDxa();

  DocumentMargins toInches() {
    return DocumentMargins(
      top: top.dxaToInches(),
      right: right.dxaToInches(),
      left: left.dxaToInches(),
      bottom: bottom.dxaToInches(),
      header: header.dxaToInches(),
      footer: footer.dxaToInches(),
      gutter: gutter.dxaToInches(),
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
