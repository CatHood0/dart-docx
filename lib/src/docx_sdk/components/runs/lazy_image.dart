import 'dart:io';
import 'dart:math';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../stores/inherited_stores/drawing_counter_provider.dart';
import '../../stores/inherited_stores/media_provider.dart';

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
class LazyImage extends DocxNode<ImageData<File>> {
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
        elementId: elementId,
        asInline: asInline,
        parent: parent,
      );

  @override
  LazyImage copyWith({
    ImageData<File>? child,
    String? id,
    DocxNode<dynamic>? parent,
    int? elementId,
    bool? asInline,
    int? transformOffsetX,
    int? transformOffsetY,
  }) {
    return LazyImage(
      data: child ?? this.child,
      elementId: elementId ?? this.elementId,
      asInline: asInline ?? this.asInline,
      transformOffsetX: transformOffsetX ?? this.transformOffsetX,
      transformOffsetY: transformOffsetY ?? this.transformOffsetY,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  String get getImageName =>
      child.name ?? 'image:${Random.secure().nextInt(900) * 10}';

  num? _imgWidthEmu;
  num? _imgHeightEmu;

  @override
  void perform() {
    super.perform();
    final DrawingElementCounterStore drawingProvider =
        DrawingCounterProvider.of(this);

    elementId ??= drawingProvider.getIdFromRef(ref: id) ??
        // usually, the element id is computed from
        // the anchor or inline parent, so, we prefer
        // using that one value, since was computed exactly for this
        // element
        getAncestorOfExactType<Anchor>()?.elementId?.castOrNull() ??
        getAncestorOfExactType<InlineGraphic>()?.elementId?.castOrNull() ??
        drawingProvider.getNextId(id);

    _imgWidthEmu = child.width;
    _imgHeightEmu = child.height;

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (child.width != null) {
      _imgWidthEmu = child.width!.unitToEmu(child.unit);
    }
    if (child.height != null) {
      _imgHeightEmu = child.height!.unitToEmu(child.unit);
    }

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (_imgWidthEmu == null && _imgHeightEmu == null) {
      final Size size =
          ImageSizeGetter.getSizeResult(FileInput(child.buffer)).size;
      _imgWidthEmu = size.width * emuPerInch / imageDpi;
      _imgHeightEmu = size.height * emuPerInch / imageDpi;
    }
  }

  @override
  List<XmlNode> buildXml() {
    final MediaStore mediaProvider = MediaProvider.of(this);
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${child.name}" couldn\'t be '
        'founded into the DocxComponentContext. Media Store: ${mediaProvider.media}',
      );
    }

    final String? relationshipId = mediaProvider.getRelationshipIdForRef(id) ??
        mediaProvider.getRelationshipIdForRef(rId!);

    if (relationshipId == null) {
      throw Exception(
        'Image(id: $id | level: $depth | parent: ${parent?.runtimeType}) was not founded in the MediaStore registry or in '
        'the ${DocxPaths.documentXmlRelsFilePath}. Please, ensure this current element is being founded by the '
        'MediaStore registry during start of the compilation',
      );
    }

    final Graphic graphic = Graphic.pic(
      parent: this,
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
              // Both sides where these elements are used
              // basically is mandatory, since word needs that
              // them have the same digit value
              extents: AnnotationExtents(cx: _imgWidthEmu!, cy: _imgHeightEmu!),
            ),
            // NOTE: should be customizable?
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

    return <XmlNode>[
      if (!asInline)
        ...graphic.buildXml()
      else
        ...InlineGraphic(
          name: imageName,
          width: _imgWidthEmu!,
          height: _imgHeightEmu!,
          components: <DocxNode<dynamic>>[graphic],
          distance: child.anchorConfig.distanceFromText,
          elementId: elementId,
        ).buildXml(),
    ];
  }

  @override
  String toString() {
    return 'LazyImage(id: $id, data: $child)';
  }

  @override
  LazyImage? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<LazyImage>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <LazyImage>[this] : null;
  }
}
