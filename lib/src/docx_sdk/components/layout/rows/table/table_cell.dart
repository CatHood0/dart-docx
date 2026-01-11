import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/cast_ext.dart';
import '../../../../../core/extensions/string_ext.dart';

/// Table cell that can contain multiple content elements.
///
/// The `TableCell` class represents a single cell within a table row.
/// Each cell can contain multiple `DocxTreeNode` elements such as paragraphs,
/// lists, images, or even nested tables. Cells support various configurations
/// including width, vertical alignment, cell merging (colspan/rowspan),
/// borders, and background shading.
///
/// Example usage:
/// ```dart
/// TableCell(
///   cellConfig: TableCellConfig(
///     width: 3000,
///     widthType: TableWidthType.dxa,
///     gridSpan: 2,  // colspan
///     rowSpan: 3,   // rowspan
///     verticalAlignment: VerticalAlignment.center,
///     borders: TableCellBorders(
///       top: TableBorder(style: BorderStyle.single, size: 8),
///     ),
///     shading: Shading(fill: Color.rgb(0xFFCCCC)),
///   ),
///   children: [
///     Paragraph.text(text: 'Main content'),
///     Paragraph.text(text: 'Additional paragraph'),
///     List.unordered(items: [
///       ListItem(text: 'Bullet point 1'),
///       ListItem(text: 'Bullet point 2'),
///     ]),
///   ],
/// ),
/// ```
class TableCell extends DocxTreeNode<List<DocxTreeNode>> {
  TableCell({
    required List<DocxTreeNode> children,
    required this.cellConfig,
    super.id,
    super.parent,
  }) : super(data: children) {
    int childIndex = 0;
    for (final DocxTreeNode child in data) {
      child
        ..parent = this
        ..index = childIndex
        ..depth = depth + 1;
      childIndex++;
    }
  }

  /// Configuration for the table cell, including:
  /// - Width and sizing behavior
  /// - Cell merging (colspan/rowspan)
  /// - Vertical alignment
  /// - Border styling
  /// - Background shading
  final TableCellConfig cellConfig;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> cellChildren = <XmlNode>[];

    // Cell properties (tcPr)
    final List<XmlNode> tcPrNodes = _buildTcPr(context);
    if (tcPrNodes.isNotEmpty) {
      cellChildren.add(
        XmlElement.tag(
          'w:tcPr',
          children: tcPrNodes,
          isSelfClosing: false,
        ),
      );
    }

    // Cell content (can be multiple elements)
    for (final DocxTreeNode child in data) {
      final List<XmlNode> childXml = child.buildXml(context: context);
      cellChildren.addAll(childXml);
    }

    return <XmlElement>[
      XmlElement.tag(
        'w:tc',
        children: cellChildren,
        isSelfClosing: false,
      ),
    ];
  }

  List<XmlNode> _buildTcPr(DocumentContext context) {
    final List<XmlNode> nodes = <XmlNode>[];

    // Cell width
    if (cellConfig.width != null) {
      nodes.add(
        XmlElement.tag(
          'w:tcW',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:w'.toName(),
              cellConfig.width!.toString(),
            ),
            XmlAttribute(
              'w:type'.toName(),
              cellConfig.widthType.name,
            ),
          ],
          isSelfClosing: true,
        ),
      );
    }

    // Cell merging (colspan)
    if (cellConfig.gridSpan != null && cellConfig.gridSpan! > 1) {
      nodes.add(
        XmlElement.tag(
          'w:gridSpan',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              cellConfig.gridSpan!.toString(),
            ),
          ],
          isSelfClosing: true,
        ),
      );
    }

    // Vertical merging (rowspan)
    if (cellConfig.rowSpan != null) {
      if (cellConfig.rowSpan! > 1) {
        // Start a vertical merge
        nodes.add(
          XmlElement.tag(
            'w:vMerge',
            attributes: <XmlAttribute>[
              XmlAttribute(
                'w:val'.toName(),
                'restart',
              ),
            ],
            isSelfClosing: true,
          ),
        );
      } else if (cellConfig.rowSpan! == 0) {
        // Continue an existing vertical merge
        nodes.add(
          XmlElement.tag(
            'w:vMerge',
            attributes: <XmlAttribute>[
              XmlAttribute(
                'w:val'.toName(),
                'continue',
              ),
            ],
            isSelfClosing: true,
          ),
        );
      }
    }

    // Vertical alignment
    if (cellConfig.verticalAlignment != null) {
      nodes.add(
        XmlElement.tag(
          'w:vAlign',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              cellConfig.verticalAlignment!.name,
            ),
          ],
          isSelfClosing: true,
        ),
      );
    }

    // Cell borders
    if (cellConfig.borders != null) {
      final List<XmlNode> borderNodes = <XmlNode>[];

      if (cellConfig.borders!.top != null) {
        borderNodes.add(_buildBorder('top', cellConfig.borders!.top!));
      }
      final int cells = parent!.cast<TableRow>().data.length - 1;
      if (cellConfig.borders!.right != null && index == cells) {
        borderNodes.add(_buildBorder('right', cellConfig.borders!.right!));
      }
      if (cellConfig.borders!.bottom != null) {
        borderNodes.add(_buildBorder('bottom', cellConfig.borders!.bottom!));
      }
      if (cellConfig.borders!.left != null) {
        borderNodes.add(_buildBorder('left', cellConfig.borders!.left!));
      }

      if (borderNodes.isNotEmpty) {
        nodes.add(
          XmlElement.tag(
            'w:tcBorders',
            children: borderNodes,
            isSelfClosing: false,
          ),
        );
      }
    }

    // Cell background/fill
    if (cellConfig.shading != null) {
      nodes.addAll(cellConfig.shading!.buildXml(
        context: context,
      ));
    }

    return nodes;
  }

  XmlElement _buildBorder(String position, TableBorder border) {
    return XmlElement.tag(
      'w:$position',
      attributes: <XmlAttribute>[
        XmlAttribute('w:val'.toName(), border.style.value),
        XmlAttribute('w:sz'.toName(), border.size.toString()),
        XmlAttribute('w:space'.toName(), border.space.toString()),
        if (border.color != null)
          XmlAttribute('w:color'.toName(), border.color!.toColorValue()!),
      ],
      isSelfClosing: true,
    );
  }

  @override
  TableCell get copy => TableCell(
        id: id,
        children: data,
        cellConfig: cellConfig,
        parent: parent,
      );

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final DocxTreeNode<dynamic> element in data) {
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
    if (data.isEmpty) return <DocxTreeNode>[];
    final List<DocxTreeNode> elements = <DocxTreeNode>[];
    for (final DocxTreeNode<dynamic> element in data) {
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
