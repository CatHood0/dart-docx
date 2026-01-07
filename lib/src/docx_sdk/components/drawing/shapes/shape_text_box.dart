import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../../../../core/extensions/string_ext.dart';

/// Text box container within a shape (wps:txbx).
///
/// Allows adding formatted text content inside a shape, with configurable
/// margins, wrapping behavior, and vertical/horizontal alignment.
class ShapeTextBox extends DocxTreeNode<ShapeTextBoxData> {
  ShapeTextBox({required super.data});

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    context.currentContentPart = this;
    final XmlElement textBoxElement = XmlElement.tag(
      'wps:txbx',
      children: <XmlNode>[
        // Rich text content inside the text box
        XmlElement.tag(
          'w:txbxContent',
          children: data.content.buildXml(context: context),
        ),
      ],
    );

    // Body properties control text wrapping and margins
    final XmlElement bodyProperties = XmlElement.tag(
      'a:bodyPr',
      attributes: <XmlAttribute>[
        XmlAttribute(
          'wrap'.toName(),
          data.wrapping.name,
        ),
        XmlAttribute(
          'vert'.toName(),
          _verticalAlignToXml(data.verticalAlignment),
        ),
        XmlAttribute(
          'horz'.toName(),
          _horizontalAlignToXml(data.horizontalAlignment),
        ),
      ],
      children: _buildInsets(data.margin),
      isSelfClosing: data.margin.left == 0 &&
          data.margin.top == 0 &&
          data.margin.right == 0 &&
          data.margin.bottom == 0,
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
  ShapeTextBox get copy => ShapeTextBox(data: data.copy);

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

    return data.content.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;

    return data.content.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
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

  final DocxTreeNode<dynamic> content;
  final EdgeInsets margin;
  final WrapType wrapping;
  final VerticalAlignment verticalAlignment;
  final Alignment horizontalAlignment;

  ShapeTextBoxData get copy => ShapeTextBoxData(
        content: content.copy,
        margin: margin,
        wrapping: wrapping,
        verticalAlignment: verticalAlignment,
        horizontalAlignment: horizontalAlignment,
      );
}
