import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../../../../core/extensions/style_to_from_node.dart';

/// Complete table configuration for DOCX documents.
///
/// The `TableConfig` class encapsulates all table-level properties including
/// styles, dimensions, borders, alignment, and layout behavior. It generates
/// the necessary XML structure for the `w:tblPr` element in DOCX files.
///
/// Example usage:
/// ```dart
/// TableProperties(
///   styles: [Style.reference('TableGrid')],
///   width: 5000,
///   widthType: TableWidthType.pct,
///   alignment: Alignment.center,
///   borders: TableBorders(
///     top: TableBorder(style: BorderStyle.double, size: 8),
///     bottom: TableBorder(style: BorderStyle.double, size: 8),
///     insideHorizontal: TableBorder(style: BorderStyle.dotted),
///   ),
///   cellMargins: TableCellMargins(
///     top: 100,
///     left: 100,
///     bottom: 100,
///     right: 100,
///   ),
///   layout: false, // fixed layout
/// );
/// ```
class TableProperties extends DocxTreeNode<void> {
  TableProperties({
    Iterable<Style> styles = const <Style>[],
    this.width = 0,
    this.widthType = TableWidthType.auto,
    this.alignment = Alignment.left,
    TableBorders? borders,
    TableCellMargins? cellMargins,
    this.layout = false,
    super.id,
  })  : styles = List<Style>.from(styles),
        cellMargins = cellMargins ??
            const TableCellMargins(
              top: 55,
              left: 55,
              bottom: 55,
              right: 55,
            ),
        borders = borders ??
            TableBorders(
              left: TableBorder(style: BorderStyle.single),
              top: TableBorder(style: BorderStyle.single),
              bottom: TableBorder(style: BorderStyle.single),
              right: TableBorder(style: BorderStyle.single),
            ),
        super(data: null);

  /// Predefined table styles to apply.
  ///
  /// These can include both built-in DOCX table styles (like 'TableGrid')
  /// and custom styles defined in the document's stylesheet.
  final List<Style> styles;

  /// Total table width.
  ///
  /// Can be specified in various units depending on `widthType`:
  /// - `TableWidthType.dxa`: Twips (1/1440 inch)
  /// - `TableWidthType.pct`: Percentage of page width
  /// - `TableWidthType.auto`: Automatic sizing
  /// - `TableWidthType.nil`: Unspecified
  final num? width;

  /// Unit type for the table width.
  ///
  /// Determines how the `width` value should be interpreted.
  final TableWidthType widthType;

  /// Horizontal alignment of the table within the document.
  ///
  /// Controls whether the table is aligned to the left, center, or right
  /// of the page or containing element.
  final Alignment? alignment;

  /// Border definitions for the entire table.
  ///
  /// Allows individual control over all table borders including
  /// external borders and internal grid lines.
  final TableBorders? borders;

  /// Internal margins for table cells.
  ///
  /// Defines the spacing between cell content and cell borders.
  /// Default values provide standard cell padding.
  final TableCellMargins? cellMargins;

  /// Determines how the table manages its column sizing.
  ///
  /// - `true`: Auto-fit layout (columns adjust to content)
  /// - `false`: Fixed layout (columns use specified widths)
  ///
  /// Auto-fit is useful for content-based tables where column widths
  /// should adjust dynamically. Fixed layout provides precise control
  /// over column dimensions.
  final bool layout;

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    final List<XmlNode> nodes = <XmlNode>[
      if (width != null)
        XmlElement.tag(
          'w:tblW',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:w'.toName(),
              width.toString(),
            ),
            XmlAttribute(
              'w:type'.toName(),
              widthType.name,
            ),
          ],
          isSelfClosing: true,
        ),
      if (alignment != null)
        XmlElement.tag(
          'w:jc',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              alignment!.name,
            ),
          ],
          isSelfClosing: true,
        ),
    ];

    // Apply table styles
    for (final Style style in styles) {
      if (style.isInvalid) {
        continue;
      }
      final List<XmlElement> xml = style.forTableStyle(
        shouldShowStyleRef: style.isReference,
        useConfigurators: !style.isReference,
      );
      nodes.addAll(xml);
    }

    // Set table layout mode
    nodes.add(
      XmlElement.tag(
        'w:tblLayout',
        attributes: <XmlAttribute>[
          XmlAttribute(
            'w:type'.toName(),
            layout ? 'autofit' : 'fixed',
          ),
        ],
      ),
    );

    // Table borders
    if (borders != null) {
      final List<XmlNode> borderNodes = <XmlNode>[];

      if (borders!.top != null) {
        borderNodes.add(_buildBorder('top', borders!.top!));
      }
      if (borders!.right != null) {
        borderNodes.add(_buildBorder('right', borders!.right!));
      }
      if (borders!.bottom != null) {
        borderNodes.add(_buildBorder('bottom', borders!.bottom!));
      }
      if (borders!.left != null) {
        borderNodes.add(_buildBorder('left', borders!.left!));
      }
      if (borders!.insideHorizontal != null) {
        borderNodes.add(_buildBorder('insideH', borders!.insideHorizontal!));
      }
      if (borders!.insideVertical != null) {
        borderNodes.add(_buildBorder('insideV', borders!.insideVertical!));
      }

      if (borderNodes.isNotEmpty) {
        nodes.add(
          XmlElement.tag(
            'w:tblBorders',
            children: borderNodes,
            isSelfClosing: false,
          ),
        );
      }
    }

    // Cell margins
    if (cellMargins != null) {
      nodes.add(
        XmlElement.tag(
          'w:tblCellMar',
          children: <XmlNode>[
            if (cellMargins!.top != null)
              _buildCellMargin('top', cellMargins!.top!),
            if (cellMargins!.right != null)
              _buildCellMargin('right', cellMargins!.right!),
            if (cellMargins!.bottom != null)
              _buildCellMargin('bottom', cellMargins!.bottom!),
            if (cellMargins!.left != null)
              _buildCellMargin('left', cellMargins!.left!),
          ],
          isSelfClosing: false,
        ),
      );
    }

    return nodes;
  }

  /// Builds an individual border element for table configuration.
  ///
  /// Creates the XML structure for a single border side with configurable
  /// style, thickness, spacing, and color.
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

  /// Builds a cell margin element for table configuration.
  ///
  /// Creates the XML structure for specifying padding/margin on a specific
  /// side of all table cells.
  XmlElement _buildCellMargin(String position, num margin) {
    return XmlElement.tag(
      'w:$position',
      attributes: <XmlAttribute>[
        XmlAttribute('w:w'.toName(), margin.toString()),
        XmlAttribute('w:type'.toName(), 'dxa'),
      ],
      isSelfClosing: true,
    );
  }

  @override
  DocxTreeNode<void> get copy => TableProperties(
        id: id,
        styles: styles,
        width: width,
        widthType: widthType,
        alignment: alignment,
        borders: borders,
        cellMargins: cellMargins,
        layout: layout,
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

/// Border configuration for tables.
///
/// Allows individual control over all border sides of a table including
/// external borders and internal grid lines. Each side can have its own
/// style, thickness, and color.
///
/// Example usage:
/// ```dart
/// TableBorders(
///   top: TableBorder(style: BorderStyle.double, size: 8),
///   bottom: TableBorder(style: BorderStyle.single, size: 4),
///   insideHorizontal: TableBorder(style: BorderStyle.dotted),
///   insideVertical: TableBorder(style: BorderStyle.dashed),
/// );
/// ```
class TableBorders {
  const TableBorders({
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.insideHorizontal,
    this.insideVertical,
  });

  TableBorders.all({
    TableBorder? all,
    this.insideHorizontal,
    this.insideVertical,
  })  : top = all,
        right = all,
        bottom = all,
        left = all;

  final TableBorder? top;
  final TableBorder? right;
  final TableBorder? bottom;
  final TableBorder? left;
  final TableBorder? insideHorizontal;
  final TableBorder? insideVertical;
}

/// Border configuration for individual table cells.
///
/// Provides control over the borders of specific cells within a table.
/// This allows for custom border styling on a per-cell basis, independent
/// of the overall table border configuration.
///
/// Example usage:
/// ```dart
/// TableCellBorders(
///   top: TableBorder(style: BorderStyle.single, color: Color.rgb(0xFF0000)),
///   bottom: TableBorder(style: BorderStyle.double, size: 8),
/// );
/// ```
class TableCellBorders {
  const TableCellBorders({
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  TableCellBorders.all({
    TableBorder? all,
  })  : top = all,
        right = all,
        bottom = all,
        left = all;

  final TableBorder? top;
  final TableBorder? right;
  final TableBorder? bottom;
  final TableBorder? left;
}

/// Definition of an individual border with style, thickness, and color.
///
/// Represents a single border line with configurable appearance.
/// The `size` property is measured in eighths of a point (so 4 = 0.5pt,
/// 8 = 1pt, 16 = 2pt, etc.).
///
/// Example usage:
/// ```dart
/// TableBorder(
///   style: BorderStyle.double,
///   size: 12,  // 1.5 points
///   space: 2,  // 2 points spacing
///   color: Color.rgb(0x336699),
/// );
/// ```
class TableBorder {
  TableBorder({
    this.style = BorderStyle.single,
    this.size = 4,
    this.space = 0,
    Color? color,
  })  : color = color ?? Color.rgb(0x000000),
        assert(
          color == null || color.rgbValue != null,
          'color property must be ' 'used calling Color.rgb constructor',
        );

  /// Border line style (single, double, dashed, dotted, etc.)
  final BorderStyle style;

  /// Border thickness in eighths of a point.
  ///
  /// Common values:
  /// - `4` = 0.5 points (default)
  /// - `8` = 1 point
  /// - `12` = 1.5 points
  /// - `16` = 2 points
  /// - `24` = 3 points
  final int size;

  /// Line spacing between the border and the content in point units.
  ///
  /// This creates space between the border line and the cell content.
  final int space;

  /// Border color in hex RGB format (e.g., 'FF0000' for red).
  ///
  /// Use `Color.rgb()` constructor to create color values.
  final Color? color;
}
