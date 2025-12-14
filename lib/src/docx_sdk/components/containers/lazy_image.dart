import 'dart:io';

import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';

class LazyImage extends ComponentContainer<LazyImageData> {
  LazyImage({
    required super.data,
    super.parent,
  });

  @override
  LazyImage get copy => LazyImage(
        data: LazyImageData(
          file: File(data.file.path),
          extension: data.extension,
          styles: data.styles,
          width: data.width,
          height: data.height,
        ),
      );

  String get getImageName => data.name ?? '';
  
  /// Whether we can use this image to any operation
  Future<bool> get canLoad async {
    return await data.file.exists();
  }

  @override
  XmlElement buildXml({required DocxComponentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${data.name}" couldn\'t be '
        'founded into the DocxComponentContext',
      );
    }
    final int docPrId =
        context.getMediaIdForImage(rId!) ?? context.generateMediaId();

    // Convert width/height to EMUs. Assuming data.width/height are in pixels or a known unit.
    // If they are in pixels, a common conversion to EMUs is to multiply by a factor (e.g., 914400 / 96 dpi to convert
    //  from pixels to EMUs if 96dpi is the resolution).
    // Here, we will assume that `computeTwip` can convert them to TWIPs or an appropriate unit, and then to EMUs.
    // Or if data.width/height are already in a base unit (e.g., points) and you need to convert to EMUs.
    // For simplicity, I will use a conversion factor to EMUs (e.g., 9525 EMUs per TWIP if the source is in TWIPs, or 12700 to convert from dxa to EMUs)
    // It is crucial that 'data.width' and 'data.height' have a defined base unit and you know what to convert them to.
    // For a basic example, if 'data.width' and 'data.height' were in pixels (96dpi), it would be:
    // final int imgWidthEmu = (data.width * 914400 / 96).round();
    // final int imgHeightEmu = (data.height * 914400 / 96).round();
    // If they are in TWIPs (1/20 of a point): 1pt = 20 TWIPs, 1 inch = 1440 TWIPs. 1 TWIP = 635 EMUs
    //
    // I swear to god that idk if this works properly
    final int imgWidthEmu = (data.width * 9525)
        .round(); // Example: if data.width is in dxa (1/20 of a point) or similar, this may need adjustment
    final int imgHeightEmu = (data.height * 9525)
        .round(); // 9525 EMU = 1 mm. If you want points, it's 12700 EMU = 1 pt.

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
                XmlAttribute(XmlName.fromString('xmlns:wp'), namespaces['wp']!),
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
                    XmlAttribute(XmlName.fromString('descr'), imageName),
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
                                    XmlAttribute(XmlName.fromString('id'),
                                        docPrId.toString()),
                                    XmlAttribute(XmlName.fromString('name'),
                                        imageName.removeAllWhitespaces()),
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
                                    XmlElement.tag('a:fillRect',
                                        isSelfClosing: true),
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
                                          '0',
                                        ),
                                        XmlAttribute(
                                          XmlName.fromString('y'),
                                          '0',
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
  List<XmlAttribute> buildXmlStyle({required DocxComponentContext context}) {
    return [];
  }

  @override
  String toString() {
    return 'LazyImage(id: $id, data: $data)';
  }

  @override
  LazyImage? visitElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<LazyImage>? visitAllElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <LazyImage>[this] : null;
  }
}

class LazyImageData {
  LazyImageData({
    required this.file,
    required this.extension,
    required this.width,
    required this.height,
    this.styles = const <TextRunAttribution>[],
  });

  final File file;
  final String extension;
  final double width;
  final double height;
  final List<TextRunAttribution> styles;
  String? name;

  @override
  String toString() {
    return 'ImageData(file: ${file.path}, extension: img.$extension, options: [width: $width, height: $height], styles: $styles)';
  }
}
