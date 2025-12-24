import 'package:xml/xml.dart';

import '../../../../docx.dart';
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
class TextFrame extends ComponentContainer<Iterable<DocxContent>> {
  /// Creates a [TextFrame] instance.
  ///
  /// [data] is the iterable of [DocxContent] that will be placed inside the frame.
  /// This typically includes [Paragraph] or [TextRun] elements.
  /// [width] and [height] specify the dimensions of the frame in pixels (constructor computes the correct sizes automatically).
  /// [wrap] defines how text wraps around the frame.
  /// [vAnchor] and [hAnchor] define how the frame is anchored vertically and horizontally.
  /// [xAlign] and [yAlign] specify the horizontal and vertical alignment of the frame.
  /// [x] and [y] are optional absolute X and Y positions in twips.
  /// [border] is an optional map to define borders for the frame,
  /// similar to how paragraph borders are defined in [StyleBuilder].
  TextFrame({
    required Iterable<DocxContent> data,
    required int width,
    required int height,
    this.wrap = FrameWrap.auto,
    this.vAnchor = FrameAnchor.page,
    this.hAnchor = FrameAnchor.page,
    this.xAlign = FrameHorizontalAlignment.left,
    this.yAlign = FrameVerticalAlignment.top,
    this.x, // Optional absolute X position in twips
    this.y, // Optional absolute Y position in twips
    this.border, // Optional borders for the frame
  })  : width = width.toTwipsFromPixels96dpi(),
        height = height.toTwipsFromPixels96dpi(),
        super(data: data) {
    // Set parent for all children
    for (final DocxContent content in data) {
      content.parent = this;
    }
  }

  final int width;
  final int height;
  final FrameWrap wrap;
  final FrameAnchor vAnchor;
  final FrameAnchor hAnchor;
  final FrameHorizontalAlignment xAlign;
  final FrameVerticalAlignment yAlign;
  final int? x; // Absolute x position in twips
  final int? y; // Absolute y position in twips
  final Style? border; // Similar to StyleBuilder _borders

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlAttribute> frameAttributes = [
      XmlAttribute('w:w'.toName(), width.toString()),
      XmlAttribute('w:h'.toName(), height.toString()),
      XmlAttribute('w:wrap'.toName(), wrap.value),
      XmlAttribute('w:vAnchor'.toName(), vAnchor.value),
      XmlAttribute('w:hAnchor'.toName(), hAnchor.value),
      XmlAttribute('w:xAlign'.toName(), xAlign.value),
      XmlAttribute('w:yAlign'.toName(), yAlign.value),
      if (x != null) XmlAttribute('w:x'.toName(), x.toString()),
      if (y != null) XmlAttribute('w:y'.toName(), y.toString()),
    ];

    final List<XmlNode> paragraphPropertiesChildren = [
      // Add frame properties to paragraph properties

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

    final List<XmlNode> paragraphChildren = [];
    if (paragraphPropertiesChildren.isNotEmpty) {
      paragraphChildren.add(
        XmlElement.tag(
          xmlParagraphBlockAttrsNode, // Typically 'w:pPr'
          children: paragraphPropertiesChildren,
        ),
      );
    }

    // Add the content of the TextFrame (e.g., actual paragraphs, text runs)
    // directly as children of the w:p element that forms the frame.
    for (final DocxContent child in data) {
      final List<XmlNode> childXml = child.buildXml(context: context);
      paragraphChildren.addAll(childXml);
    }

    return [
      XmlElement.tag(
        xmlParagraphNode,
        children: paragraphChildren,
      ),
    ];
  }

  @override
  TextFrame get copy => TextFrame(
        data: data
            .map(
              (e) => e.copy,
            )
            .toList(),
        width: width,
        height: height,
        wrap: wrap,
        hAnchor: hAnchor,
        vAnchor: vAnchor,
        xAlign: xAlign,
        yAlign: yAlign,
        x: x,
        y: y,
        border: border,
      );

  @override
  List<DocxContent<dynamic>>? visitAllElement(
    bool Function(DocxContent<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (data.isEmpty) return <DocxContent<dynamic>>[];
    final List<DocxContent<dynamic>> elements = <DocxContent<dynamic>>[];
    for (final DocxContent element in data) {
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxContent<dynamic>>? foundedEl = element.visitAllElement(
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
  DocxContent<dynamic>? visitElement(
    bool Function(DocxContent<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    for (final DocxContent element in data) {
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxContent<dynamic>? foundedEl = element.visitElement(
          shouldGetElement,
        );
        if (foundedEl != null) {
          return foundedEl;
        }
      }
    }
    return null;
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
              [];
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
}
