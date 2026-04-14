import 'dart:typed_data';

import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/normalizer/auto_size_normalizer.dart';

/// Floating image component with advanced positioning options.
///
/// Represents an image that can be positioned independently of text flow,
/// with various wrapping strategies (square, tight, through, topAndBottom).
/// Floating images are wrapped in an `Anchor` element that provides
/// precise positioning relative to page margins, paragraphs, or characters.
///
/// Unlike inline images, floating images support text wrapping around them
/// and complex positioning scenarios.
///
/// Example usage:
/// ```dart
/// final floatingImage = FloatingImage(
///   data: ImageData(
///     buffer: imageBytes,
///     extension: 'jpg',
///     anchorConfig: AnchorConfig.block()
///       .wrapType(WrapType.square)
///       .horizontalAnchor(HorizontalAnchorPosition.margin)
///       .verticalAnchor(VerticalAnchorPosition.paragraph),
///   ),
/// );
/// ```
class FloatingImage extends DocxTreeNode<ImageData<Uint8List>> {
  FloatingImage({
    required ImageData<Uint8List> data,
    super.parent,
    super.id,
    this.transformOffsetX = 0,
    this.transformOffsetY = 0,
  })  : assert(
          data.anchorConfig.wrapType != WrapType.asCharacter,
          'the wrapping strategy '
          'cannot be "asCharacter" in blocks, since '
          '<wp:anchor> component is '
          'required to build correctly an '
          'indenpendent image',
        ),
        super(child: data) {
    super.length = 1;
  }

  final int transformOffsetX;
  final int transformOffsetY;

  String get getImageName => child.name ?? '';

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${child.name}" couldn\'t be '
        'founded into the DocxComponentContext',
      );
    }

    // relates the id with an index id, so, its more easy
    // to get it in more another places
    final int elementId = context.drawingStore.getNextId(id);

    num? imgWidthEmu = child.width;
    num? imgHeightEmu = child.height;

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (imgWidthEmu == null || imgHeightEmu == null) {
      final Uint8List bytes = child.buffer;
      final Size size = ImageSizeGetter.getSizeResult(MemoryInput(bytes)).size;
      // the result is a size computed in inches
      final NormalizedSizeResult resultSize =
          AutoSizeNormalizer.resizeImageBySettings(
        size,
        context.options.pageSize.toInches(),
        context.options.margins.toInches(),
        imageDpi,
      );

      imgWidthEmu ??= resultSize.width?.inchesToEmu();
      imgHeightEmu ??= resultSize.height?.inchesToEmu();
    }

    return <XmlElement>[
      ...Anchor(
        child: Image(
          // should be unique by component
          // but, since blocks are just
          // wrappers of granular components
          // we assign to them the same id
          // to avoid sync issues with stores
          id: id,
          data: child,
          asInline: false,
        ),
        config: child.anchorConfig,
        width: imgWidthEmu!,
        height: imgHeightEmu!,
        name: imageName,
        elementId: elementId,
      ).buildXml(context: context),
    ];
  }

  @override
  List<XmlAttribute> buildXmlStyle({required DocumentContext context}) {
    return [];
  }

  @override
  FloatingImage get copy => FloatingImage(
        id: id,
        transformOffsetX: transformOffsetX,
        transformOffsetY: transformOffsetY,
        data: ImageData<Uint8List>(
          buffer: Uint8List.fromList(child.buffer),
          extension: child.extension,
          anchorConfig: child.anchorConfig,
          styles: child.styles,
          width: child.width,
          height: child.height,
          alt: child.alt,
          name: child.name,
          unit: child.unit,
        ),
      );

  @override
  String toString() {
    return 'Image(id: $id, data: $child)';
  }

  @override
  FloatingImage? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<FloatingImage>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <FloatingImage>[this] : null;
  }
}
