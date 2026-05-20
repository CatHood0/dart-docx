import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/cast_ext.dart';
import '../../../../../core/extensions/string_ext.dart';

/// Table row containing multiple cells.
///
/// The `TableRow` class represents a single row within a table. Each row
/// contains a collection of `TableCell` objects and can have row-level
/// properties such as height, splitting behavior, and styling.
///
/// Example usage:
/// ```dart
/// TableRow(
///   cells: [
///     TableCell(
///       children: [Paragraph.text(text: 'Cell 1')],
///       cellConfig: TableCellConfig(width: 2000),
///     ),
///     TableCell(
///       children: [Paragraph.text(text: 'Cell 2')],
///       cellConfig: TableCellConfig(width: 3000),
///     ),
///   ],
/// ),
/// ```
class TableRow extends DocxNode<List<TableCell>> {
  TableRow({
    required Iterable<TableCell> cells,
    this.canSplit,
    this.hidden,
    this.height,
    TableHeightRule? heightRule,
    this.alignment,
    this.spacing = 0,
    this.isHeader = false,
    super.id,
    super.parent,
  })  : heightRule = height != null && heightRule == null
            ? TableHeightRule.atLeast
            : heightRule,
        super(child: List.from(cells)) {
    int cellIndex = 0;
    for (final TableCell cell in child) {
      cell
        ..parent = this
        ..index = cellIndex
        ..depth = depth + 1;
      cellIndex++;
    }
  }

  TableRow.header({
    required Iterable<TableCell> cells,
    this.canSplit,
    this.hidden,
    this.height,
    TableHeightRule? heightRule,
    this.alignment,
    this.spacing = 0,
    super.id,
    super.parent,
  })  : isHeader = true,
        heightRule = height != null && heightRule == null
            ? TableHeightRule.atLeast
            : heightRule,
        super(child: List.from(cells)) {
    int cellIndex = 0;
    for (final TableCell cell in child) {
      cell
        ..parent = this
        ..index = cellIndex
        ..depth = depth + 1;
      cellIndex++;
    }
  }

  TableRow.empty({
    TableHeightRule? heightRule,
    this.hidden,
    this.height,
    this.canSplit,
    this.alignment,
    this.spacing = 0,
    this.isHeader = false,
    super.id,
    super.parent,
  })  : heightRule = height != null && heightRule == null
            ? TableHeightRule.atLeast
            : heightRule,
        super(child: List.from(<dynamic>[]));

  TableRow.one({
    required TableCell cell,
    this.canSplit,
    this.hidden,
    this.height,
    this.alignment,
    this.spacing = 0,
    this.isHeader = false,
    TableHeightRule? heightRule,
    super.id,
    super.parent,
  })  : heightRule = height != null && heightRule == null
            ? TableHeightRule.atLeast
            : heightRule,
        super(child: List.from(<dynamic>[cell]));

  TableRow.two({
    required TableCell cell,
    required TableCell cell2,
    this.canSplit,
    this.hidden,
    this.height,
    this.alignment,
    this.spacing = 0,
    this.isHeader = false,
    TableHeightRule? heightRule,
    super.id,
    super.parent,
  })  : heightRule = height != null && heightRule == null
            ? TableHeightRule.atLeast
            : heightRule,
        super(child: List.from(<dynamic>[cell, cell2]));

  TableRow.three({
    required TableCell cell,
    required TableCell cell2,
    required TableCell cell3,
    this.canSplit,
    this.hidden,
    this.height,
    this.alignment,
    this.spacing = 0,
    this.isHeader = false,
    TableHeightRule? heightRule,
    super.id,
    super.parent,
  })  : heightRule = height != null && heightRule == null
            ? TableHeightRule.atLeast
            : heightRule,
        super(child: List.from(<dynamic>[cell, cell2, cell3]));

  final bool? canSplit;
  final bool? hidden;
  final int? height;
  final TableHeightRule? heightRule;
  final Alignment? alignment;

  /// Forces Word to show always the header row
  /// when it is splitted between different pages
  final bool isHeader;

  /// The spacing between all the cells
  /// in dxa units
  final int spacing;

  @override
  List<XmlElement> buildXml() {
    final List<XmlNode> rowChildren = <XmlNode>[
      // To maintain compatibility with certain editors,
      // we always include a w:trPr element, even if empty.
      // This avoids rendering issues with editors like LibreOffice.
      XmlElement.tag(
        'w:trPr',
        children: buildXmlStyle(),
        isSelfClosing: false,
      )
    ];

    // Build all cells in the row
    for (final TableCell cell in child) {
      if (cell.cellConfig.widthType.needsWidth && cell.cellConfig.width <= 0) {
        throw Exception(
          '${getAncestorOfExactType<Table>()?.runtimeType}:${getAncestorOfExactType<Table>()?.id} => '
          '$runtimeType:$id => TableWidthType.pct or TableWidthType.dxa '
          'requires a non zero and non negative [width]',
        );
      }

      if (cell.cellConfig.widthType.isNilOrAuto && cell.cellConfig.width > 0) {
        throw Exception(
          '${getAncestorOfExactType<Table>()?.runtimeType}:${getAncestorOfExactType<Table>()?.id} => '
          '$runtimeType:$id => TableWidthType.auto or '
          'TableWidthType.nil only can be used when '
          '[width] is zero or less',
        );
      }

      final List<XmlNode> cellXml = cell.buildXml();
      rowChildren.addAll(cellXml);
    }

    return <XmlElement>[
      XmlElement.tag(
        'w:tr',
        children: rowChildren,
        isSelfClosing: false,
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle() {
    final Alignment? align =
        alignment ?? getAncestorOfExactType<Align>()?.alignment;
    assert(
      align == null || align.isCenterLeftOrRight(),
      'TableRow alignment only supports: '
      'left, center and right. Found: "${align.name}"',
    );
    return <XmlElement>[
      if (canSplit != null)
        // it's so annoying how they select the names
        // of some nodes...
        XmlElement.tag(
          'w:cantSplit',
          attributes: XmlAttribute(
            'w:val'.toName(),
            '${!canSplit!}',
          ).toList(),
        ),
      if (align != null)
        XmlElement.tag(
          'w:jc',
          attributes: XmlAttribute(
            'w:val'.toName(),
            align.name,
          ).toList(),
        ),
      XmlElement.tag(
        'w:tblHeader',
        attributes: XmlAttribute(
          'w:val'.toName(),
          (!isHeader).toString(),
        ).toList(),
      ),
      if (hidden != null)
        XmlElement.tag(
          'w:hidden',
          attributes: XmlAttribute(
            'w:val'.toName(),
            (!hidden!).toString(),
          ).toList(),
        ),
      if (spacing > 0)
        XmlElement.tag(
          'w:tblCellSpacing',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:w'.toName(),
              (spacing).toString(),
            ),
            XmlAttribute(
              'w:type'.toName(),
              'dxa',
            ),
          ],
        ),
      if (height != null && heightRule != null)
        XmlElement.tag(
          'w:trHeight',
          attributes: <XmlAttribute>[
            XmlAttribute('w:val'.toName(), (height!).toString()),
            XmlAttribute('w:hRule'.toName(), (heightRule!).toString()),
          ],
        ),
    ];
  }

  @override
  TableRow get copy => TableRow(
        id: id,
        parent: parent,
        cells: child,
        hidden: hidden,
        canSplit: canSplit,
        height: height,
        heightRule: heightRule,
      );

  @override
  TableRow copyWith({
    Iterable<TableCell>? cells,
    String? id,
    DocxNode<dynamic>? parent,
    bool? canSplit,
    bool? hidden,
    int? height,
    TableHeightRule? heightRule,
    Alignment? alignment,
    bool? isHeader,
    int? spacing,
  }) {
    return TableRow(
      cells: cells ?? this.child,
      canSplit: canSplit ?? this.canSplit,
      hidden: hidden ?? this.hidden,
      height: height ?? this.height,
      heightRule: heightRule ?? this.heightRule,
      alignment: alignment ?? this.alignment,
      isHeader: isHeader ?? this.isHeader,
      spacing: spacing ?? this.spacing,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final TableCell element in child) {
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxNode? foundedEl = element.visitElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          return foundedEl;
        }
      }
    }
    return null;
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (child.isEmpty) return <DocxNode>[];
    final List<DocxNode> elements = <DocxNode>[];
    for (final TableCell element in child) {
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxNode<dynamic>>? foundedEl = element.visitAllElement(
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
}
