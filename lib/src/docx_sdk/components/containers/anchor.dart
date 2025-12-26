import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/extensions/string_ext.dart';
import '../../mixins/ignorable_mixin.dart';

class Anchor extends DocxTreeNode<DocxTreeNode> with IgnorableMixin {
  Anchor({
    required DocxTreeNode component,
    required this.offsetX,
    required this.offsetY,
    required this.frameOffsetY,
    required this.frameOffsetX,
    required this.frameAlignY,
    required this.frameAlignX,
    required this.widthEmu,
    required this.heightEmu,
    required this.wrapType,
    required this.name,
    required this.zIndex,
    required this.docPrId,
    this.simplePosX = 0,
    this.simplePosY = 0,
    this.relativeFrom = Anchor.relativeParagraphKey,
    super.parent,
    super.id,
  }) : super(data: component) {
    data
      ..parent = this
      ..index = 0
      ..depth = depth + 1;
  }

  int simplePosX;
  int simplePosY;
  String relativeFrom;
  String wrapType;
  Object docPrId;
  String name;
  int? zIndex;

  num widthEmu;
  num heightEmu;

  /// Global horizontal offset applied to the whole document
  int offsetX;

  /// Global vertical offset applied to the whole document
  int offsetY;

  ImagePositioning positioning = ImagePositioning.inline;

  /// Internal Vertical offset applied only to the box where the image is painted
  int? frameOffsetY;

  /// Internal Horizontal offset applied only to the box where the image is
  int? frameOffsetX;

  /// Internal Vertical alignment applied to the box where the image is
  String frameAlignY;

  /// Internal Horizontal alignment applied to the box where the image is
  String frameAlignX;

  static const String relativeColumnKey = 'column';
  static const String relativeParagraphKey = 'paragraph';

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    return <XmlNode>[
      XmlElement.tag(
        'wp:anchor',
        attributes: [
          XmlAttribute(XmlName.fromString('simplePos'), '0'),
          if (zIndex != null)
            XmlAttribute(
              XmlName.fromString('relativeHeight'),
              zIndex.toString(),
            ),
          XmlAttribute(
            XmlName.fromString('behindDoc'),
            positioning == ImagePositioning.behindText ? '1' : '0',
          ),
          XmlAttribute(XmlName.fromString('locked'), '0'),
          XmlAttribute(XmlName.fromString('layoutInCell'), '1'),
          XmlAttribute(XmlName.fromString('allowOverlap'), '1'),
        ],
        children: <XmlNode>[
          XmlElement.tag(
            'w:simplePos',
            attributes: {
              XmlAttribute(
                'x'.toName(),
                simplePosX.nonNegative.toString(),
              ),
              XmlAttribute(
                'y'.toName(),
                simplePosY.nonNegative.toString(),
              ),
            },
            isSelfClosing: true,
          ),
          // external offsets
          if (offsetX > 0)
            XmlOffsetPosition(
              x: true,
              alignment: frameAlignX,
              offset: offsetX,
            ).buildXml(context),
          if (offsetY > 0)
            XmlOffsetPosition(
              x: false,
              alignment: frameAlignY,
              offset: offsetY,
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
            'wp:cNvGraphicFramePr',
            isSelfClosing: true,
          ),
          XmlElement.tag(
            'wp:extent',
            attributes: [
              XmlAttribute(
                XmlName.fromString('cx'),
                widthEmu.toString(),
              ),
              XmlAttribute(
                XmlName.fromString('cy'),
                heightEmu.toString(),
              ),
            ],
            isSelfClosing: true,
          ),
          XmlElement.tag(
            'wp:docPr',
            isSelfClosing: true,
            attributes: [
              XmlAttribute(XmlName.fromString('id'), docPrId.toString()),
              XmlAttribute(XmlName.fromString('name'), name),
              XmlAttribute(
                XmlName.fromString('descr'),
                name,
              ),
              if (zIndex != null)
                XmlAttribute(
                  XmlName.fromString('relativeHeight'),
                  zIndex.toString(),
                ),
            ],
          ),
          ...data.buildXml(context: context),
        ],
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  Anchor get copy => Anchor(
        id: id,
        component: data,
        simplePosX: simplePosX,
        simplePosY: simplePosY,
        relativeFrom: relativeFrom,
        parent: parent,
        offsetX: offsetX,
        offsetY: offsetY,
        frameOffsetY: frameOffsetY,
        frameOffsetX: frameOffsetX,
        frameAlignY: frameAlignY,
        frameAlignX: frameAlignX,
        widthEmu: widthEmu,
        heightEmu: heightEmu,
        wrapType: wrapType,
        name: name,
        zIndex: zIndex,
        docPrId: docPrId,
      );

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? <DocxTreeNode<dynamic>>[this]
        : !visitChildrenIfNeeded
            ? null
            : data.visitAllElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? this
        : !visitChildrenIfNeeded
            ? null
            : data.visitElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  bool shouldIgnore() {
    return data is IgnorableMixin && (data as IgnorableMixin).shouldIgnore();
  }
}
