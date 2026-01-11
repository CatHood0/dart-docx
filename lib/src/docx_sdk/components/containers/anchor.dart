import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../core/extensions/string_ext.dart';

/// Anchor element for floating content positioning.
///
/// Represents the `wp:anchor` element in DrawingML, used to position
/// floating content (images, shapes) independently of text flow.
/// Anchors provide precise control over positioning, wrapping behavior,
/// and layering of floating elements.
///
/// Anchors support various positioning modes:
/// - Relative to page margins
/// - Relative to paragraph bounds
/// - Relative to specific characters
/// - Absolute page coordinates
///
/// Example usage:
/// ```dart
/// final anchor = Anchor(
///   component: myImage,
///   widthEmu: 2000000,
///   heightEmu: 1500000,
///   name: 'Floating Image',
///   config: AnchorConfig.block(),
/// );
/// ```
class Anchor extends DocxTreeNode<DocxTreeNode> with IgnorableMixin {
  Anchor({
    required DocxTreeNode component,
    required this.widthEmu,
    required this.heightEmu,
    required this.name,
    this.elementId,
    required this.config,
    super.parent,
    super.id,
  }) : super(data: component) {
    data
      ..parent = this
      ..index = 0
      ..depth = depth + 1;
  }

  int? elementId;
  final String name;
  final AnchorConfig config;

  final num widthEmu;
  final num heightEmu;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    elementId ??= context.drawingStore.getNextId(id);
    return <XmlElement>[
      XmlElement.tag(
        'wp:anchor',
        attributes: <XmlAttribute>[
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
            attributes: <XmlAttribute>{
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
              alignment: config.horizontalPosition?.name,
              relativeFrom: config.horizontalAnchor.name,
              x: true,
            ).buildXml(context),
          if (config.wrapType != WrapType.asCharacter)
            XmlOffsetPosition(
              offset: config.anchorOffsetY.nonNegative,
              alignment: config.verticalPosition?.name,
              relativeFrom: config.verticalAnchor.name,
              x: false,
            ).buildXml(context),
          if ((config.wrapType != WrapType.noWrap) &&
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
            docPrId: elementId.toString(),
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
        elementId: elementId,
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

/// XML component for precise positioning of floating elements.
///
/// Represents either `wp:positionH` (horizontal) or `wp:positionV` (vertical)
/// positioning elements in DrawingML. Used for precise placement of
/// floating images and shapes relative to various reference points.
///
/// Example usage:
/// ```dart
/// final position = XmlOffsetPosition(
///   relativeFrom: 'margin',
///   alignment: 'center',
///   x: true,
/// );
/// ```
class XmlOffsetPosition extends XmlComponentBase<void> {
  XmlOffsetPosition({
    required this.relativeFrom,
    required bool x,
    this.alignment,
    this.offset,
  }) : super(
          xmlKey: x ? 'wp:positionH' : 'wp:positionV',
          value: null,
        );

  /// Reference point for positioning:
  /// - "margin": Relative to page margins
  /// - "page": Absolute page position
  /// - "column": Within text column
  /// - "character": Relative to specific character
  /// - "paragraph": Relative to paragraph bounds
  final String relativeFrom;

  /// Numeric offset in EMU units (used when no alignment specified)
  final num? offset;

  /// Text alignment: "left", "center", "right", "inside", "outside"
  /// (takes precedence over offset when both are provided)
  final String? alignment;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      isSelfClosing: false,
      attributes: <XmlAttribute>[
        XmlAttribute(
          'relativeFrom'.toName(),
          relativeFrom,
        ),
      ],
      children: <XmlNode>[
        // if offset is null, then we require alignment
        // if offset isnt null, then we always will prefer
        // precise positioning over alignment
        if (alignment != null && alignment!.isNotEmpty && offset == null)
          XmlElement.tag(
            'wp:align',
            children: <XmlNode>[
              XmlText(alignment ?? AnchorPosition.left.name),
            ],
          )
        else
          XmlElement.tag(
            'wp:posOffset',
            children: <XmlNode>[
              XmlText(offset!.toString()),
            ],
          ),
      ],
    );
  }
}
