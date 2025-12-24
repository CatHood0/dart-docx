import 'dart:io';

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';
import '../../mixins/ignorable_mixin.dart';

class LazyImage extends ComponentContainer<ImageData<File>> with IgnorableMixin {
  LazyImage({
    required super.data,
    super.parent,
  });

  @override
  LazyImage get copy => LazyImage(
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
  XmlElement buildXml({required DocumentContext context}) {
    final String imageName = getImageName;
    if (imageName.isEmpty) {
      throw Exception(
        'The image "${data.name}" couldn\'t be '
        'founded into the DocxComponentContext',
      );
    }
    final String wrapType = data.wrapType();

    // Configurar z-order para delante/detrás del texto
    final int? zIndex = data.positioning == ImagePositioning.behindText
        ? -1
        : data.positioning == ImagePositioning.inFrontOfText
            ? 1
            : null;

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
      final Size size =
          ImageSizeGetter.getSizeResult(FileInput(data.buffer)).size;
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
                XmlAttribute(XmlName.fromString('simplePos'), '0'),
                XmlAttribute(XmlName.fromString('relativeHeight'), '0'),
                XmlAttribute(
                  XmlName.fromString('behindDoc'),
                  data.positioning == ImagePositioning.behindText ? '1' : '0',
                ),
                XmlAttribute(XmlName.fromString('locked'), '0'),
                XmlAttribute(XmlName.fromString('layoutInCell'), '1'),
                XmlAttribute(XmlName.fromString('allowOverlap'), '1'),
              ],
              children: <XmlNode>[
                XmlElement.tag(
                  'wp:simplePos',
                  attributes: [
                    XmlAttribute(XmlName.fromString('x'), '0'),
                    XmlAttribute(XmlName.fromString('y'), '0'),
                  ],
                  isSelfClosing: true,
                ),
                // external offsets
                XmlOffsetPosition(
                  x: true,
                  alignment: data.frameAlignX,
                  offset: data.offsetX,
                ).buildXml(context),
                XmlOffsetPosition(
                  x: false,
                  alignment: data.frameAlignY,
                  offset: data.offsetY,
                ).buildXml(context),
                XmlElement.tag(
                  'wp:wrap${wrapType.capitalize()}',
                  isSelfClosing: true,
                  attributes: [
                    if (wrapType == 'square' || wrapType == 'tight')
                      XmlAttribute(
                        XmlName.fromString('wrapText'),
                        'bothSides',
                      ),
                  ],
                ),
                XmlElement.tag(
                  'wp:extent',
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
                    if (zIndex != null)
                      XmlAttribute(
                        XmlName.fromString('relativeHeight'),
                        zIndex.toString(),
                      ),
                  ],
                ),
                XmlElement.tag(
                  'wp:cNvGraphicFramePr',
                  isSelfClosing: true,
                ),
                _buildGraphicContent(
                  docPrId: docPrId,
                  imageName: imageName,
                  imgWidthEmu: imgWidthEmu!,
                  imgHeightEmu: imgHeightEmu!,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  XmlElement _buildGraphicContent({
    required int docPrId,
    required String imageName,
    required num imgWidthEmu,
    required num imgHeightEmu,
  }) {
    return XmlElement.tag(
      'a:graphic',
      isSelfClosing: false,
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
                          imageName,
                        ),
                      ],
                    ),
                    XmlElement.tag(
                      'pic:cNvPicPr',
                      isSelfClosing: true,
                    ),
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
                              data.frameOffsetX.toString(),
                            ),
                            XmlAttribute(
                              XmlName.fromString('y'),
                              data.frameOffsetY.toString(),
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
                        XmlElement.tag(
                          'a:avLst',
                          isSelfClosing: true,
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
