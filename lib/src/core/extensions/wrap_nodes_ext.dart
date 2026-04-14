import '../../docx_sdk/sdk.dart'
    show
        Align,
        Alignment,
        CrossAxisAlignment,
        DocumentContext,
        DocxTreeNode,
        Drawing,
        GridColumn,
        MainAxisAlignment,
        Numbering,
        PageColumn,
        Paragraph,
        ParagraphPageBreak,
        Row,
        Run,
        RunBase,
        Style,
        Table,
        TableBorder,
        TableBorders,
        TableCell,
        TableCellConfig,
        TableHeightRule,
        TableProperties,
        TableRow,
        TableWidthType;
import 'cast_ext.dart';

extension WrapNode on DocxTreeNode {
  Paragraph paragraph({
    Iterable<Style> styles = const <Style>[],
    ParagraphPageBreak pageBreak = ParagraphPageBreak.none,
    Numbering? numbering,
    Alignment? align,
    String? id,
  }) {
    if (this is RunBase) {
      return Paragraph(
        children: <RunBase<dynamic>>[cast()],
        id: id,
        styles: styles,
        pageBreak: pageBreak,
        numbering: numbering,
        alignment: align,
      );
    }

    return Paragraph.run(
      this,
      id: id,
      styles: styles,
      pageBreak: pageBreak,
      numbering: numbering,
      align: align,
    );
  }

  Align align({
    required Alignment alignment,
    String? id,
  }) {
    assert(this is! Align, 'Couldn\'t be possible wrap an Align into another');
    return Align(
      id: id,
      child: this,
      alignment: alignment,
    );
  }

  Run run({
    String? id,
    bool wrapInRunMark = true,
  }) {
    if (this is RunBase) {
      throw Exception('Cannot wrap $runtimeType:${this.id} into a Run');
    }
    return Run(
      id: id,
      component: this,
      wrapInRunMark: wrapInRunMark,
    );
  }

  Drawing drawing({
    String? id,
  }) {
    return Drawing(
      id: id,
      child: this,
    );
  }

  DocxTreeNode lazy({
    String? id,
  }) {
    return DocxTreeNode.lazyBuild((DocumentContext context, String id) {
      return this;
    });
  }

  PageColumn column({
    String? id,
  }) {
    return PageColumn(
      id: id,
      children: <DocxTreeNode<dynamic>>[
        this is RunBase ? paragraph() : this,
      ],
    );
  }

  Table table({
    String? id,
    bool variableWidth = false,
    Alignment? align,
    Iterable<GridColumn>? columns,
    TableCellConfig? cellConfig,
    TableProperties? tableProperties,
    int? height,
    int spacing = 0,
    Alignment? alignment,
    TableHeightRule? heightRule,
    bool? canSplit,
    bool? hidden,
    bool isHeader = false,
  }) {
    return Table(
      id: id,
      rows: <TableRow>[
        tableRow(
          cellConfig: cellConfig,
          heightRule: heightRule,
          height: height,
          canSplit: canSplit,
          hidden: hidden,
          alignment: alignment,
          spacing: spacing,
          isHeader: isHeader,
        ),
      ],
      columns: columns?.toList() ?? GridColumn.intrintric().toList(),
      tableProperties: tableProperties ??
          TableProperties(
            layout: !variableWidth,
            widthType: variableWidth ? TableWidthType.auto : TableWidthType.nil,
            alignment: align ?? Alignment.center,
            borders: TableBorders.all(TableBorder.none()),
          ),
    );
  }

  TableRow tableRow({
    String? id,
    bool? canSplit,
    bool? hidden,
    int? height,
    TableHeightRule? heightRule,
    Alignment? alignment,
    bool isHeader = false,
    int spacing = 0,
    TableCellConfig? cellConfig,
    DocxTreeNode? parent,
  }) {
    return TableRow(
      id: id,
      heightRule: heightRule,
      height: height,
      canSplit: canSplit,
      hidden: hidden,
      alignment: alignment,
      spacing: spacing,
      isHeader: isHeader,
      parent: parent,
      cells: <TableCell>[
        tableCell(cellConfig: cellConfig),
      ],
    );
  }

  TableCell tableCell({
    String? id,
    TableCellConfig? cellConfig,
  }) {
    return TableCell.one(
      id: id,
      child: this,
      cellConfig: cellConfig ?? TableCellConfig.nil(),
    );
  }
}

extension WrapNodes on Iterable<DocxTreeNode> {
  Paragraph paragraph({
    Iterable<Style> styles = const <Style>[],
    ParagraphPageBreak pageBreak = ParagraphPageBreak.none,
    Numbering? numbering,
    Alignment? align,
    String? id,
  }) {
    return Paragraph(
      children: this is Iterable<RunBase<dynamic>>
          ? this.cast<RunBase<dynamic>>()
          : map((DocxTreeNode<dynamic> e) => e.run()).cast<RunBase<dynamic>>(),
      id: id,
      styles: styles,
      pageBreak: pageBreak,
      numbering: numbering,
      alignment: align,
    );
  }

  Iterable<Run> run({
    String? id,
  }) {
    return map((DocxTreeNode<dynamic> e) => e.run());
  }

  Iterable<Drawing> drawing({
    String? id,
  }) {
    return map((DocxTreeNode<dynamic> e) => e.drawing());
  }

  PageColumn column({
    String? id,
  }) {
    return PageColumn(
      id: id,
      children: <DocxTreeNode<dynamic>>[
        ...(this is Iterable<RunBase<dynamic>>
            ? map(
                (DocxTreeNode<dynamic> e) => e.paragraph(),
              )
            : this),
      ],
    );
  }

  Table table({
    String? id,
    bool variableWidth = false,
    Alignment? align,
    Iterable<GridColumn>? columns,
    TableCellConfig? cellConfig,
    TableProperties? tableProperties,
    int? height,
    int spacing = 0,
    Alignment? alignment,
    TableHeightRule? heightRule,
    bool? canSplit,
    bool? hidden,
    bool isHeader = false,
  }) {
    return Table(
      id: id,
      rows: <TableRow>[
        ...map<TableRow>((DocxTreeNode<dynamic> e) => e.tableRow(
              cellConfig: cellConfig,
              heightRule: heightRule,
              height: height,
              canSplit: canSplit,
              hidden: hidden,
              alignment: alignment,
              spacing: spacing,
              isHeader: isHeader,
            )).cast(),
      ],
      columns: columns?.toList() ?? GridColumn.intrintric().repeat(length - 1),
      tableProperties: tableProperties ??
          TableProperties(
            layout: !variableWidth,
            widthType: variableWidth ? TableWidthType.auto : TableWidthType.nil,
            alignment: align ?? Alignment.center,
            borders: TableBorders.all(TableBorder.none()),
          ),
    );
  }

  Row row({
    String? id,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    int? width,
  }) {
    return Row(
      id: id,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      width: width ?? 0,
      children: List<DocxTreeNode<dynamic>>.from(this),
    );
  }
}
