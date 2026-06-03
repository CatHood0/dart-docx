import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/cast_ext.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../../../compiler/inherited/compiler_config_provider.dart';

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
///       top: TableBorder(style: BorderStyle.single, size: Point(8)),
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
class TableCell extends DocxNode<List<DocxNode>> {
  TableCell({
    required List<DocxNode> children,
    required this.cellConfig,
    bool reversed = false,
    super.id,
    super.parent,
  })  : _length = children.length,
        _fixed = true,
        _start = 0,
        super(child: children) {
    int childIndex = 0;
    for (final DocxNode el in reversed ? child.reversed : child) {
      el
        ..parent = this
        ..index = childIndex
        ..depth = depth + 1;
      childIndex++;
    }
  }

  TableCell.one({
    required DocxNode child,
    required this.cellConfig,
    bool reversed = false,
    super.id,
    super.parent,
  })  : _length = 1,
        _fixed = true,
        _start = 0,
        super(child: <DocxNode<dynamic>>[child]) {
    child
      ..parent = this
      ..index = 0
      ..depth = depth + 1;
  }

  TableCell.empty({
    this.cellConfig = const TableCellConfig.auto(),
    bool reversed = false,
    super.id,
    super.parent,
  })  : _length = 0,
        _fixed = true,
        _start = 0,
        super(child: <DocxNode<dynamic>>[]);

  TableCell.builder({
    required DocxNode Function(int) itemBuilder,
    required int itemCount,
    required this.cellConfig,
    bool reversed = false,
    super.id,
    super.parent,
  })  : _length = itemCount,
        _fixed = false,
        _start = 0,
        _itemBuilder = itemBuilder,
        super(child: const <DocxNode<dynamic>>[]);

  /// Configuration for the table cell, including:
  /// - Width and sizing behavior
  /// - Cell merging (colspan/rowspan)
  /// - Vertical alignment
  /// - Border styling
  /// - Background shading
  final TableCellConfig cellConfig;

  DocxNode Function(int)? _itemBuilder;
  int _length;
  int _start;
  bool _fixed;

  @override
  set parent(DocxNode<dynamic>? parent) {
    CompilerLogger.root.debug(
      'Assigning parent => $parent in $runtimeType:$id ($depth)',
    );
    super.parent = parent?.castOrNull<TableRow>();
  }

  @override
  void updateElement(
    DocxNode<dynamic> component, {
    int? index,
    bool strict = true,
  }) {}

  @override
  void insertText(
    String text, {
    int? offset,
    int? path,
    List<Object>? styles,
    bool mergeStyles = true,
  }) {}

  @override
  void deleteText({required int start, required int length, int? path}) {}

  @override
  void addAll(List<DocxNode<dynamic>> components) {}

  //TODO: make the cache using this
  @override
  void perform() {}

  @override
  List<XmlElement> buildXml() {
    if (parent == null) {
      throw '$runtimeType:$id has not parent relationship';
    }
    final List<XmlNode> cellChildren = <XmlNode>[];
    List<DocxNode<dynamic>>? children = _fixed ? child : null;

    if (children == null) {
      children = <DocxNode<dynamic>>[];
      for (int i = _start;
          _start > 0 ? i > 0 : i < _length;
          _start > 0 ? i-- : i++) {
        children.add(
          _itemBuilder!(i)
            ..index = i
            ..parent = this,
        );
      }
    }

    // Cell properties (tcPr)
    final List<XmlNode> tcPrNodes = _buildTcPr();
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
    for (final DocxNode child in children) {
      final List<XmlNode> childXml = child.buildXml();
      cellChildren.addAll(childXml);
    }

    // Detect if this component is a row into another one
    //
    // Internally, Row is automatically parsed to a Table
    // so, we cannot call it expecting something
    //
    // If you create a trace of the ancestor, you will get this:
    //
    //  LayoutConstraints
    //  |_ Table
    //   |_ TableRow
    //    | TableCell <- (we are here)
    //
    // As you see, we don't get a Row instance here
    if ((child.lastOrNull is Table || child.lastOrNull is Row) &&
        isChildOf<Table>()) {
      CompilerLogger.root.warning(
        'Detected ending ${child.last.runtimeType} '
        'child in $runtimeType:$depth:$id. '
        'Inserting empty paragraph to avoid rendering issues with multiple editors',
      );
      // why we call last element and check if it's a row?
      //
      // Well, by some reason, LibreOffice does not render it properly if there is no space
      // between the table and the end of the cell
      //
      // What is this problem? Literally, all tables breaks itself, being "moved"
      // internally to behave as independent external tables, that makes look them like the tree
      // moved for no reason
      //
      // Just a workaround. It's not problem that we can "fix"
      cellChildren.addAll(Paragraph.empty().buildXml());
    }

    return <XmlElement>[
      XmlElement.tag(
        'w:tc',
        children: cellChildren,
        isSelfClosing: false,
      ),
    ];
  }

  List<XmlNode> _buildTcPr() {
    if (cellConfig.widthType.isExpand && isChildOf<CompilerConfigProvider>()) {
      throw Exception(
        'Cannot build style '
        'properties of $runtimeType:$id since was not '
        'founded CompilerConfigProvider in the tree',
      );
    }
    final CompilerConfigProvider? configs = CompilerConfigProvider.of(this);
    final List<XmlNode> nodes = <XmlNode>[
      XmlElement.tag(
        'w:tcW',
        attributes: <XmlAttribute>[
          if (cellConfig.width > 0 && !cellConfig.widthType.isExpand)
            XmlAttribute(
              'w:w'.toName(),
              cellConfig.width.toString(),
            )
          else if (cellConfig.widthType.isExpand)
            XmlAttribute(
              'w:w'.toName(),
              (configs!.options.pageSize.width.toDxa() -
                      (configs.options.margins.left +
                          configs.options.margins.right))
                  .floor()
                  .toString(),
            ),
          XmlAttribute(
            'w:type'.toName(),
            cellConfig.widthType.isExpand
                ? TableWidthType.dxa.name
                : cellConfig.widthType.name,
          ),
        ],
        isSelfClosing: true,
      )
    ];

    // Cell merging (colspan)
    if (cellConfig.columnSpan != null && cellConfig.columnSpan! > 1) {
      nodes.add(
        XmlElement.tag(
          'w:gridSpan',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              cellConfig.columnSpan!.toString(),
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
      final int cells = parent!.child.length - 1;
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
      nodes.addAll(cellConfig.shading!.buildXml());
    }

    return nodes;
  }

  XmlElement _buildBorder(String position, BorderSide border) {
    if (border.color != null && !border.color!.isRGB) {
      CompilerLogger.root.error(
        'Found BorderSide instance '
        'with a non RGB Color definition \'${border.color}\'. We recommend '
        'using Color(0xFFFFFF) or RGB constructor variants.\n\n'
        'This instance will be ignored.\n\n'
        'Object: $id, '
        'Depth: $depth, '
        'Index: $index\n'
        'Parent: ${getAncestorOfExactType<Table>()?.runtimeType}\n'
        'Parent-Id: ${getAncestorOfExactType<Table>()?.id}\n'
        'Row: ${getAncestorOfExactType<Table>()?.runtimeType}\n'
        'Row-index: ${getAncestorOfExactType<TableRow>()?.index}\n'
        'Row-id: ${getAncestorOfExactType<TableRow>()?.id}',
      );
    }
    return XmlElement.tag(
      'w:$position',
      attributes: <XmlAttribute>[
        XmlAttribute('w:val'.toName(), border.style.value),
        XmlAttribute('w:sz'.toName(), border.size.toEightOfPt().toString()),
        XmlAttribute('w:space'.toName(), border.space.toEightOfPt().toString()),
        if (border.color != null && border.color!.isRGB)
          XmlAttribute('w:color'.toName(), border.color!.toColorValue()!),
      ],
      isSelfClosing: true,
    );
  }

  @override
  TableCell get copy => TableCell(
        id: id,
        children: child,
        cellConfig: cellConfig,
        parent: parent,
      );

  @override
  TableCell copyWith({
    List<DocxNode<dynamic>>? child,
    String? id,
    DocxNode<dynamic>? parent,
    TableCellConfig? cellConfig,
  }) {
    return TableCell(
      cellConfig: cellConfig ?? this.cellConfig,
      children: child ?? this.child,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final DocxNode<dynamic> element in child) {
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
    for (final DocxNode<dynamic> element in child) {
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
