import 'package:xml/xml.dart';
import '../../../../../../docx.dart';
import '../../shared/fill.dart';

/// Pattern fill for shapes (a:pattFill).
///
/// Fills shape geometry with a repeating pattern, defined by a foreground color
/// and a background color. The pattern type can be stripes, dots, etc.
class PatternFillComponent extends Fill<PatternFill> {
  PatternFillComponent({required super.data});

  @override
  PatternFillComponent get copy => PatternFillComponent(data: data.copy);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> children = <XmlNode>[];

    if (data.foregroundColor != null) {
      children.add(
        XmlElement.tag(
          'a:fgClr',
          children: data.foregroundColor!.buildXml(context: context),
        ),
      );
    }

    if (data.backgroundColor != null) {
      children.add(
        XmlElement.tag(
          'a:bgClr',
          children: data.backgroundColor!.buildXml(context: context),
        ),
      );
    }

    return <XmlElement>[
      XmlElement.tag(
        'a:pattFill',
        attributes: <XmlAttribute>[
          XmlAttribute(XmlName.fromString('prst'), _patternTypeToXml(data.type)),
        ],
        children: children,
      ),
    ];
  }

  String _patternTypeToXml(PatternType type) {
    return switch (type) {
      PatternType.percent5 => 'pct5',
      PatternType.percent10 => 'pct10',
      PatternType.percent20 => 'pct20',
      PatternType.percent25 => 'pct25',
      PatternType.percent30 => 'pct30',
      PatternType.percent40 => 'pct40',
      PatternType.percent50 => 'pct50',
      PatternType.percent60 => 'pct60',
      PatternType.percent70 => 'pct70',
      PatternType.percent75 => 'pct75',
      PatternType.percent80 => 'pct80',
      PatternType.percent90 => 'pct90',
      PatternType.darkHorizontal => 'dkHorz',
      PatternType.darkVertical => 'dkVert',
      PatternType.darkDownwardDiagonal => 'dkDnDiag',
      PatternType.darkUpwardDiagonal => 'dkUpDiag',
      PatternType.darkGrid => 'dkGrid',
      PatternType.darkTrellis => 'dkTrellis',
      PatternType.lightHorizontal => 'ltHorz',
      PatternType.lightVertical => 'ltVert',
      PatternType.lightDownwardDiagonal => 'ltDnDiag',
      PatternType.lightUpwardDiagonal => 'ltUpDiag',
      PatternType.lightGrid => 'ltGrid',
      PatternType.lightTrellis => 'ltTrellis',
      PatternType.narrowHorizontal => 'narHorz',
      PatternType.narrowVertical => 'narVert',
      PatternType.narrowDownwardDiagonal => 'narDnDiag',
      PatternType.narrowUpwardDiagonal => 'narUpDiag',
      PatternType.dashedDownwardDiagonal => 'dashDnDiag',
      PatternType.dashedUpwardDiagonal => 'dashUpDiag',
      PatternType.dashedHorizontal => 'dashHorz',
      PatternType.dashedVertical => 'dashVert',
      PatternType.smallConfetti => 'smConfetti',
      PatternType.largeConfetti => 'lgConfetti',
      PatternType.zigZag => 'zigZag',
      PatternType.wave => 'wave',
      PatternType.diagonalBrick => 'diagBrick',
      PatternType.horizontalBrick => 'horzBrick',
      PatternType.weave => 'weave',
      PatternType.plaid => 'plaid',
      PatternType.divot => 'divot',
      PatternType.dottedGrid => 'dotGrid',
      PatternType.dottedDiamond => 'dotDmnd',
      PatternType.shingle => 'shingle',
      PatternType.sphere => 'sphere',
      PatternType.smallGrid => 'smGrid',
      PatternType.largeGrid => 'lgGrid',
      PatternType.smallCheckerBoard => 'smCheck',
      PatternType.largeCheckerBoard => 'lgCheck',
      PatternType.outlinedDiamond => 'openDmnd',
      PatternType.solidDiamond => 'solidDmnd',
    };
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <PatternFillComponent>[this];
    return null;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    return null;
  }
}

/// Pattern fill configuration.
class PatternFill {
  const PatternFill({
    required this.type,
    this.foregroundColor,
    this.backgroundColor,
  });

  final PatternType type;
  final Color? foregroundColor;
  final Color? backgroundColor;

  PatternFill get copy => PatternFill(
        type: type,
        foregroundColor: foregroundColor?.copy,
        backgroundColor: backgroundColor?.copy,
      );
}
