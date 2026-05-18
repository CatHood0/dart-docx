import 'package:xml/xml.dart';
import '../../../../../../docx.dart';

/// Pattern fill for shapes (a:pattFill).
///
/// Fills shape geometry with a repeating pattern, defined by a foreground color
/// and a background color. The pattern type can be stripes, dots, etc.
class PatternFillComponent extends Fill<PatternFill> {
  PatternFillComponent({required super.child});

  @override
  PatternFillComponent get copy => PatternFillComponent(child: child.copy);

  @override
  PatternFillComponent copyWith({
    PatternFill? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return PatternFillComponent(
      child: child ?? this.child.copy,
    )..parent = parent ?? this.parent;
  }

  @override
  List<XmlNode> buildXml() {
    final List<XmlNode> children = <XmlNode>[];

    if (child.foregroundColor != null) {
      children.add(
        XmlElement.tag(
          'a:fgClr',
          children:
              child.foregroundColor!.ensureInitialized(context).buildXml(),
        ),
      );
    }

    if (child.backgroundColor != null) {
      children.add(
        XmlElement.tag(
          'a:bgClr',
          children:
              child.backgroundColor!.ensureInitialized(context).buildXml(),
        ),
      );
    }

    return <XmlNode>[
      XmlElement.tag(
        'a:pattFill',
        attributes: <XmlAttribute>[
          XmlAttribute(
            XmlName.fromString('prst'),
            _patternTypeToXml(child.type),
          ),
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
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <PatternFillComponent>[this];
    return null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
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
