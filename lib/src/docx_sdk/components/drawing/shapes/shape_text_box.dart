import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';
import '../../../../core/extensions/string_ext.dart';

/// Text box container within a shape (wps:txbx).
///
/// Allows adding formatted text content inside a shape, with configurable
/// margins, wrapping behavior, and vertical/horizontal alignment.
class ShapeTextBox extends DocxNode<ShapeTextBoxData> {
  ShapeTextBox({
    required super.child,
    super.id,
    super.parent,
  });

  @override
  List<XmlNode> buildXml() {
    final List<XmlNode> children = <XmlNode>[];
    for (final DocxNode<dynamic> element in child.content) {
      if (element is IgnorableMixin && element.cast<IgnorableMixin>().shouldIgnore()) {
        continue;
      }
      children.addAll(element.buildXml());
    }
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
      isSelfClosing: child.margin.all() == 0,
    );

    return <XmlElement>[
      textBoxElement,
      bodyProperties,
    ];
  }

  List<XmlNode> _buildInsets(EdgeInsets margin) {
    if (margin.all() == 0) {
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
  ShapeTextBox get copy => ShapeTextBox(
        id: id,
        child: child.copy,
        parent: parent,
      );

  @override
  ShapeTextBox copyWith({
    ShapeTextBoxData? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return ShapeTextBox(
      id: id ?? this.id,
      child: child ?? this.child.copy,
      parent: parent ?? this.parent,
    );
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <ShapeTextBox>[this];
    if (!visitChildrenIfNeeded) return null;
    for (final DocxNode<dynamic> el in child.content) {
      final List<DocxNode<dynamic>>? result = el.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }
    return null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    for (final DocxNode<dynamic> el in child.content) {
      final DocxNode<dynamic>? result = el.visitElement(
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
    this.margin = const EdgeInsets.all(Twip(0)),
    this.wrapping = WrapType.square,
    this.verticalAlignment = VerticalAlignment.top,
    this.horizontalAlignment = Alignment.left,
  }) : assert(
          wrapping == WrapType.square || wrapping == WrapType.none,
          '"${wrapping.name}" is '
          'not allowed. ShapeTextBox onl '
          'allow square and none wrapping types',
        );

  ShapeTextBoxData.empty({
    this.margin = const EdgeInsets.all(Twip(0)),
    this.wrapping = WrapType.square,
    this.verticalAlignment = VerticalAlignment.top,
    this.horizontalAlignment = Alignment.left,
  })  : content = <DocxNode<dynamic>>[],
        assert(
          wrapping == WrapType.square || wrapping == WrapType.none,
          '"${wrapping.name}" is '
          'not allowed. ShapeTextBox only '
          'support: WrapType.none and WrapType.square wrapping types',
        );

  final Iterable<DocxNode<dynamic>> content;
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
