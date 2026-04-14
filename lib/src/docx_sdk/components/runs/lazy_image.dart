import 'dart:io';
import 'dart:math';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';

/// Lazy-loaded image component with file-based data.
///
/// This class represents an image loaded from a file, with lazy evaluation
/// of image dimensions. It's useful for large images or when working with
/// file systems, as it only reads the image data when needed.
///
/// Similar to [Image], this can render as inline or floating, but defers
/// file reading until compilation time.
///
/// Example usage:
/// ```dart
/// final lazyImage = LazyImage(
///   data: ImageData(
///     buffer: File('path/to/image.png'),
///     extension: 'png',
///     width: 2,
///     height: 1.5,
///     unit: Unit.inches,
///   ),
/// );
/// ```
///
/// ## Note:
///
/// Please, take careful he name of the images,
/// since if it's not provided, the compiler
/// will generate a generic one.
///
/// In future releases incremental editing probably will be enabled and to avoid loss images provide one
class LazyImage extends DocxTreeNode<ImageData<File>> {
  LazyImage({
    required ImageData<File> data,
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
  LazyImage get copy => LazyImage(
        id: id,
        data: ImageData<File>(
          buffer: File(child.buffer.path),
          extension: child.extension,
          styles: child.styles,
          width: child.width,
          height: child.height,
          name: child.name,
          alt: child.alt,
          unit: child.unit,
        ),
        transformOffsetY: transformOffsetY,
        transformOffsetX: transformOffsetX,
      );

  String get getImageName =>
      child.name ?? 'image:${Random.secure().nextInt(900) * 10}';

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${child.name}" couldn\'t be '
        'founded into the DocxComponentContext. Media Store: ${context.mediaStore.media}',
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

    if (relationshipId == null) {
      throw Exception(
        'Image(id: $id | level: $depth | parent: ${parent?.runtimeType}) was not founded in the MediaStore registry or in '
        'the ${DocxPaths.documentXmlRelsFilePath}. Please, ensure this current element is being founded by the '
        'MediaStore registry during start of the compilation',
      );
    }

    num? imgWidthEmu;
    num? imgHeightEmu;

    if (child.width != null) {
      imgWidthEmu = child.width!.unitToEmu(child.unit);
    }
    if (child.height != null) {
      imgHeightEmu = child.height!.unitToEmu(child.unit);
    }

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (imgWidthEmu == null && imgHeightEmu == null) {
      final Size size =
          ImageSizeGetter.getSizeResult(FileInput(child.buffer)).size;
      imgWidthEmu = size.width * emuPerInch / imageDpi;
      imgHeightEmu = size.height * emuPerInch / imageDpi;
    }

    final Graphic graphic = Graphic.pic(
      child: Picture(
        components: <DocxTreeNode<dynamic>>[
          BlipFill.pic(
            blip: Blip(embedRelId: relationshipId.toString()),
            stretch: Stretch(
              child: <DocxTreeNode<dynamic>>[
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
              extents: AnnotationExtents(cx: imgWidthEmu!, cy: imgHeightEmu!),
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
    );

    return <XmlElement>[
      if (!asInline)
        ...graphic.buildXml(context: context)
      else
        ...Inline(
          name: imageName,
          width: imgWidthEmu,
          height: imgHeightEmu,
          components: <DocxTreeNode<dynamic>>[graphic],
          distance: child.anchorConfig.distanceFromText,
        ).buildXml(context: context),
    ];
  }

  @override
  List<XmlAttribute> buildXmlStyle({required DocumentContext context}) {
    return [];
  }

  @override
  String toString() {
    return 'LazyImage(id: $id, data: $child)';
  }

  @override
  LazyImage? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<LazyImage>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <LazyImage>[this] : null;
  }
}
