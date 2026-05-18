import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';
import '../../../utils/logger/logger_configs.dart';

/// A container that groups multiple elements to be rendered in a row layout
/// using tables internally
@experimental
class Column extends DocxNode<List<DocxNode>> {
  Column({
    required Iterable<DocxNode> children,
    this.align,
    this.fixedWidth = false,
    this.width = 0,
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

  final int width;
  final Alignment? align;
  final bool fixedWidth;

  @protected
  bool ignoreBreak = false;

  void add(DocxNode node) {
    child.add(node);
  }

  void addFirst(DocxNode node) {
    child.insert(0, node);
  }

  void addAt(int index, DocxNode node) {
    child.insert(index, node);
  }

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
    final Iterable<DocxNode<dynamic>> columns = child.where(
        (DocxNode<dynamic> e) =>
            e is! IgnorableMixin ||
            !e.cast<IgnorableMixin>().shouldIgnore() ||
            !e.isEmptyNode());

    final List<XmlElement> elements = <XmlElement>[];
    for (final DocxNode<dynamic> c in columns) {
      elements.addAll(c
          .buildXml(
              context: createdInheritedContext(
            context,
          ))
          .cast());
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
        getAncestorOfExactType<Table>() != null) {
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
      // What is this problem? Literally, all the tables break the current flows, and are "moved"
      // internally to behave as independent external tables, that makes look it likes we moved
      // all outsided without nesting the tree
      elements.addAll(Paragraph.empty().buildXml(
          context: createdInheritedContext(
        context,
      )));
    }

    return <XmlElement>[
      ...elements,
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) {
    return <XmlNode>[];
  }

  @override
  Column get copy => Column(
        id: id,
        align: align,
        fixedWidth: fixedWidth,
        width: width,
        children: child,
      );

  @override
  Column copyWith({
    Iterable<DocxNode>? child,
    String? id,
    DocxNode<dynamic>? parent,
    int? width,
    Alignment? align,
    bool? fixedWidth,
  }) {
    return Column(
      children: child ?? this.child,
      width: width ?? this.width,
      align: align ?? this.align,
      fixedWidth: fixedWidth ?? this.fixedWidth,
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
          visitChildrenIfNeeded: visitChildrenIfNeeded,
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
    final List<DocxNode> elements = <DocxNode>[];
    for (final DocxNode element in child) {
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
