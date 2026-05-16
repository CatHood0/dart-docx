import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/extensions/skippable_iterations_ext.dart';

/// A container that groups multiple elements to be rendered in a row layout
/// using tables internally
@experimental
class Row extends DocxNode<List<DocxNode>> {
  Row({
    required Iterable<DocxNode> children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.width = 0,
    this.minHeight = -1,
    this.spacing = 0,
    super.id,
    super.parent,
  }) : super(child: List.from(children)) {
    int index = 0;
    for (final DocxNode<dynamic> content in child) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  /// The width in DXA units
  final int width;
  final int minHeight;

  /// The spacing between the elements in DXA units
  final int spacing;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    context.currentContentPart = this;

    return <XmlElement>[
      ...toTable(
        context,
      ).buildXml(context: context).cast(),
    ];
  }

  /// Converts this [Row] in a [Table] equivalent version
  DocxNode toTable(DocumentContext context) {
    int maxWidth = context.getAncestorOfExactType<LayoutConstraints>()?.maxWidth ?? width;

    final EdgeInsets padding = context.getAncestorOfExactType<Padding>()?.padding ?? EdgeInsets.zero();

    if (maxWidth == 0) {
      maxWidth = context.options.availablePageWidth;
    }

    maxWidth = maxWidth.nonNegative.toInt();

    final List<DocxNode<dynamic>> temp = List<DocxNode>.from(child);

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
    if ((temp.lastOrNull is Table || temp.lastOrNull is Row)) {
      // why we call last element and check if it's a row?
      //
      // Well, by some reason, LibreOffice does not render it properly if there is no space
      // between the table and the end of the cell
      //
      // What is this problem? Literally, all the tables break the current flows, and are "moved"
      // internally to behave as independent external tables, that makes look it likes we moved
      // all outsided without nesting the tree
      temp.add(Paragraph.empty());
    }

    final Iterable<TableCell> cells = temp.skippableMapIndexed((
      int i,
      DocxNode<dynamic> e,
    ) {
      DocxNode<dynamic> tempNode = e;
      // So, coming from the context where you know that Word doesn't
      // have anything like "space between", we need to do some...
      // "jobs" to allow and similar behavior
      //
      // I'd love if Office OOXML have a better and more elegant
      // solution, but this is not the case
      if (mainAxisAlignment == MainAxisAlignment.spaceBetween) {
        // Since Align component has more priority
        // than the configured alignment for every child
        // we can make this easily
        if (i > (child.length / 2).floor() || i + 1 >= child.length) {
          tempNode = e.align(alignment: Alignment.right);
        } else if (i == (child.length / 2).floor() && child.length > 2) {
          tempNode = e.align(alignment: Alignment.center);
        } else {
          tempNode = e.align(alignment: Alignment.left);
        }
      } else if (mainAxisAlignment != null) {
        tempNode = tempNode.align(alignment: mainAxisAlignment!.align());
      }

      return tempNode.tableCell(
        // idk, but, this fixed nested tables with variable width
        // decided by LayoutConstraints
        //
        // Let me cook!
        //
        //
        // Wait, this could simulate the behavior in MainAxisSize?
        // cellConfig: maxWidth > 0
        //     ? TableCellConfig.dxa(
        //         width: (maxWidth / child.length).toInt(),
        //         verticalAlignment: crossAxisAlignment?.vertical(),
        //         borders: TableCellBorders.nil(),
        //       )
        //     : TableCellConfig.auto(
        //         verticalAlignment: crossAxisAlignment?.vertical(),
        //         borders: TableCellBorders.nil(),
        //       ));
        cellConfig: TableCellConfig.auto(
          verticalAlignment: crossAxisAlignment?.vertical(),
          borders: TableCellBorders.nil(),
        ),
      );
    });

    Table table = Table(
      id: id,
      parent: this,
      tableProperties: TableProperties(
        layout: true,
        width: maxWidth,
        alignment: mainAxisAlignment?.align(),
        widthType: maxWidth == 0 ? TableWidthType.auto : TableWidthType.dxa,
        padding: padding,
      ),
      columns: maxWidth > 0
          ? GridColumn(width: (maxWidth / cells.length).toInt()).repeat(cells.length)
          : GridColumn.intrintric().repeat(cells.length),
      rows: TableRow(
        canSplit: true,
        hidden: false,
        isHeader: false,
        height: minHeight > 0 ? minHeight : null,
        heightRule: TableHeightRule.atLeast,
        spacing: spacing,
        cells: cells,
      ).toList(),
    );

    // This fixes the issue where the nested rows, break all the layout
    return LayoutConstraints(
      maxWidth: (maxWidth / cells.length).toInt(),
      children: table.toList(),
    );
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  Row get copy => Row(
        id: id,
        children: child,
      );

  @override
  Row copyWith({
    Iterable<DocxNode>? child,
    String? id,
    DocxNode<dynamic>? parent,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    int? width,
    int? minHeight,
    int? spacing,
  }) {
    return Row(
      children: child ?? this.child,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      width: width ?? this.width,
      minHeight: minHeight ?? this.minHeight,
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
    for (final DocxNode<dynamic> element in child) {
      if (element.isEmptyNode()) continue;
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
    for (final DocxNode element in child) {
      if (element.isEmptyNode()) continue;
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
