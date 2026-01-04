import '../../../../../docx.dart';

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
    AnchorConfig? anchorConfig,
    this.width,
    this.height,
    this.alt,
    this.unit = Unit.inch,
    this.styles = const <Style>[],
    this.name,
  }) : anchorConfig = anchorConfig ??
            AnchorConfig.square(
              side: WrapSide.largest,
            );

  String? name;
  String? alt;
  final T buffer;
  final String extension;
  final num? width;
  final num? height;

  final List<Style> styles;

  /// Anchor configuration for positioning in DOCX.
  final AnchorConfig anchorConfig;

  final Unit unit;

  @override
  String toString() {
    return 'ImageData(extension: $name.$extension, '
        'config: $anchorConfig'
        'unit: ${unit.name}, '
        'options: [width: $width, height: $height], '
        'styles: $styles)';
  }
}
