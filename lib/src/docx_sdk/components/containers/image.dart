import 'package:flutter/foundation.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/namespaces.dart';
import '../../sdk.dart';
import '../../utils/image_utils.dart';

class Image extends ComponentContainer<ImageData<Uint8List>> {
  Image({
    required super.data,
    super.parent,
  });

  @override
  Image get copy => Image(
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
          verticalOffset: data.verticalOffset,
          verticalAlign: data.verticalAlign,
          horizontalOffset: data.horizontalOffset,
          horizontalAlign: data.horizontalAlign,
        ),
      );

  String get getImageName => data.name ?? '';

  @override
  XmlElement buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${data.name}" couldn\'t be '
        'founded into the DocxComponentContext',
      );
    }
    final int docPrId = context.store.getMediaIdForRef(super.id) ??
        context.store.getMediaIdForRef(rId!) ??
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

    return runParent(
      attributes: buildXmlStyle(context: context),
      children: <XmlNode>[
        XmlElement.tag(
          'w:drawing',
          isSelfClosing: false,
          children: <XmlNode>[
            XmlElement.tag(
              'wp:inline',
              isSelfClosing: false,
              attributes: [
                XmlAttribute(XmlName.fromString('distT'), '0'),
                XmlAttribute(XmlName.fromString('distB'), '0'),
                XmlAttribute(XmlName.fromString('distL'), '0'),
                XmlAttribute(XmlName.fromString('distR'), '0'),
              ],
              children: <XmlNode>[
                XmlElement.tag(
                  'wp:extent',
                  attributes: [
                    XmlAttribute(
                        XmlName.fromString('cx'), imgWidthEmu.toString()),
                    XmlAttribute(
                        XmlName.fromString('cy'), imgHeightEmu.toString()),
                  ],
                  isSelfClosing: true,
                ),
                XmlElement.tag(
                  'wp:docPr',
                  isSelfClosing: true,
                  attributes: [
                    XmlAttribute(XmlName.fromString('id'), docPrId.toString()),
                    XmlAttribute(XmlName.fromString('name'), imageName),
                    XmlAttribute(
                      XmlName.fromString('descr'),
                      data.alt ?? imageName,
                    ),
                  ],
                ),
                XmlElement.tag(
                  'a:graphic',
                  isSelfClosing: false,
                  attributes: [
                    XmlAttribute(
                        XmlName.fromString('xmlns:a'), namespaces['a']!),
                  ],
                  children: [
                    XmlElement.tag(
                      'a:graphicData',
                      isSelfClosing: false,
                      attributes: [
                        XmlAttribute(
                          XmlName.fromString('uri'),
                          'http://schemas.openxmlformats.org/drawingml/2006/picture',
                        ),
                      ],
                      children: [
                        XmlElement.tag(
                          'pic:pic',
                          isSelfClosing: false,
                          attributes: [
                            XmlAttribute(
                              XmlName.fromString('xmlns:pic'),
                              'http://schemas.openxmlformats.org/drawingml/2006/picture',
                            ),
                          ],
                          children: [
                            XmlElement.tag(
                              'pic:nvPicPr',
                              isSelfClosing: false,
                              children: [
                                XmlElement.tag(
                                  'pic:cNvPr',
                                  isSelfClosing: true,
                                  attributes: [
                                    XmlAttribute(
                                      XmlName.fromString('id'),
                                      docPrId.toString(),
                                    ),
                                    XmlAttribute(
                                      XmlName.fromString('name'),
                                      imageName.removeAllWhitespaces(),
                                    ),
                                  ],
                                ),
                                XmlElement.tag('pic:cNvPicPr',
                                    isSelfClosing: true),
                              ],
                            ),
                            XmlElement.tag(
                              'pic:blipFill',
                              isSelfClosing: false,
                              children: [
                                XmlElement.tag(
                                  'a:blip',
                                  attributes: [
                                    XmlAttribute(
                                      XmlName.fromString('r:embed'),
                                      rId!,
                                    ),
                                  ],
                                  isSelfClosing: true,
                                ),
                                XmlElement.tag(
                                  'a:stretch',
                                  isSelfClosing: false,
                                  children: [
                                    XmlElement.tag(
                                      'a:fillRect',
                                      isSelfClosing: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            XmlElement.tag(
                              'pic:spPr',
                              isSelfClosing: false,
                              children: [
                                XmlElement.tag(
                                  'a:xfrm',
                                  isSelfClosing: false,
                                  children: [
                                    XmlElement.tag(
                                      'a:off',
                                      isSelfClosing: true,
                                      attributes: [
                                        XmlAttribute(
                                          XmlName.fromString('x'),
                                          data.hasOffset
                                              ? data.offsetX.toString()
                                              : '0',
                                        ),
                                        XmlAttribute(
                                          XmlName.fromString('y'),
                                          data.hasOffset
                                              ? data.offsetY.toString()
                                              : '0',
                                        ),
                                      ],
                                    ),
                                    XmlElement.tag(
                                      'a:ext',
                                      isSelfClosing: true,
                                      attributes: [
                                        XmlAttribute(
                                          XmlName.fromString('cx'),
                                          imgWidthEmu.toString(),
                                        ),
                                        XmlAttribute(
                                          XmlName.fromString('cy'),
                                          imgHeightEmu.toString(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                XmlElement.tag(
                                  'a:prstGeom',
                                  isSelfClosing: false,
                                  attributes: [
                                    XmlAttribute(
                                      XmlName.fromString('prst'),
                                      'rect',
                                    ),
                                  ],
                                  children: [
                                    XmlElement.tag('a:avLst',
                                        isSelfClosing:
                                            true), // a:avLst es autocerrado
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
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
  Image? visitElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<Image>? visitAllElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <Image>[this] : null;
  }
}
