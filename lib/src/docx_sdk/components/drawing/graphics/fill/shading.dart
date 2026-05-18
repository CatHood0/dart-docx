import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/string_ext.dart';

class Shading extends Fill<void> {
  Shading({
    this.style = ShadingPattern.solid,
    this.color,
    this.fill,
  }) : super(child: null);

  Shading.clear({
    this.color,
    this.fill,
  })  : style = ShadingPattern.clear,
        super(child: null);

  Shading.horizontalCross({
    this.color,
    this.fill,
  })  : style = ShadingPattern.horzCross,
        super(child: null);

  Shading.horizontalStripe({
    this.color,
    this.fill,
  })  : style = ShadingPattern.horzStripe,
        super(child: null);

  Shading.diagonalCross({
    this.color,
    this.fill,
  })  : style = ShadingPattern.diagCross,
        super(child: null);

  Shading.fwdDiagStripe({
    this.color,
    this.fill,
  })  : style = ShadingPattern.fwdDiagStripe,
        super(child: null);

  Shading.bkwdDiagStripe({
    this.color,
    this.fill,
  })  : style = ShadingPattern.bkwdDiagStripe,
        super(child: null);

  Shading.pct10({
    this.color,
    this.fill,
  })  : style = ShadingPattern.pct10,
        super(child: null);

  Shading.pct20({
    this.color,
    this.fill,
  })  : style = ShadingPattern.pct20,
        super(child: null);

  Shading.pct30({
    this.color,
    this.fill,
  })  : style = ShadingPattern.pct30,
        super(child: null);

  Shading.pct40({
    this.color,
    this.fill,
  })  : style = ShadingPattern.pct40,
        super(child: null);

  Shading.pct50({
    this.color,
    this.fill,
  })  : style = ShadingPattern.pct50,
        super(child: null);

  Shading.pct60({
    this.color,
    this.fill,
  })  : style = ShadingPattern.pct60,
        super(child: null);

  Shading.pct70({
    this.color,
    this.fill,
  })  : style = ShadingPattern.pct70,
        super(child: null);

  final ShadingPattern style;

  final Color? color;

  final Color? fill;

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
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
  Shading copyWith({
    String? id,
    DocxNode<void>? parent,
    ShadingPattern? style,
    Color? color,
    Color? fill,
  }) {
    return Shading(
      style: style ?? this.style,
      color: color ?? this.color,
      fill: fill ?? this.fill,
    )..parent = parent ?? this.parent;
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <DocxNode<dynamic>>[this] : null;
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
