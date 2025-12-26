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
    this.frameOffsetY,
    this.frameOffsetX,
    this.frameAlignX = 'left',
    this.frameAlignY = 'top',
  });

  String? name;
  String? alt;
  final T buffer;
  final String extension;
  final num? width;
  final num? height;

  final List<Style> styles;

  /// Global horizontal offset applied to the whole document
  final int offsetX;

  /// Global vertical offset applied to the whole document
  final int offsetY;

  final ImagePositioning positioning = ImagePositioning.inline;

  /// Internal Vertical offset applied only to the box where the image is painted
  final int? frameOffsetY;

  /// Internal Horizontal offset applied only to the box where the image is
  final int? frameOffsetX;

  /// Internal Vertical alignment applied to the box where the image is
  final String frameAlignY;

  /// Internal Horizontal alignment applied to the box where the image is
  final String frameAlignX;
  final Unit unit;

  bool get hasGlobalOffset => offsetX >= 0 && offsetY >= 0;

  String wrapType() {
    return switch (positioning) {
      ImagePositioning.square => 'square',
      ImagePositioning.tight => 'tight',
      ImagePositioning.behindText => 'none',
      ImagePositioning.inFrontOfText => 'none',
      ImagePositioning.topAndBottom => 'topAndBottom',
      _ => 'square',
    };
  }

  @override
  String toString() {
    return 'ImageData(extension: $name.$extension, '
        'wrap: ${wrapType()}, '
        'positioning: ${positioning.name}, '
        'offsetX: $offsetX, '
        'offsetY: $offsetY, '
        'frameOffsetX: $frameOffsetX, '
        'frameOffsetY: $frameOffsetY, '
        'unit: ${unit.name}, '
        'options: [width: $width, height: $height], '
        'styles: $styles)';
  }
}
