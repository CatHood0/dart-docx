import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';
import '../../../../core/extensions/string_ext.dart';

/// Text box container within a shape (wps:txbx).
///
/// Allows adding formatted text content inside a shape, with configurable
/// margins, wrapping behavior, and vertical/horizontal alignment.
class ShapeTextBox extends DocxTreeNode<ShapeTextBoxData> {
  ShapeTextBox({required super.child});

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> children = <XmlNode>[];
    for (final DocxTreeNode<dynamic> element in child.content) {
      if (element is IgnorableMixin &&
          element.cast<IgnorableMixin>().shouldIgnore()) {
        continue;
      }
      context.currentContentPart = element;
      children.addAll(element.buildXml(context: context));
    }
    context.currentContentPart = this;
    final XmlElement textBoxElement = XmlElement.tag(
      'wps:txbx',
      children: <XmlNode>[
        // Rich text content inside the text box
        XmlElement.tag(
          'w:txbxContent',
          children: children,
        ),
      ],
    );

    // Body properties control text wrapping and margins
    final XmlElement bodyProperties = XmlElement.tag(
      'a:bodyPr',
      attributes: <XmlAttribute>[
        XmlAttribute(
          'wrap'.toName(),
          child.wrapping.name,
        ),
        XmlAttribute(
          'vert'.toName(),
          _verticalAlignToXml(child.verticalAlignment),
        ),
        XmlAttribute(
          'horz'.toName(),
          _horizontalAlignToXml(child.horizontalAlignment),
        ),
      ],
      children: _buildInsets(child.margin),
      isSelfClosing: child.margin.left == 0 &&
          child.margin.top == 0 &&
          child.margin.right == 0 &&
          child.margin.bottom == 0,
    );

    return <XmlElement>[
      textBoxElement,
      bodyProperties,
    ];
  }

  List<XmlNode> _buildInsets(EdgeInsets margin) {
    if (margin.left == 0 &&
        margin.top == 0 &&
        margin.right == 0 &&
        margin.bottom == 0) {
      return <XmlNode>[];
    }

    return <XmlNode>[
      XmlElement.tag(
        'a:ins',
        attributes: <XmlAttribute>[
          XmlAttribute('l'.toName(), margin.left.toString()),
          XmlAttribute('t'.toName(), margin.top.toString()),
          XmlAttribute('r'.toName(), margin.right.toString()),
          XmlAttribute('b'.toName(), margin.bottom.toString()),
        ],
        isSelfClosing: true,
      ),
    ];
  }

  String _verticalAlignToXml(VerticalAlignment alignment) {
    return switch (alignment) {
      VerticalAlignment.top => 't',
      VerticalAlignment.middle => 'ctr',
      VerticalAlignment.bottom => 'b',
      _ => 't',
    };
  }

  String _horizontalAlignToXml(Alignment alignment) {
    return switch (alignment) {
      Alignment.left => 'l',
      Alignment.center => 'ctr',
      Alignment.right => 'r',
      _ => 'l',
    };
  }

  @override
  ShapeTextBox get copy => ShapeTextBox(child: child.copy);

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <ShapeTextBox>[this];
    if (!visitChildrenIfNeeded) return null;
    for (final DocxTreeNode<dynamic> el in child.content) {
      final List<DocxTreeNode<dynamic>>? result = el.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }
    return null;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    for (final DocxTreeNode<dynamic> el in child.content) {
      final DocxTreeNode<dynamic>? result = el.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }
    return null;
  }
}

/// Text box configuration for shapes.
class ShapeTextBoxData {
  ShapeTextBoxData({
    required this.content,
    this.margin = const EdgeInsets.all(0),
    this.wrapping = WrapType.square,
    this.verticalAlignment = VerticalAlignment.top,
    this.horizontalAlignment = Alignment.left,
  }) : assert(
          wrapping == WrapType.square || wrapping == WrapType.none,
          '"${wrapping.name}" is '
          'not allowed. ShapeTextBox onl '
          'allow square and none wrapping types',
        );

  final Iterable<DocxTreeNode<dynamic>> content;
  final EdgeInsets margin;
  final WrapType wrapping;
  final VerticalAlignment verticalAlignment;
  final Alignment horizontalAlignment;

  ShapeTextBoxData get copy => ShapeTextBoxData(
        content: content,
        margin: margin,
        wrapping: wrapping,
        verticalAlignment: verticalAlignment,
        horizontalAlignment: horizontalAlignment,
      );
}
