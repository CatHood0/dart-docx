import '../../../../../docx.dart';

class ImageData<T extends Object> {
  ImageData({
    required this.buffer,
    required this.extension,
    required this.width,
    required this.height,
    this.styles = const <Style>[],
    this.name,
  });

  String? name;
  final T buffer;
  final String extension;
  final double width;
  final double height;
  final List<Style> styles;

  @override
  String toString() {
    return 'ImageData(extension: img.$extension, options: [width: $width, height: $height], styles: $styles)';
  }
}
