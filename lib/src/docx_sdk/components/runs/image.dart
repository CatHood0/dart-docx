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
///     width: 2,
///     height: 1.5,
///     unit: Unit.inches,
///   ),
/// );
/// ```
/// ## Note:
///
/// Please, take careful he name of the images,
/// since if it's not provided, the compiler
/// will generate a generic one.
///
/// In future releases incremental editing probably will be enabled and to avoid loss images provide one
class Image extends DocxNode<ImageData<Uint8List>> {
  Image({
    required ImageData<Uint8List> data,
    super.parent,
    super.id,
    this.elementId,
    this.asInline = false,
    this.transformOffsetX = 0,
    this.transformOffsetY = 0,
  }) : super(child: data);

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
        buffer: child.buffer,
        extension: child.extension,
        styles: child.styles,
        width: child.width,
        anchorConfig: child.anchorConfig,
        height: child.height,
        name: child.name,
        alt: child.alt,
        unit: child.unit,
      ),
      transformOffsetX: transformOffsetX,
      transformOffsetY: transformOffsetY,
      parent: parent,
      elementId: elementId,
      asInline: asInline,
    );
  }

  @override
  Image copyWith({
    ImageData<Uint8List>? child,
    String? id,
    DocxNode<dynamic>? parent,
    int? elementId,
    bool? asInline,
    int? transformOffsetX,
    int? transformOffsetY,
  }) {
    return Image(
      data: child ?? this.child,
      elementId: elementId ?? this.elementId,
      asInline: asInline ?? this.asInline,
      transformOffsetX: transformOffsetX ?? this.transformOffsetX,
      transformOffsetY: transformOffsetY ?? this.transformOffsetY,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  String get getImageName => child.name ?? '';

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
    if (width == null && height == null) {
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
    } else {
      // Avoid having a null reference
      // on both of them
      height ??= width;
      width ??= height;

      width = width!.unitToEmu(data.unit);
      height = height!.unitToEmu(data.unit);
    }
    return ImageSize(
      width: width!,
      height: height!,
    );
  }

  @override
  void perform() {
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
      throw Exception(
        'Image(id: $id | level: $depth | parent: ${parent?.runtimeType}) was not founded in the MediaStore registry or in '
        'the ${DocxPaths.documentXmlRelsFilePath}. Please, ensure this current element is being founded by the '
        'MediaStore registry during start of the compilation',
      );
    }
  }

  @override
  List<XmlNode> buildXml() {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${child.name}" couldn\'t be '
        'founded into the DocxComponentContext',
      );
    }
    final String relationshipId =
        (context.mediaStore.getRelationshipIdForRef(id) ??
            context.mediaStore.getRelationshipIdForRef(rId ?? '-1'))!;

    final ImageSize imageSize = getSizeForImage(
      child,
      pageSize: context.options.pageSize,
      margins: context.options.margins,
    );

    final Graphic graphic = Graphic(
      child: GraphicData(
        uri: namespaces['pic']!,
        child: Picture(
          components: <DocxNode<dynamic>>[
            BlipFill.pic(
              blip: Blip(embedRelId: relationshipId.toString()),
              stretch: Stretch(
                child: <DocxNode<dynamic>>[
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
                extents: AnnotationExtents(
                    cx: imageSize.width, cy: imageSize.height),
              ),
              presetGeometry: PresetGeometry(preset: PresetShapeType.rectangle),
            ),
            NonVisualPictureProperties(
              nonVisualDrawingProperties: NonVisualDrawingProperties(
                id: elementId!.toString(),
                name: imageName,
                description: child.alt ?? imageName,
              ),
              nonVisualPictureDrawingProperties:
                  NonVisualPictureDrawingProperties(),
            ),
          ],
        ),
      ),
    );

    return <XmlNode>[
      if (!asInline)
        ...graphic.ensureInitialized(context).buildXml()
      else
        ...Inline(
          name: imageName,
          width: imageSize.width,
          height: imageSize.height,
          components: <DocxNode<dynamic>>[graphic],
          distance: child.anchorConfig.distanceFromText,
        ).ensureInitialized(context).buildXml(),
    ];
  }

  @override
  String toString() {
    return 'Image(id: $id, data: $child)';
  }

  @override
  Image? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<Image>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
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
