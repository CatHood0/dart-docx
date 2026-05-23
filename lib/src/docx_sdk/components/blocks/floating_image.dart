import 'dart:typed_data';

import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../compiler/inherited/compiler_config_provider.dart';
import '../../exceptions/docx_compilation_exception.dart';
import '../../stores/inherited_stores/drawing_counter_provider.dart';
import '../../stores/inherited_stores/media_provider.dart';

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
class FloatingImage extends DocxNode<ImageData<Uint8List>> {
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
  FloatingImage copyWith({
    ImageData<Uint8List>? data,
    int? transformOffsetX,
    int? transformOffsetY,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return FloatingImage(
      data: data ?? child,
      transformOffsetX: transformOffsetX ?? this.transformOffsetX,
      transformOffsetY: transformOffsetY ?? this.transformOffsetY,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  // relates the id with an index id, so, its more easy
  // to get it in more another places
  int? _elementId;
  num? _imgWidthEmu;
  num? _imgHeightEmu;
  final String childId = DocxElements.instance.createId();

  @override
  void perform() {
    super.perform();
    if (isChildOf<DrawingCounterProvider>()) {
      final DrawingElementCounterStore drawingProvider =
          DrawingCounterProvider.of(this);

      _elementId ??= drawingProvider.getIdFromRef(ref: id) ??
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
      _elementId ??=
          getAncestorOfExactType<Anchor>()?.elementId?.castOrNull() ??
              getAncestorOfExactType<InlineGraphic>()?.elementId?.castOrNull();
    }

    _imgWidthEmu = child.width?.toEmu();
    _imgHeightEmu = child.height?.toEmu();

    if (isChildOf<CompilerConfigProvider>()) {
      final DocumentOptions opt = CompilerConfigProvider.of(this)!.options;
      final DocumentMargins margins = opt.margins;
      final PageSize pageSize = opt.pageSize;

      final ImageSize size = Image.getSizeForImage(
        child,
        margins: margins,
        pageSize: pageSize,
      );

      _imgWidthEmu = size.width;
      _imgHeightEmu = size.height;
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
      final String? relationshipId =
          mediaProvider.getRelationshipIdForRef(childId) ??
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

    return <XmlNode>[
      ...Anchor(
        child: Image(
          // should be unique by component
          // but, since blocks are just
          // wrappers of granular components
          // we assign to them the same id
          // to avoid sync issues with stores
          id: childId,
          data: child,
          asInline: false,
        ),
        config: child.anchorConfig,
        width: _imgWidthEmu!,
        height: _imgHeightEmu!,
        name: imageName,
        elementId: _elementId,
      ).buildXml(),
    ];
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
        ),
      );

  @override
  String toString() {
    return 'Image(id: $id, data: $child)';
  }

  @override
  FloatingImage? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<FloatingImage>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <FloatingImage>[this] : null;
  }
}
