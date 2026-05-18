import '../../docx_sdk/sdk.dart'
    show
        Align,
        Alignment,
        CrossAxisAlignment,
        BuildNodeContext,
        DocxNode,
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
        TableWidthType,
        NumberingList;
import 'cast_ext.dart';

extension WrapNode on DocxNode {
  Paragraph paragraph({
    Iterable<Style> styles = const <Style>[],
    ParagraphPageBreak pageBreak = ParagraphPageBreak.none,
    Numbering? numbering,
    Alignment? align,
    String? id,
    DocxNode? parent,
  }) {
    if (this is RunBase) {
      return Paragraph(
        children: <RunBase<dynamic>>[cast()],
        id: id,
        styles: styles,
        pageBreak: pageBreak,
        numbering: numbering,
        alignment: align,
        parent: parent,
      );
    }

    return Paragraph.run(
      this,
      id: id,
      styles: styles,
      pageBreak: pageBreak,
      numbering: numbering,
      align: align,
      parent: parent,
    );
  }

  NumberingList numbering([String? key]) {
    if (key == null) {
      final NumberingList? owner = getAncestorOfExactType<NumberingList>();
      if (owner == null) {
        throw Exception(
          'key must be provided if '
          'node $runtimeType:$id at $depth is not '
          'wrapped by a NumberingList node',
        );
      }
      return NumberingList.inheritOne(child: this);
    }
    return NumberingList(
      refKey: key,
      children: <DocxNode<dynamic>>[this],
    );
  }

  Align align({
    required Alignment alignment,
    String? id,
    DocxNode? parent,
  }) {
    assert(this is! Align, 'Couldn\'t be possible wrap an Align into another');
    return Align(
      id: id,
      child: this,
      alignment: alignment,
      parent: parent,
    );
  }

  Run run({
    String? id,
    bool wrapInRunMark = true,
    DocxNode? parent,
  }) {
    if (this is RunBase) {
      throw Exception('Cannot wrap $runtimeType:${this.id} into a Run');
    }
    return Run(
      id: id,
      component: this,
      wrapInRunMark: wrapInRunMark,
      parent: parent,
    );
  }

  Drawing drawing({
    String? id,
    DocxNode? parent,
  }) {
    return Drawing(
      id: id,
      child: this,
    )..parent = parent;
  }

  DocxNode lazy({
    String? id,
    DocxNode? parent,
  }) {
    return DocxNode.lazyBuild((BuildNodeContext context, String id) {
      return this..parent = parent;
    })
      ..parent = this;
  }

  PageColumn column({
    String? id,
    DocxNode? parent,
  }) {
    return PageColumn(
      id: id,
      children: <DocxNode<dynamic>>[
        this is RunBase
            ? (paragraph()..parent = parent)
            : (this..parent = parent),
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
    DocxNode? parent,
  }) {
    return Table(
      id: id,
      parent: parent,
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
    DocxNode? parent,
    TableHeightRule? heightRule,
    Alignment? alignment,
    bool isHeader = false,
    int spacing = 0,
    TableCellConfig? cellConfig,
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
    DocxNode? parent,
  }) {
    return TableCell.one(
      id: id,
      child: this,
      cellConfig: cellConfig ?? TableCellConfig.nil(),
      parent: parent,
    );
  }
}

extension WrapNodes on Iterable<DocxNode> {
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
          : map((DocxNode<dynamic> e) => e.run()).cast<RunBase<dynamic>>(),
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
    return map((DocxNode<dynamic> e) => e.run());
  }

  Iterable<Drawing> drawing({
    String? id,
  }) {
    return map((DocxNode<dynamic> e) => e.drawing());
  }

  PageColumn column({
    String? id,
  }) {
    return PageColumn(
      id: id,
      children: <DocxNode<dynamic>>[
        ...(this is Iterable<RunBase<dynamic>>
            ? map(
                (DocxNode<dynamic> e) => e.paragraph(),
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
        ...map<TableRow>((DocxNode<dynamic> e) => e.tableRow(
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
      children: List<DocxNode<dynamic>>.from(this),
    );
  }
}
