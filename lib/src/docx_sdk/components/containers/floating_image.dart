import 'dart:typed_data';

import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/normalizer/auto_size_normalizer.dart';
import 'anchor.dart';

class FloatingImage extends DocxTreeNode<ImageData<Uint8List>> {
  FloatingImage({
    required super.data,
    super.parent,
    super.id,
    this.transformOffsetX = 0,
    this.transformOffsetY = 0,
  }) : assert(
          data.anchorConfig.wrapType != WrapType.asCharacter,
          'the wrapping strategy '
          'cannot be "asCharacter" in blocks, since '
          '<wp:anchor> component is '
          'required to build correctly an '
          'indenpendent image',
        );

  final int transformOffsetX;
  final int transformOffsetY;

  String get getImageName => data.name ?? '';

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${data.name}" couldn\'t be '
        'founded into the DocxComponentContext',
      );
    }

    final int? docPrId = context.store.getIndexId(id);

    num? imgWidthEmu = data.width;
    num? imgHeightEmu = data.height;

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (imgWidthEmu == null || imgHeightEmu == null) {
      final Uint8List bytes = data.buffer;
      final Size size = ImageSizeGetter.getSizeResult(MemoryInput(bytes)).size;
      // the result is a size computed in inches
      final NormalizedSizeResult resultSize =
          AutoSizeNormalizer.resizeImageBySettings(
        size,
        context.options.pageSize.toInches(),
        context.options.margins.toInches(),
        imageDpi,
      );

      imgWidthEmu ??= resultSize.width?.toEmuFromInches();
      imgHeightEmu ??= resultSize.height?.toEmuFromInches();
    }

    return <XmlElement>[
      ...Anchor(
        component: Image(
          // should be unique by component
          // but, since blocks are just
          // wrappers of granular components
          // we assign to them the same id
          // to avoid sync issues with stores
          id: id,
          data: data,
          asInline: false,
        ),
        config: data.anchorConfig,
        widthEmu: imgWidthEmu!,
        parent: this,
        heightEmu: imgHeightEmu!,
        name: imageName,
        docPrId: docPrId!.toString(),
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
          buffer: Uint8List.fromList(data.buffer),
          extension: data.extension,
          anchorConfig: data.anchorConfig,
          styles: data.styles,
          width: data.width,
          height: data.height,
          alt: data.alt,
          name: data.name,
          unit: data.unit,
        ),
      );

  @override
  String toString() {
    return 'Image(id: $id, data: $data)';
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
