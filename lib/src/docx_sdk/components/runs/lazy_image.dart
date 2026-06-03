import 'dart:io';
import 'dart:math';

import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../compiler/inherited/compiler_config_provider.dart';
import '../../exceptions/docx_compilation_exception.dart';
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
    this.transformOffsetX = const Emu(0),
    this.transformOffsetY = const Emu(0),
  }) : super(child: data);

  /// Whether the image should be rendered inline with text.
  bool asInline;

  /// Horizontal transformation offset in EMU units.
  final UnitValue transformOffsetX;

  /// Vertical transformation offset in EMU units.
  final UnitValue transformOffsetY;
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
          anchorConfig: child.anchorConfig,
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
    UnitValue? transformOffsetX,
    UnitValue? transformOffsetY,
  }) {
    return LazyImage(
      data: child ?? this.child,
      elementId: elementId ?? this.elementId,
      asInline: asInline ?? this.asInline,
      transformOffsetX: transformOffsetX ?? this.transformOffsetX,
      transformOffsetY: transformOffsetY ?? this.transformOffsetY,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    )
      .._imgWidthEmu = _imgWidthEmu
      .._imgHeightEmu = _imgHeightEmu
      ..relationshipId = relationshipId;
  }

  String get getImageName =>
      child.name ?? 'image:${Random.secure().nextInt(900) * 10}';

  UnitValue? _imgWidthEmu;
  UnitValue? _imgHeightEmu;
  String? relationshipId = '1';

  @override
  void perform() {
    super.perform();
    if (isChildOf<DrawingCounterProvider>()) {
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
    } else {
      // usually, the element id is computed from
      // the anchor or inline parent, so, we prefer
      // using that one value, since was computed exactly for this
      // element
      elementId ??= getAncestorOfExactType<Anchor>()?.elementId?.castOrNull() ??
          getAncestorOfExactType<InlineGraphic>()?.elementId?.castOrNull();
    }

    _imgWidthEmu = child.width;
    _imgHeightEmu = child.height;

    if (isChildOf<CompilerConfigProvider>()) {
      final DocumentOptions opt = CompilerConfigProvider.of(this)!.options;
      final DocumentMargins margins = opt.margins;
      final PageSize pageSize = opt.pageSize;

      final ImageSize size = Image.getSizeForImage(
        child,
        margins: margins,
        pageSize: pageSize,
      );

      _imgWidthEmu = size.width.toEmu();
      _imgHeightEmu = size.height.toEmu();
    }
  }

  @override
  List<XmlNode> buildXml() {
    final String imageName = getImageName;

    if (isChildOf<MediaProvider>()) {
      final MediaStore mediaProvider = MediaProvider.of(this);
      relationshipId = mediaProvider.getRelationshipIdForRef(id) ??
          mediaProvider.getRelationshipIdForRef(rId!);

      // TODO: should we register these elements automatically during building?
      //
      // the index of this image. Literally the
      // relationship id but formatted to a digit
      if (relationshipId == null) {
        throw DocxCompilationException(
          message:
              '$runtimeType:$id was not founded in the MediaStore registry or in '
              'the ${DocxPaths.documentXmlRelsFilePath}. '
              'Please, ensure your element has ben discovered by the store before building'
              'MediaStore registry during start of the compilation',
          cause:
              'Not found relationship id into document.xml.rels that references this element',
          node: this,
        );
      }
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
              extents: AnnotationExtents(
                cx: _imgWidthEmu!,
                cy: _imgHeightEmu!,
              ),
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
