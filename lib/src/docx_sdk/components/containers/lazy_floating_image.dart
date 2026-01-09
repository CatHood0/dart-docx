import 'dart:io';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/normalizer/auto_size_normalizer.dart';
import '../../mixins/ignorable_mixin.dart';
import 'anchor.dart';

class LazyFloatingImage extends ComponentContainer<ImageData<File>>
    with IgnorableMixin {
  LazyFloatingImage({
    required super.data,
    super.parent,
    super.id,
    this.transformOffsetX = 0,
    this.transformOffsetY = 0,
  }) : assert(
          data.anchorConfig.wrapType != WrapType.asCharacter,
          'the wrapping strategy '
          'cannot be inline in blocks',
        );

  final int transformOffsetX;
  final int transformOffsetY;

  @override
  LazyFloatingImage get copy => LazyFloatingImage(
        id: id,
        transformOffsetX: transformOffsetX,
        transformOffsetY: transformOffsetY,
        data: ImageData(
          buffer: File(data.buffer.path),
          anchorConfig: data.anchorConfig,
          extension: data.extension,
          styles: data.styles,
          width: data.width,
          height: data.height,
          name: data.name,
          alt: data.alt,
          unit: data.unit,
        ),
      );

  String get getImageName => data.name ?? '';

  @override
  bool shouldIgnore() {
    // since try to get metadata is not expensive
    // we can know if the current image is valid for any decoder
    // at this point
    //
    // if not, just ignore
    final _ = ImageSizeGetter.getSizeResult(FileInput(data.buffer));
    // we need to verify even if the file exist
    return data.buffer.existsSync();
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${data.name}" couldn\'t be '
        'founded into the DocxComponentContext',
      );
    }

    // relates the id with an index id, so, its more easy
    // to get it in more another places
    final int elementId = context.drawingStore.getNextId(id);

    num? imgWidthEmu = data.width;
    num? imgHeightEmu = data.height;

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (imgWidthEmu == null || imgHeightEmu == null) {
      final Size size =
          ImageSizeGetter.getSizeResult(FileInput(data.buffer)).size;
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
      super.runParent(
        attributes: buildXmlStyle(context: context),
        children: <XmlNode>[
          ...Anchor(
            component: LazyImage(
              // should be unique by component
              // by, since blocks are just
              // wrappers of granular components
              // we assign to them the same id
              // to avoid sync issues with stores
              id: id,
              data: data,
              transformOffsetX: transformOffsetX,
              transformOffsetY: transformOffsetY,
              asInline: false,
            ),
            widthEmu: imgWidthEmu!,
            heightEmu: imgHeightEmu!,
            config: data.anchorConfig,
            name: imageName,
            elementId: elementId,
          ).buildXml(context: context),
        ],
      ),
    ];
  }

  @override
  List<XmlAttribute> buildXmlStyle({required DocumentContext context}) {
    return [];
  }

  @override
  String toString() {
    return 'LazyImage(id: $id, data: $data)';
  }

  @override
  LazyFloatingImage? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<LazyFloatingImage>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <LazyFloatingImage>[this] : null;
  }
}
