import 'dart:io';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../mixins/ignorable_mixin.dart';
import 'anchor.dart';

class LazyImageBlock extends ComponentContainer<ImageData<File>>
    with IgnorableMixin {
  LazyImageBlock({
    required super.data,
    super.parent,
    super.id,
  });

  @override
  LazyImageBlock get copy => LazyImageBlock(
        id: id,
        data: ImageData(
          buffer: File(data.buffer.path),
          extension: data.extension,
          styles: data.styles,
          width: data.width,
          height: data.height,
          name: data.name,
          offsetX: data.offsetX,
          offsetY: data.offsetY,
          alt: data.alt,
          unit: data.unit,
          frameOffsetY: data.frameOffsetY,
          frameAlignY: data.frameAlignY,
          frameOffsetX: data.frameOffsetX,
          frameAlignX: data.frameAlignX,
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
      final Size size =
          ImageSizeGetter.getSizeResult(FileInput(data.buffer)).size;
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
                    component: LazyImage(
                      // should be unique by component
                      // by, since blocks are just
                      // wrappers of granular components
                      // we assign to them the same id
                      // to avoid sync issues with stores
                      id: id,
                      data: data,
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
                : LazyImage(
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
    return 'LazyImage(id: $id, data: $data)';
  }

  @override
  LazyImageBlock? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<LazyImageBlock>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <LazyImageBlock>[this] : null;
  }
}
