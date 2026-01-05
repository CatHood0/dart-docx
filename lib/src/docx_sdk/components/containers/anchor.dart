import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/extensions/string_ext.dart';
import '../../mixins/ignorable_mixin.dart';

class Anchor extends DocxTreeNode<DocxTreeNode> with IgnorableMixin {
  Anchor({
    required DocxTreeNode component,
    required this.widthEmu,
    required this.heightEmu,
    required this.name,
    required this.docPrId,
    required this.config,
    super.parent,
    super.id,
  }) : super(data: component) {
    data
      ..parent = this
      ..index = 0
      ..depth = depth + 1;
  }

  final Object docPrId;
  final String name;
  final AnchorConfig config;

  final num widthEmu;
  final num heightEmu;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'wp:anchor',
        attributes: [
          XmlAttribute(
            XmlName.fromString('behindDoc'),
            config.zOrder.toString(),
          ),
          XmlAttribute(
            'distT'.toName(),
            config.distanceFromText.top.toString(),
          ),
          XmlAttribute(
            'distB'.toName(),
            config.distanceFromText.bottom.toString(),
          ),
          XmlAttribute(
            'distL'.toName(),
            config.distanceFromText.left.toString(),
          ),
          XmlAttribute(
            'distR'.toName(),
            config.distanceFromText.right.toString(),
          ),
          XmlAttribute(
            XmlName.fromString('locked'),
            config.anchorLock.toInt().toString(),
          ),
          XmlAttribute(
            XmlName.fromString('layoutInCell'),
            config.layoutInCell.toInt().toString(),
          ),
          XmlAttribute(
            XmlName.fromString('allowOverlap'),
            config.allowOverlap.toInt().toString(),
          ),
        ],
        children: <XmlNode>[
          XmlElement.tag(
            'w:simplePos',
            attributes: {
              XmlAttribute(
                'x'.toName(),
                config.simplePosX.nonNegative.toString(),
              ),
              XmlAttribute(
                'y'.toName(),
                config.simplePosY.nonNegative.toString(),
              ),
            },
            isSelfClosing: true,
          ),
          // external offsets
          if (config.wrapType != WrapType.asCharacter)
            XmlOffsetPosition(
              offset: config.anchorOffsetX.nonNegative,
              alignment: config.horizontalAlign?.name,
              relativeFrom: config.horizontalAnchor.name,
              x: true,
            ).buildXml(context),
          if (config.wrapType != WrapType.asCharacter)
            XmlOffsetPosition(
              offset: config.anchorOffsetY.nonNegative,
              alignment: config.verticalAlign?.name,
              relativeFrom: config.verticalAnchor.name,
              x: false,
            ).buildXml(context),
          if (config.wrapType != WrapType.none &&
              config.wrapType != WrapType.asCharacter)
            XmlElement.tag(
              'wp:wrap${config.wrapType.name.capitalize()}',
              isSelfClosing: true,
              attributes: <XmlAttribute>[
                if (config.wrapSide != null)
                  XmlAttribute(
                    XmlName.fromString('wrapText'),
                    config.wrapSide!.name,
                  ),
              ],
            ),
          XmlElement.tag(
            'wp:cNvGraphicFramePr',
            isSelfClosing: true,
          ),
          ...Extent(
            cx: widthEmu,
            cy: heightEmu,
          ).buildXml(context: context),
          ...DocProperties(
            docPrId: docPrId.toString(),
            name: name.toString(),
            relativeHeight: '0',
          ).buildXml(context: context),
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
        config: config,
        parent: parent,
        widthEmu: widthEmu,
        heightEmu: heightEmu,
        name: name,
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
