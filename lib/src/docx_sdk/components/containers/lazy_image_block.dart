import 'dart:io';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../mixins/ignorable_mixin.dart';
import '../drawing/drawing.dart';

class LazyImageBlock extends ComponentContainer<ImageData<File>>
    with IgnorableMixin {
  LazyImageBlock({
    required super.data,
    super.parent,
  });

  @override
  LazyImageBlock get copy => LazyImageBlock(
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
    try {
      final _ = ImageSizeGetter.getSizeResult(FileInput(data.buffer));
      // we need to verify even if the file exist
      return data.buffer.existsSync();
    } catch (ex) {
      return false;
    }
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      runParent(
        attributes: buildXmlStyle(context: context),
        children: <XmlNode>[
          ...Drawing(
            data: LazyImage(data: data),
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
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<LazyImageBlock>? visitAllElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <LazyImageBlock>[this] : null;
  }
}
