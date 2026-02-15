import 'dart:io';
import 'dart:typed_data';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../../core/normalizer/auto_size_normalizer.dart';

/// Standard image component with in-memory byte data.
///
/// This class represents an image stored as raw bytes in memory.
/// It handles image insertion into DOCX documents with automatic
/// size detection and proper XML generation for the DrawingML format.
///
/// The image can be rendered as either inline (flows with text)
/// or floating (positioned independently with text wrap options).
///
/// Example usage:
/// ```dart
/// final image = Image(
///   data: ImageData(
///     buffer: imageBytes,
///     extension: 'png',
///     width: 2.inchesToEmu(),
///     height: 1.5.inchesToEmu(),
///   ),
/// );
/// ```
class Image extends DocxTreeNode<ImageData<Uint8List>> {
  Image({
    required super.data,
    super.parent,
    super.id,
    this.elementId,
    this.asInline = false,
    this.transformOffsetX = 0,
    this.transformOffsetY = 0,
  });

  /// Whether the image should be rendered inline with text.
  bool asInline;

  /// Horizontal transformation offset in EMU units.
  final int transformOffsetX;

  /// Vertical transformation offset in EMU units.
  final int transformOffsetY;

  int? elementId;

  @override
  Image get copy {
    return Image(
      id: id,
      data: ImageData<Uint8List>(
        buffer: data.buffer,
        extension: data.extension,
        styles: data.styles,
        width: data.width,
        anchorConfig: data.anchorConfig,
        height: data.height,
        name: data.name,
        alt: data.alt,
        unit: data.unit,
      ),
      transformOffsetX: transformOffsetX,
      transformOffsetY: transformOffsetY,
    );
  }

  String get getImageName => data.name ?? '';

  static ImageSize getSizeForImage(
    ImageData data, {
    PageSize? pageSize,
    DocumentMargins? margins,
  }) {
    assert(
      data is ImageData<File> || data is ImageData<Uint8List>,
      'buffer must be File or '
      'Uint8List to get '
      'image size',
    );
    num? width = data.width;
    num? height = data.height;

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (width == null || height == null) {
      final Object bytes = data.buffer;
      final Size size = ImageSizeGetter.getSizeResult(
        bytes is File
            ? FileInput(bytes)
            : MemoryInput(
                bytes.cast<Uint8List>(),
              ),
      ).size;
      final NormalizedSizeResult resultSize =
          AutoSizeNormalizer.resizeImageBySettings(
        size,
        pageSize?.toInches(),
        margins?.toInches(),
        imageDpi,
      );

      width ??= resultSize.width?.inchesToEmu();
      height ??= resultSize.height?.inchesToEmu();
    }
    return ImageSize(
      width: width!,
      height: height!,
    );
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${data.name}" couldn\'t be '
        'founded into the DocxComponentContext',
      );
    }

    final String? relationshipId =
        context.mediaStore.getRelationshipIdForRef(id) ??
            context.mediaStore.getRelationshipIdForRef(rId ?? '-1');

    elementId ??= context.drawingStore.getIdFromRef(ref: id) ??
        // usually, the element id is computed from
        // the anchor or inline parent, so, we prefer
        // using that one value, since was computed exactly for this
        // element
        context.getAncestorOfExactType<Anchor>()?.elementId?.castOrNull() ??
        context.getAncestorOfExactType<Inline>()?.elementId?.castOrNull() ??
        context.drawingStore.getNextId(id);

    // the index of this image. Literally the
    // relationship id but formatted to a digit
    if (relationshipId == null) {
      throw Exception('Image($id) with "$data", was not inserted in '
          'document.xml.rels, and cannot found relation id');
    }

    final ImageSize imageSize = getSizeForImage(
      data,
      pageSize: context.options.pageSize,
      margins: context.options.margins,
    );

    final Graphic graphic = Graphic(
      data: GraphicData(
        uri: namespaces['pic']!,
        data: Picture(
          components: <DocxTreeNode<dynamic>>[
            BlipFill.pic(
              blip: Blip(embedRelId: relationshipId.toString()),
              stretch: Stretch(
                data: <DocxTreeNode<dynamic>>[
                  FillRectangle(),
                ],
              ),
            ),
            PictureShapeProperties(
              transform2D: Transform2D(
                offset: Offset(
                  x: transformOffsetX,
                  y: transformOffsetY,
                ),
                extents: AnnotationExtents(cx: imageSize.width, cy: imageSize.height),
              ),
              presetGeometry: PresetGeometry(preset: PresetShapeType.rectangle),
            ),
            NonVisualPictureProperties(
              nonVisualDrawingProperties: NonVisualDrawingProperties(
                id: elementId!.toString(),
                name: imageName,
                description: data.alt ?? imageName,
              ),
              nonVisualPictureDrawingProperties:
                  NonVisualPictureDrawingProperties(),
            ),
          ],
        ),
      ),
    );

    return <XmlElement>[
      if (!asInline)
        ...graphic.buildXml(context: context)
      else
        ...Inline(
          name: imageName,
          width: imageSize.width,
          height: imageSize.height,
          components: <DocxTreeNode<dynamic>>[graphic],
          distance: data.anchorConfig.distanceFromText,
        ).buildXml(context: context),
    ];
  }

  @override
  List<XmlAttribute> buildXmlStyle({required DocumentContext context}) {
    return <XmlAttribute>[];
  }

  @override
  String toString() {
    return 'Image(id: $id, data: $data)';
  }

  @override
  Image? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<Image>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <Image>[this] : null;
  }
}

class ImageSize {
  ImageSize({
    required this.width,
    required this.height,
  });

  final num width;
  final num height;
}
