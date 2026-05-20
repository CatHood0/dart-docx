import 'dart:io';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/normalizer/auto_size_normalizer.dart';
import '../../compiler/inherited/compiler_config_provider.dart';
import '../../stores/inherited_stores/drawing_counter_provider.dart';

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
          unit: child.unit,
        ),
      );

  String get getImageName => child.name ?? '';

  int? _elementId;
  num? _imgWidthEmu;
  num? _imgHeightEmu;

  @override
  void perform() {
    super.perform();
    _elementId ??= DrawingCounterProvider.of(this).getNextId(id);

    // relates the id with an index id, so, its more easy
    // to get it in more another places
    final CompilerConfigProvider? config = CompilerConfigProvider.of(this);

    _imgWidthEmu = child.width;
    _imgHeightEmu = child.height;

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (_imgWidthEmu == null || _imgHeightEmu == null) {
      final Size size =
          ImageSizeGetter.getSizeResult(FileInput(child.buffer)).size;
      // the result is a size computed in inches
      final NormalizedSizeResult resultSize =
          AutoSizeNormalizer.resizeImageBySettings(
        size,
        config?.options.pageSize.toInches(),
        config?.options.margins.toInches(),
        imageDpi,
      );

      _imgWidthEmu ??= resultSize.width?.inchesToEmu();
      _imgHeightEmu ??= resultSize.height?.inchesToEmu();
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

    return <XmlNode>[
      ...Anchor(
        child: LazyImage(
          // should be unique by component
          // by, since blocks are just
          // wrappers of granular components
          // we assign to them the same id
          // to avoid sync issues with stores
          id: id,
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
