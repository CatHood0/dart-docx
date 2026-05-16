import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/num_extensions.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../../../../core/extensions/style_to_from_node.dart';
import '../../../../utils/logger/logger_configs.dart';

export '../../../../../core/borders.dart' show DocxBorder, DocxBorders, DocxCellBorders;

/// Backwards compatibility alias for [TableBorder].
typedef TableBorder = DocxBorder;

/// Backwards compatibility alias for [TableBorders].
typedef TableBorders = DocxBorders;

/// Backwards compatibility alias for [TableCellBorders].
typedef TableCellBorders = DocxCellBorders;

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
class TableProperties extends DocxNode<void> {
  TableProperties({
    Iterable<Style> styles = const <Style>[],
    this.width = 0,
    this.widthType = TableWidthType.auto,
    this.alignment = Alignment.left,
    TableBorders? borders,
    EdgeInsets? padding,
    this.layout = false,
    super.id,
    super.parent,
  })  : assert(width >= 0, 'width cannot be less than zero'),
        assert(width != 0 || !widthType.isExpand || width == 0 && widthType.isExpand,
            'widthType of type expand requires that width property be zero or less'),
        assert(width <= 0 && widthType.isNilOrAuto || width > 0 && widthType.needsWidth,
            'TableWidthType.auto can only be used when width is zero or less'),
        styles = List<Style>.from(styles),
        cellMargins = padding ?? const EdgeInsets.all(20),
        borders = borders ?? TableBorders.all(TableBorder(style: BorderStyle.single)),
        super(child: null);

  TableProperties.fromContext({
    required DocumentContext context,
    Iterable<Style> styles = const <Style>[],
    this.alignment = Alignment.left,
    TableBorders? borders,
    EdgeInsets? padding,
    super.id,
    super.parent,
  })  : width = context.options.availablePageWidth,
        layout = false,
        widthType = TableWidthType.dxa,
        styles = List<Style>.from(styles),
        cellMargins = padding ?? const EdgeInsets.all(20),
        borders = borders ?? TableBorders.all(TableBorder(style: BorderStyle.single)),
        super(child: null);

  TableProperties.expand({
    Iterable<Style> styles = const <Style>[],
    this.alignment = Alignment.left,
    TableBorders? borders,
    EdgeInsets? padding,
    this.layout = false,
    super.id,
    super.parent,
  })  : width = 0,
        widthType = TableWidthType.expand,
        styles = List<Style>.from(styles),
        cellMargins = padding ?? const EdgeInsets.all(55),
        borders = borders ?? TableBorders.all(TableBorder(style: BorderStyle.single)),
        super(child: null);

  TableProperties.auto({
    Iterable<Style> styles = const <Style>[],
    this.alignment = Alignment.left,
    TableBorders? borders,
    EdgeInsets? padding,
    this.layout = false,
    super.id,
    super.parent,
  })  : width = 0,
        widthType = TableWidthType.auto,
        styles = List<Style>.from(styles),
        cellMargins = padding ?? const EdgeInsets.all(55),
        borders = borders ?? TableBorders.all(TableBorder(style: BorderStyle.single)),
        super(child: null);

  TableProperties.dxa({
    Iterable<Style> styles = const <Style>[],
    this.width = 0,
    this.alignment = Alignment.left,
    TableBorders? borders,
    EdgeInsets? padding,
    this.layout = false,
    super.id,
    super.parent,
  })  : widthType = TableWidthType.dxa,
        styles = List<Style>.from(styles),
        assert(width != 0, 'widthType of type expand requires that width property be zero or less'),
        cellMargins = padding ?? const EdgeInsets.all(55),
        borders = borders ?? TableBorders.all(TableBorder(style: BorderStyle.single)),
        super(child: null);

  TableProperties.pct({
    Iterable<Style> styles = const <Style>[],
    this.width = 0,
    this.alignment = Alignment.left,
    TableBorders? borders,
    EdgeInsets? padding,
    this.layout = false,
    super.id,
    super.parent,
  })  : widthType = TableWidthType.pct,
        assert(width != 0, 'widthType of type expand requires that width property be zero or less'),
        styles = List<Style>.from(styles),
        cellMargins = padding ?? const EdgeInsets.all(55),
        borders = borders ?? TableBorders.all(TableBorder(style: BorderStyle.single)),
        super(child: null);

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
  final int width;

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
  final EdgeInsets? cellMargins;

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
    context.currentContentPart = this;

    int padding = context.getAncestorOfExactType<Padding>()?.padding.all().toInt() ?? 0;

    if (context.childOfAncestorOfExactType<Padding>()) {
      CompilerLogger.root.debug('Founded Padding($padding) parent for $id in ${parent.runtimeType}');
    }
    final List<XmlNode> nodes = <XmlNode>[
      XmlElement.tag(
        'w:tblW',
        attributes: <XmlAttribute>[
          if (width > 0 && !widthType.isExpand)
            XmlAttribute(
              'w:w'.toName(),
              (width - padding).nonNegative.toString(),
            )
          else if (widthType.isExpand)
            XmlAttribute(
              'w:w'.toName(),
              (context.options.availablePageWidth.floor() - padding).nonNegative.toString(),
            ),
          XmlAttribute(
            'w:type'.toName(),
            widthType.isExpand ? TableWidthType.dxa.name : widthType.name,
          ),
        ],
        isSelfClosing: true,
      ),
    ];

    if (alignment != null || context.childOfAncestorOfExactType<Align>()) {
      final Alignment align = context.getAncestorOfExactType<Align>()?.alignment ?? alignment!;
      nodes.add(XmlElement.tag(
        'w:jc',
        attributes: <XmlAttribute>[
          XmlAttribute(
            'w:val'.toName(),
            align.name,
          ),
        ],
        isSelfClosing: true,
      ));
    }
    // Apply table styles
    for (final Style style in styles) {
      //TODO: context.checkStylesRefExistence
      // must be here too
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
      //TODO: some warnings in the OOXML says that we need to ensure
      // that left is passed only when first row element, and the same for right the cur element is the right end one
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
            if (cellMargins!.top != null) _buildCellMargin('top', cellMargins!.top!),
            if (cellMargins!.right != null) _buildCellMargin('right', cellMargins!.right!),
            if (cellMargins!.bottom != null) _buildCellMargin('bottom', cellMargins!.bottom!),
            // if (cellMargins!.left != null)
            //   _buildCellMargin('left', cellMargins!.left!),
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
    if (border.color != null && !border.color!.isRGB) {
      CompilerLogger.root.error('Found TableBorder instance in TableProperties configuration '
          'with non RGB Color definition \'${border.color}\'. We recommend '
          'using Color(0x<COLOR>) or RGB constructor variants.\n\n'
          'This instance will be ignored.\n\n'
          'Object: $id, '
          'Parent: ${getAncestorOfExactType<Table>()?.runtimeType}\n'
          'Parent-Id: ${getAncestorOfExactType<Table>()?.id}\n');
    }
    return XmlElement.tag(
      'w:$position',
      attributes: <XmlAttribute>[
        XmlAttribute('w:val'.toName(), border.style.value),
        XmlAttribute('w:sz'.toName(), border.size.toString()),
        XmlAttribute('w:space'.toName(), border.space.toString()),
        if (border.color != null && border.color!.isRGB)
          XmlAttribute('w:color'.toName(), border.color!.toColorValue()!)
        else
          XmlAttribute('w:color'.toName(), 'auto'),
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
  DocxNode<void> get copy => TableProperties(
        id: id,
        parent: parent,
        styles: styles,
        width: width,
        widthType: widthType,
        alignment: alignment,
        borders: borders,
        padding: cellMargins,
        layout: layout,
      );

  @override
  TableProperties copyWith({
    String? id,
    DocxNode<void>? parent,
    Iterable<Style>? styles,
    int? width,
    TableWidthType? widthType,
    Alignment? alignment,
    TableBorders? borders,
    EdgeInsets? cellMargins,
    bool? layout,
  }) {
    return TableProperties(
      styles: styles ?? this.styles,
      width: width ?? this.width,
      widthType: widthType ?? this.widthType,
      alignment: alignment ?? this.alignment,
      borders: borders ?? this.borders,
      padding: cellMargins ?? this.cellMargins,
      layout: layout ?? this.layout,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
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
    bool Function(DocxNode<dynamic>) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
