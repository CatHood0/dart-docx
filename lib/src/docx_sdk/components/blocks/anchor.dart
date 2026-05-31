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
class Anchor extends DocxNode<DocxNode> with IgnorableMixin {
  Anchor({
    required super.child,
    required this.width,
    required this.height,
    required this.name,
    required this.config,
    this.elementId,
    super.parent,
    super.id,
  }) {
    child
      ..parent = this
      ..index = 0;
  }

  int? elementId;
  final String name;
  final AnchorConfig config;

  /// The [width] of the elemento into this [Anchor]
  /// expressed in EMU units
  final UnitValue width;

  /// The [height] of the elemento into this [Anchor]
  /// expressed in EMU units
  final UnitValue height;

  @override
  List<XmlElement> buildXml() {
    elementId ??= DrawingCounterProvider.of(this).getNextId(id);
    return <XmlElement>[
      XmlElement.tag(
        'wp:anchor',
        attributes: <XmlAttribute>[
          // required for standard
          //TODO: decide what we will do with this
          XmlAttribute(
            XmlName.fromString('relativeHeight'),
            '0',
          ),
          XmlAttribute(
            XmlName.fromString('behindDoc'),
            config.zOrder.toString(),
          ),
          XmlAttribute(
            'distT'.toName(),
            config.distanceFromText.top.toEmu().toString(),
          ),
          XmlAttribute(
            'distB'.toName(),
            config.distanceFromText.bottom.toEmu().toString(),
          ),
          XmlAttribute(
            'distL'.toName(),
            config.distanceFromText.left.toEmu().toString(),
          ),
          XmlAttribute(
            'distR'.toName(),
            config.distanceFromText.right.toEmu().toString(),
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
          // required position to pass
          // every validation
          ...Extent(
            cx: width,
            cy: height,
          ).buildXml(),
          XmlElement.tag(
            'wp:simplePos',
            attributes: <XmlAttribute>{
              XmlAttribute(
                'x'.toName(),
                config.simplePosX.toEmu().nonNegative.toString(),
              ),
              XmlAttribute(
                'y'.toName(),
                config.simplePosY.toEmu().nonNegative.toString(),
              ),
            },
            isSelfClosing: true,
          ),
          // external offsets
          if (config.wrapType != WrapType.asCharacter)
            XmlOffsetPosition(
              offset: config.anchorOffsetX.toEmu().nonNegative,
              alignment: config.horizontalPosition?.name,
              relativeFrom: config.horizontalAnchor.name,
              x: true,
            ).buildXml(),
          if (config.wrapType != WrapType.asCharacter)
            XmlOffsetPosition(
              offset: config.anchorOffsetY.toEmu().nonNegative,
              alignment: config.verticalPosition?.name,
              relativeFrom: config.verticalAnchor.name,
              x: false,
            ).buildXml(),
          if ((config.wrapType != WrapType.noWrap) && config.wrapType != WrapType.asCharacter)
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

          // XmlElement.tag(
          //   'wp:cNvGraphicFramePr',
          //   isSelfClosing: true,
          // ),
          ...DocProperties(
            docPrId: elementId.toString(),
            name: name.toString(),
          ).buildXml(),
          ...child.buildXml(),
        ],
      ),
    ];
  }

  @override
  Anchor get copy => Anchor(
        id: id,
        child: child,
        config: config,
        parent: parent,
        width: width,
        height: height,
        name: name,
        elementId: elementId,
      );

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? <DocxNode<dynamic>>[this]
        : !visitChildrenIfNeeded
            ? null
            : child.visitAllElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? this
        : !visitChildrenIfNeeded
            ? null
            : child.visitElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  bool shouldIgnore() {
    return child is IgnorableMixin && (child as IgnorableMixin).shouldIgnore();
  }

  @override
  Anchor copyWith({
    DocxNode? child,
    int? elementId,
    String? name,
    UnitValue? width,
    UnitValue? height,
    AnchorConfig? config,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return Anchor(
      child: child ?? this.child,
      id: id ?? this.id,
      name: name ?? this.name,
      elementId: elementId ?? this.elementId,
      width: width ?? this.width,
      height: height ?? this.height,
      config: config ?? this.config,
      parent: parent ?? this.parent,
    );
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
  XmlElement buildXml() {
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
