import 'dart:typed_data';

import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../drawing/drawing.dart';

class ImageBlock extends ComponentContainer<ImageData<Uint8List>> {
  ImageBlock({
    required super.data,
    super.parent,
  });

  @override
  ImageBlock get copy => ImageBlock(
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
    return <XmlElement>[
      runParent(
        attributes: buildXmlStyle(context: context),
        children: <XmlNode>[
          ...Drawing(
            data: Image(data: data),
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
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<ImageBlock>? visitAllElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <ImageBlock>[this] : null;
  }
}
