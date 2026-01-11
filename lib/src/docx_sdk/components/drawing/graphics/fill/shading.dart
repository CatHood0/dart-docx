import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../shared/fill.dart';

class Shading extends Fill<void> {
  Shading({
    this.style = ShadingPattern.solid,
    this.color,
    this.fill,
  }) : super(data: null);

  final ShadingPattern style;

  final Color? color;

  final Color? fill;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    assert(
      color == null || color!.rgbValue != null,
      'color property '
      'only accept Color.rgb '
      'instances. Found: $color',
    );
    return <XmlElement>[
      XmlElement.tag(
        'w:shd',
        attributes: <XmlAttribute>[
          XmlAttribute(
            'w:val'.toName(),
            style.value,
          ),
          if (color != null)
          XmlAttribute(
            'w:color'.toName(),
            color!.toColorValue()!,
          ),
          if (fill != null)
            XmlAttribute(
              'w:fill'.toName(),
              fill!.toColorValue()!,
            ),
        ],
        isSelfClosing: true,
      )
    ];
  }

  @override
  Shading get copy => Shading(
        fill: fill,
        color: color,
        style: style,
      );

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <DocxTreeNode<dynamic>>[this] : null;
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
