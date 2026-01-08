import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../../core/extensions/string_ext.dart';

/// Represents a text frame within the Word document.
///
/// A TextFrame allows its content (typically paragraphs) to be positioned
/// independently from the main text flow, similar to a floating text box.
///
/// The content inside a [TextFrame] is rendered as a special paragraph
/// (`<w:p>`) with frame properties (`<w:framePr>`).
///
/// Note: The internal implementation treats the frame's content as part
/// of a single paragraph that has frame properties.
class TextFrame extends ComponentContainer<Iterable<DocxTreeNode>> {
  /// Creates a [TextFrame] instance.
  ///
  /// [data] is the iterable of [DocxTreeNode] that will be placed inside the frame.
  /// This typically includes [Paragraph] or [TextRun] elements.
  /// [width] and [height] specify the dimensions of the frame in pixels (constructor computes the correct sizes automatically).
  /// [wrap] defines how text wraps around the frame.
  /// [vAnchor] and [hAnchor] define how the frame is anchored vertically and horizontally.
  /// [xAlign] and [yAlign] specify the horizontal and vertical alignment of the frame.
  /// [offsetX] and [offsetY] are optional absolute X and Y positions in twips.
  /// [border] is an optional map to define borders for the frame,
  /// similar to how paragraph borders are defined in [StyleBuilder].
  TextFrame({
    required Iterable<DocxTreeNode> data,
    required int width,
    required int height,
    super.id,
    this.wrap = FrameWrap.auto,
    this.vAnchor = VerticalAnchorPosition.page,
    this.hAnchor = HorizontalAnchorPosition.page,
    this.xAlign = AnchorPosition.left,
    this.yAlign = AnchorPosition.top,
    this.offsetX, // Optional absolute X position in twips
    this.offsetY, // Optional absolute Y position in twips
    this.border, // Optional borders for the frame
  })  : width = width.toTwipsFromPixels96dpi(),
        height = height.toTwipsFromPixels96dpi(),
        super(data: data) {
    // Set parent for all children

    int index = 0;
    for (final DocxTreeNode<dynamic> content in data) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  final int width;
  final int height;
  final FrameWrap wrap;
  final VerticalAnchorPosition vAnchor;
  final HorizontalAnchorPosition hAnchor;
  final AnchorPosition xAlign;
  final AnchorPosition yAlign;
  final int? offsetX;
  final int? offsetY;
  final Style? border;

  @override
  TextFrame get copy => TextFrame(
        id: id,
        data: data
            .map(
              (DocxTreeNode<dynamic> e) => e.copy,
            )
            .toList(),
        width: width,
        height: height,
        wrap: wrap,
        hAnchor: hAnchor,
        vAnchor: vAnchor,
        xAlign: xAlign,
        yAlign: yAlign,
        offsetX: offsetX,
        offsetY: offsetY,
        border: border,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlAttribute> frameAttributes = <XmlAttribute>[
      XmlAttribute('w:w'.toName(), width.toString()),
      XmlAttribute('w:h'.toName(), height.toString()),
      XmlAttribute('w:wrap'.toName(), wrap.value),
      XmlAttribute('w:vAnchor'.toName(), vAnchor.xmlValue),
      XmlAttribute('w:hAnchor'.toName(), hAnchor.xmlValue),
      XmlAttribute('w:xAlign'.toName(), xAlign.xmlValue),
      XmlAttribute('w:yAlign'.toName(), yAlign.xmlValue),
      if (offsetX != null) XmlAttribute('w:x'.toName(), offsetX.toString()),
      if (offsetY != null) XmlAttribute('w:y'.toName(), offsetY.toString()),
    ];

    final List<XmlNode> paragraphPropertiesChildren = <XmlNode>[
      XmlElement.tag(
        'w:framePr',
        attributes: frameAttributes,
        isSelfClosing: true,
      ),
    ];

    final List<XmlNode> borderConfigs = buildXmlStyle(context: context);

    if (borderConfigs.isNotEmpty) {
      paragraphPropertiesChildren.add(
        XmlElement.tag(
          'w:pBdr',
          children: borderConfigs,
        ),
      );
    }

    final List<XmlNode> paragraphChildren = <XmlNode>[];
    if (paragraphPropertiesChildren.isNotEmpty) {
      paragraphChildren.add(
        XmlElement.tag(
          xmlParagraphBlockAttrsNode,
          children: paragraphPropertiesChildren,
        ),
      );
    }

    // Add the content of the TextFrame (e.g., actual paragraphs, text runs)
    // directly as children of the w:p element that forms the frame.
    for (final DocxTreeNode child in data) {
      final List<XmlNode> element = child.buildXml(context: context);
      if (child is IgnorableMixin &&
              child.cast<IgnorableMixin>().shouldIgnore() ||
          element.isEmpty) {
        continue;
      }
      paragraphChildren.addAll(element);
    }

    return <XmlElement>[
      XmlElement.tag(
        xmlParagraphNode,
        children: paragraphChildren,
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    final List<XmlNode> borderConfigs = <XmlNode>[];
    if (border != null) {
      final StyleConfigurator? pBdrConfig =
          border!.getConfiguratorOrNull('w:pBdr', fullName: true);
      if (pBdrConfig != null && pBdrConfig.hasChildren) {
        for (final StyleConfigurator borderChild in pBdrConfig.configurators) {
          final List<XmlAttribute> attrs = borderChild.attributes?.entries.map((
                MapEntry<String, dynamic> entry,
              ) {
                final String attrName = entry.key.contains(
                  ':',
                )
                    ? entry.key
                    : 'w:${entry.key}';
                return XmlAttribute(
                  attrName.toName(),
                  entry.value.toString(),
                );
              }).toList() ??
              <XmlAttribute>[];
          // Add w:val attribute if value is present
          if (borderChild.value != null) {
            attrs.add(
              XmlAttribute(
                'w:val'.toName(),
                borderChild.value.toString(),
              ),
            );
          }

          borderConfigs.add(
            XmlElement.tag(
              borderChild.qualifiedName, // e.g., <w:left>
              attributes: attrs,
              isSelfClosing: true,
            ),
          );
        }
      }
    }
    return borderConfigs;
  }

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (data.isEmpty) return <DocxTreeNode<dynamic>>[];
    final List<DocxTreeNode<dynamic>> elements = <DocxTreeNode<dynamic>>[];
    for (final DocxTreeNode element in data) {
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxTreeNode<dynamic>>? foundedEl = element.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          elements.addAll(foundedEl);
        }
      }
    }
    return elements;
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    for (final DocxTreeNode element in data) {
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxTreeNode<dynamic>? foundedEl = element.visitElement(
          shouldGetElement,
        );
        if (foundedEl != null) {
          return foundedEl;
        }
      }
    }
    return null;
  }
}
