import 'dart:io';
import 'dart:typed_data';

import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';

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
    this.unit = Unit.pixels96,
    this.styles = const <Style>[],
    this.name,
  })  : assert(
          buffer is Uint8List || buffer is File,
          'buffer '
          'can only accept Uint8List and File '
          'types. Another types aren\'t supported yet',
        ),
        anchorConfig = anchorConfig ??
            AnchorConfig.square(
              side: WrapSide.largest,
            );

  ImageData.size({
    required this.buffer,
    required this.extension,
    required double size,
    AnchorConfig? anchorConfig,
    this.alt,
    this.unit = Unit.pixels96,
    this.styles = const <Style>[],
    this.name,
  })  : assert(
          buffer is Uint8List || buffer is File,
          'buffer '
          'can only accept Uint8List and File '
          'types. Another types aren\'t supported yet',
        ),
        width = size,
        height = size,
        anchorConfig = anchorConfig ??
            AnchorConfig.square(
              side: WrapSide.largest,
            );

  static ImageData<File> file({
    required String file,
    AnchorConfig? anchorConfig,
    num? width,
    num? height,
    String? alt,
    Unit unit = Unit.pixels96,
    List<Style> styles = const <Style>[],
    String? name,
  }) {
    assert(file.lastIndexOf('.') != -1,
        'the current path does not aim to a valid file: "$file"');
    final String ext = file.substring(file.lastIndexOf('.'));
    assert(ext.startsWith('.'),
        'extension cannot start with another character than ".". Found: $ext');
    return ImageData<File>(
      buffer: File(file),
      extension: ext,
      width: width,
      height: height,
      name: name,
      alt: alt,
      unit: unit,
      styles: styles,
      anchorConfig: anchorConfig,
    );
  }

  static ImageData<File> fileSized({
    required String file,
    required num size,
    AnchorConfig? anchorConfig,
    String? alt,
    Unit unit = Unit.pixels96,
    List<Style> styles = const <Style>[],
    String? name,
  }) {
    assert(file.lastIndexOf('.') != -1,
        'the current path does not aim to a valid file: "$file"');
    final String ext = file.substring(file.lastIndexOf('.') + 1);
    assert(ext.startsWith('.'),
        'extension cannot start with another character than ".". Found: $ext');
    print(ext);
    return ImageData<File>(
      buffer: File(file),
      extension: ext,
      name: name,
      alt: alt,
      unit: unit,
      width: size,
      height: size,
      styles: styles,
      anchorConfig: anchorConfig,
    );
  }

  String? name;
  String? alt;
  final T buffer;
  final String extension;

  /// The width of this image in the Docx document
  final num? width;

  /// The width of this image in the Docx document
  final num? height;

  final List<Style> styles;

  /// Anchor configuration for positioning in DOCX.
  final AnchorConfig anchorConfig;

  /// The unit that the width and height have
  ///
  /// Useful to know the type unit to convert it
  /// to EMU equivalent
  ///
  /// Default to Unit.pixels96
  final Unit unit;

  @override
  String toString() {
    return 'ImageData(extension: ${buffer is File ? buffer.cast<File>().path : '${name ?? 'N/A'}.$extension'}, '
        'config: $anchorConfig'
        'unit: ${unit.name}, '
        'options: [width: $width, height: $height], '
        'styles: $styles)';
  }
}

class MediaData {
  MediaData({
    required this.name,
    required this.id,
    required this.extension,
    required this.bytes,
    required this.relationshipId,
    this.fileName = '',
  });

  // this is the rId of the image
  final String relationshipId;
  final Uint8List bytes;
  // the name of the image into DOCX file
  final String name;
  // the name of the image into the media folder
  final String fileName;
  // this id is auto-generated
  // to be pasted
  final int id;
  // the extension of this media
  final String extension;

  @override
  String toString() {
    return 'MediaData(name: $name.$extension, id: $id)';
  }
}
