import 'dart:typed_data';

import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';
import '../../../../docx.dart';
import 'anchor.dart';

class ImageBlock extends ComponentContainer<ImageData<Uint8List>> {
  ImageBlock({
    required super.data,
    super.parent,
    super.id,
  });

  @override
  ImageBlock get copy => ImageBlock(
        id: id,
        data: ImageData<Uint8List>(
          buffer: Uint8List.fromList(data.buffer),
          extension: data.extension,
          styles: data.styles,
          width: data.width,
          height: data.height,
          offsetX: data.offsetX,
          offsetY: data.offsetY,
          alt: data.alt,
          name: data.name,
          unit: data.unit,
          frameAlignY: data.frameAlignY,
          frameOffsetY: data.frameOffsetY,
          frameOffsetX: data.frameOffsetX,
          frameAlignX: data.frameAlignX,
        ),
      );

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
    final String wrapType = data.wrapType();

    final int? zIndex = data.positioning == ImagePositioning.behindText
        ? -1
        : data.positioning == ImagePositioning.inFrontOfText
            ? 1
            : null;

    final int docPrId = context.store.getAssignedIdForRef(super.id) ??
        context.store.getAssignedIdForRef(rId!) ??
        context.store.generateMediaId();

    num? imgWidthEmu;
    num? imgHeightEmu;
    if (data.width != null) {
      imgWidthEmu = data.width!.toEmuFromUnit(data.unit);
    }
    if (data.height != null) {
      imgHeightEmu = data.height!.toEmuFromUnit(data.unit);
    }

    //TODO: we will need to create our own decoders for different
    // image extensions than jpeg, gif, png, webp, bmp.
    if (imgWidthEmu == null && imgHeightEmu == null) {
      final Uint8List bytes = data.buffer;
      final Size size = ImageSizeGetter.getSizeResult(MemoryInput(bytes)).size;
      imgWidthEmu = size.width * emuPerInch / imageDpi;
      imgHeightEmu = size.height * emuPerInch / imageDpi;
    }
    return <XmlElement>[
      super.runParent(
        attributes: buildXmlStyle(context: context),
        children: <XmlNode>[
          ...Drawing(
            data: data.hasGlobalOffset
                ? Anchor(
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
                    offsetX: data.offsetX,
                    offsetY: data.offsetY,
                    frameOffsetY: data.frameOffsetY,
                    frameOffsetX: data.frameOffsetX,
                    frameAlignY: data.frameAlignY,
                    frameAlignX: data.frameAlignX,
                    widthEmu: imgWidthEmu!,
                    heightEmu: imgHeightEmu!,
                    wrapType: wrapType,
                    name: imageName,
                    zIndex: zIndex,
                    docPrId: docPrId,
                  )
                : Image(
                    //NOTE: i'll repeat: 
                    // them should be unique by component
                    // but, since blocks are just
                    // wrappers of granular components
                    // we assign to them the same id
                    // to avoid sync issues with stores
                    id: id,
                    data: data,
                  ),
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
    return 'Image(id: $id, data: $data)';
  }

  @override
  ImageBlock? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<ImageBlock>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <ImageBlock>[this] : null;
  }
}
