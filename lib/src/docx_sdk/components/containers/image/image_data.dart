import '../../../../../docx.dart';

enum ImagePositioning {
  inline, // Inside the text (character level)
  square, // the text will be around the image
  tight, //  text will try to adapt to the image position
  behindText, // Detrás del texto
  inFrontOfText, // front of text
  topAndBottom,
}

enum Unit {
  twip,
  cm,
  mm,
  inch,
  emu,
  pt,
  pixels96,
  dpi,
}

class ImageData<T extends Object> {
  ImageData({
    required this.buffer,
    required this.extension,
    this.width,
    this.height,
    this.alt,
    this.unit = Unit.inch,
    this.styles = const <Style>[],
    this.name,
    this.offsetX = -1,
    this.offsetY = -1,
    this.verticalOffset,
    this.horizontalOffset,
    this.horizontalAlign,
    this.verticalAlign,
  });

  String? name;
  String? alt;
  final T buffer;
  final String extension;
  final double? width;
  final double? height;
  final List<Style> styles;
  final int offsetX;
  final int offsetY;

  final ImagePositioning positioning = ImagePositioning.inline;
  final int? verticalOffset; //
  final int? horizontalOffset; //
  final String? verticalAlign;
  final String? horizontalAlign;
  final Unit unit;

  bool get hasOffset => offsetX >= 0 && offsetY >= 0;

  @override
  String toString() {
    return 'ImageData(extension: img.$extension, options: [width: $width, height: $height], styles: $styles)';
  }
}
