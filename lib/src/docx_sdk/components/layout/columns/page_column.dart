import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';
import '../../../utils/logger/logger_configs.dart';

/// A container that groups multiple elements to be rendered in a column layout
/// for multi-column documents.
///
/// This component is designed to facilitate the creation of multi-column layouts
/// in DOCX documents, conceptually inspired by column behavior in Flutter,
/// but adapted to the particularities of the document format.
///
/// Recommended only when `SectionOptions` has defined its `ColumnOptions`,
/// because when it is not defined, `Column` behaviors works more as a
/// page breaking instead column breaking
///
/// If the founded number of columns is more than the configured number
/// in `DocumentLayout`, then column break will behavior like a page breaking
/// instead.
@experimental
class PageColumn extends DocxNode<List<DocxNode>> {
  PageColumn({
    required Iterable<DocxNode> children,
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
    if (context.options.columns == null ||
        context.options.columns!.numColumns == null) {
      CompilerLogger.root.warning(
        'Its not recommended the use of "$runtimeType:$id" in none '
        'multi-column documents (ColumnOptions is not defined or numColumns is null). '
        'This will not throw an exception, since '
        'Microsoft Word specifications allow the column breaking '
        'even when it was not configured, but we incentive to '
        'you to not use this with the current configurations ',
      );
    }
    final List<XmlElement> elements = <XmlElement>[];
    for (final DocxNode<dynamic> e in child) {
      final List<XmlElement> element =
          e.buildXml(context: createdInheritedContext(context)).cast();
      if (e is IgnorableMixin && e.cast<IgnorableMixin>().shouldIgnore() ||
          element.isEmpty) {
        continue;
      }
      elements.addAll(element);
    }
    return <XmlElement>[
      if (!ignoreBreak)
        ...Paragraph.run(
          Break.pageBreak(),
        ).buildXml(context: context),
      ...elements,
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) {
    return <XmlNode>[];
  }

  @override
  PageColumn get copy => PageColumn(
        id: id,
        children: child,
      );

  @override
  PageColumn copyWith({
    Iterable<DocxNode>? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return PageColumn(
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
