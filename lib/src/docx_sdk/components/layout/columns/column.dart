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
/// Using this component avoid making some manual things, since you can do the same
/// thing just inserting `Paragraph(data: [Run(component: Break.columnBreak()]))` at the document root
/// after your content.
///
/// If the founded number of columns is more than the configured number
/// in `DocumentLayout`, then column break will behavior like a page breaking
/// instead.
@experimental
class Column extends DocxTreeNode<List<DocxTreeNode>> {
  Column({
    required Iterable<DocxTreeNode> children,
    super.id,
    super.parent,
  }) : super(data: List.from(children)) {
    int index = 0;
    for (final DocxTreeNode<dynamic> content in data) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  @protected
  bool ignoreBreak = false;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    if (context.options.columns == null ||
        context.options.columns!.numColumns == null) {
      CompilerLogger.root.w(
        'Its not recommended the use of "$runtimeType:$id" in none '
        'multi-column documents (ColumnOptions is not defined or numColumns is null). '
        'This will not throw an exception, since '
        'Microsoft Word specifications allow the column breaking '
        'even when it was not configured, but we incentive to '
        'you to not use this with the current configurations ',
      );
    }
    context.currentContentPart = this;
    final List<XmlElement> elements = <XmlElement>[];
    for (final DocxTreeNode<dynamic> e in data) {
      final List<XmlElement> element = e
          .buildXml(
            context: context,
          )
          .cast();
      if (e is IgnorableMixin && e.cast<IgnorableMixin>().shouldIgnore() ||
          element.isEmpty) {
        continue;
      }
      elements.addAll(element);
    }
    return <XmlElement>[
      ...elements,
      if (!ignoreBreak)
        ...Paragraph(
          data: <RunBase<dynamic>>[
            Run(component: Break(data: BreakType.column)),
          ],
        ).buildXml(context: context),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  Column get copy => Column(
        id: id,
        children: data,
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
    for (final DocxTreeNode element in data) {
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
