import 'dart:io';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/normalizer/auto_size_normalizer.dart';

class LazyFloatingImage extends DocxNode<ImageData<File>>
    with IgnorableMixin {
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
  List<XmlElement> buildXml({required BuildNodeContext context}) {
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
      final Size size =
          ImageSizeGetter.getSizeResult(FileInput(child.buffer)).size;
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
          asInline: false,
        ),
        width: imgWidthEmu!,
        height: imgHeightEmu!,
        config: child.anchorConfig,
        name: imageName,
        elementId: elementId,
      ).buildXml(context: context),
    ];
  }

  @override
  List<XmlAttribute> buildXmlStyle({required BuildNodeContext context}) {
    return <XmlAttribute>[];
  }

  @override
  String toString() {
    return 'LazyImage(id: $id, data: $child)';
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
