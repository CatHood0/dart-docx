import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/style_to_from_node.dart';

/// Table row containing multiple cells.
///
/// The `TableRow` class represents a single row within a table. Each row
/// contains a collection of `TableCell` objects and can have row-level
/// properties such as height, splitting behavior, and styling.
///
/// Example usage:
/// ```dart
/// TableRow(
///   rowConfig: TableStyleBuilder.singularTable()
///       .rowProperties(
///         height: 504,
///         heightRule: TableHeightRule.atLeast,
///         cantSplit: true,
///       )
///       .tableShading(color: Color.rgb(0xF0F0F0)),
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
class TableRow extends DocxTreeNode<List<TableCell>> {
  TableRow({
    required Iterable<TableCell> cells,
    this.rowConfig,
    super.id,
    super.parent,
  }) : super(child: List.from(cells)) {
    int cellIndex = 0;
    for (final TableCell cell in child) {
      cell
        ..parent = this
        ..index = cellIndex
        ..depth = depth + 1;
      cellIndex++;
    }
  }

  /// Row configuration including height, splitting behavior,
  /// and styling properties.
  ///
  /// This is built using `TableStyleBuilder` to create row-specific
  /// properties that apply to the entire row.
  final TableStyleBuilder? rowConfig;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> rowChildren = <XmlNode>[
      // To maintain compatibility with certain editors,
      // we always include a w:trPr element, even if empty.
      // This avoids rendering issues with editors like LibreOffice.
      XmlElement.tag(
        'w:trPr',
        children: _buildTrPr(context),
        isSelfClosing: false,
      )
    ];

    // Build all cells in the row
    for (final TableCell cell in child) {
      final List<XmlElement> cellXml = cell.buildXml(context: context);
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

  /// Builds the row properties (trPr) XML nodes.
  ///
  /// This includes row height, splitting behavior, and any other
  /// row-level styling properties configured via `rowConfig`.
  List<XmlNode> _buildTrPr(DocumentContext context) {
    return <XmlNode>[
      ...?rowConfig?.build().forTableRowStyle(
            shouldShowStyleRef: false,
            useConfigurators: true,
          )
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  TableRow get copy => TableRow(
        id: id,
        cells: child,
        rowConfig: rowConfig,
        parent: parent,
      );

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final TableCell element in child) {
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxTreeNode? foundedEl = element.visitElement(
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
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (child.isEmpty) return <DocxTreeNode>[];
    final List<DocxTreeNode> elements = <DocxTreeNode>[];
    for (final TableCell element in child) {
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
}
