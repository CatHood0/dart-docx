import 'dart:io';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../compiler/inherited/compiler_config_provider.dart';
import '../../exceptions/docx_compilation_exception.dart';
import '../../stores/inherited_stores/drawing_counter_provider.dart';
import '../../stores/inherited_stores/media_provider.dart';

class LazyFloatingImage extends DocxNode<ImageData<File>> with IgnorableMixin {
  LazyFloatingImage({
    required ImageData<File> data,
    super.parent,
    super.id,
    this.transformOffsetX = 0,
    this.transformOffsetY = 0,
  })  : assert(
          data.anchorConfig.wrapType != WrapType.asCharacter,
          'the wrapping strategy '
          'cannot be inline in blocks',
        ),
        super(child: data) {
    super.length = 1;
  }

  final int transformOffsetX;
  final int transformOffsetY;

  @override
  LazyFloatingImage copyWith({
    ImageData<File>? data,
    int? transformOffsetX,
    int? transformOffsetY,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return LazyFloatingImage(
      data: data ?? child,
      transformOffsetX: transformOffsetX ?? this.transformOffsetX,
      transformOffsetY: transformOffsetY ?? this.transformOffsetY,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  LazyFloatingImage get copy => LazyFloatingImage(
        id: id,
        transformOffsetX: transformOffsetX,
        transformOffsetY: transformOffsetY,
        data: ImageData(
          buffer: File(child.buffer.path),
          anchorConfig: child.anchorConfig,
          extension: child.extension,
          styles: child.styles,
          width: child.width,
          height: child.height,
          name: child.name,
          alt: child.alt,
        ),
      );

  String get getImageName => child.name ?? '';

  int? _elementId;
  num? _imgWidthEmu;
  num? _imgHeightEmu;
  late final String childId = DocxElements.instance.createId();

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
  bool shouldIgnore() {
    // since try to get metadata is not expensive
    // we can know if the current image is valid for any decoder
    // at this point
    //
    // if not, just ignore
    final SizeResult _ = ImageSizeGetter.getSizeResult(FileInput(child.buffer));
    // we need to verify even if the file exist
    return child.buffer.existsSync();
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
      final String? relationshipId = mediaProvider.getRelationshipIdForRef(childId) ??
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
        child: LazyImage(
          // should be unique by component
          // by, since blocks are just
          // wrappers of granular components
          // we assign to them the same id
          // to avoid sync issues with stores
          id: childId,
          data: child,
          transformOffsetX: transformOffsetX,
          transformOffsetY: transformOffsetY,
          elementId: _elementId,
          asInline: false,
        ),
        width: _imgWidthEmu!,
        height: _imgHeightEmu!,
        config: child.anchorConfig,
        name: imageName,
        elementId: _elementId,
      ).buildXml(),
    ];
  }

  @override
  String toString() {
    return 'LazyImage(id: $id, data: $child, anchor: ${child.anchorConfig})';
  }

  @override
  LazyFloatingImage? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<LazyFloatingImage>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <LazyFloatingImage>[this] : null;
  }
}
