import 'dart:io';
import 'dart:typed_data';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../../core/normalizer/auto_size_normalizer.dart';
import '../../exceptions/docx_compilation_exception.dart';
import '../../stores/inherited_stores/media_provider.dart';

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

  UnitValue? _imgWidthEmu;
  UnitValue? _imgHeightEmu;

  String? docRelsRefId;

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
    UnitValue? transformOffsetX,
    UnitValue? transformOffsetY,
  }) {
    return Image(
      id: id ?? this.id,
      data: child ?? this.child,
      parent: parent ?? this.parent,
      asInline: asInline ?? this.asInline,
      elementId: elementId ?? this.elementId,
      transformOffsetX: transformOffsetX ?? this.transformOffsetX,
      transformOffsetY: transformOffsetY ?? this.transformOffsetY,
    )
      .._imgWidthEmu = _imgWidthEmu
      .._imgHeightEmu = _imgHeightEmu;
  }

  String get getImageName => child.name ?? '';

  //TODO: other image implementations should be using this
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
    UnitValue? width = data.width;
    UnitValue? height = data.height;

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
        DocxElements.instance.dpi,
      );

      width ??= resultSize.width?.toEmu();
      height ??= resultSize.height?.toEmu();
    } else {
      // Avoid having a null reference
      // on both of them
      height ??= width;
      width ??= height;
    }
    return ImageSize(
      width: width!.toEmu(),
      height: height!.toEmu(),
    );
  }

  @override
  void perform() {
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
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${child.name}" couldn\'t be '
        'founded into the DocxComponentContext',
      );
    }

    if (isChildOf<MediaProvider>()) {
      final MediaStore mediaProvider = MediaProvider.of(this);
      final String? docRelsRefId = mediaProvider.getRelationshipIdForRef(id) ??
          mediaProvider.getRelationshipIdForRef(rId!);

      // the index of this image. Literally the
      // relationship id but formatted to a digit
      if (docRelsRefId == null) {
        throw DocxCompilationException(
          message:
              'Image(id: $id | level: $depth | parent: ${parent?.runtimeType}) was not founded in the MediaStore registry or in '
              'the ${DocxPaths.documentXmlRelsFilePath}. Please, ensure this current element is being founded by the '
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
            blip: Blip(embedRelId: docRelsRefId.toString()),
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
                cx: _imgWidthEmu!,
                cy: _imgHeightEmu!,
              ),
            ),
            //NOTE: should be customizable?
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
      if (isChildOf<InlineGraphic>() || !asInline)
        ...graphic.buildXml()
      else
        ...InlineGraphic(
          name: imageName,
          width: _imgWidthEmu ?? Emu(0),
          height: _imgHeightEmu ?? Emu(0),
          components: <DocxNode<dynamic>>[graphic],
          distance: child.anchorConfig.distanceFromText,
          elementId: elementId,
        ).buildXml(),
    ];
  }

  @override
  String toString() {
    return 'Image(id: $id, elementId: $elementId, docRelsRefId: $docRelsRefId, data: $child)';
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
