import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';
import '../../../xml_components/document/xml_section_configuration_component.dart';

/// A container component that defines a document section with specific layout properties.
///
/// In Word/DOCX, sections are fundamental units that can have their own page configuration
/// independent of other parts of the document. This component allows creating sections
/// with customized layout settings such as page size, margins, columns, headers/footers,
/// and more.
///
/// **Take in account these things:**
/// - Each section can have unique page layout settings
/// - Sections are separated by section breaks in Word
/// - Layout changes (like columns, orientation) typically require a new section
/// - The section configuration is applied to all content within the section
///
/// **Behavior:**
/// 1. **Content Grouping**: Groups multiple document elements (paragraphs, tables, etc.)
///    into a logical section unit
/// 3. **Section Break**: Automatically adds a section break with the specified layout
///    at the end of the section's content
///
/// **Usage Example:**
/// ```dart
/// final section = Section(
///   layout: DocumentLayout(
///     size: PageSize.letter,
///     margins: DocumentMargins.fromInches(
///       top: 1.02,
///       right: 1.52,
///       left: 1.52,
///       bottom: 1.52,
///       header: 0,
///       footer: 0,
///       gutter: 0,
///     ),
///     columns: ColumnOptions(
///       numColumns: 2,
///       equalWidth: true,
///     ),
///   ),
///   children: [
///     Paragraph.text(text: 'Section 1 Content'),
///     Table(rows: [...]),
///   ],
/// );
/// ```
///
/// **How Sections Work in Word:**
/// - When Word encounters a section break, it applies the new layout settings
///   to all subsequent content
/// - The section's layout settings are defined in the last paragraph of the section
///   via `<w:sectPr>` element
/// - Multiple sections allow different parts of a document to have different
///   formatting (e.g., portrait/landscape mix, different headers, column layouts)
///
/// **Note**: This is an experimental component (@experimental) and its API may change
/// as the DOCX library evolves.
@experimental
class Section extends DocxTreeNode<List<DocxTreeNode>> {
  Section({
    required Iterable<DocxTreeNode> children,
    required this.layout,
    super.id,
    super.parent,
  }) : super(child: List.from(children)) {
    int index = 0;
    for (final DocxTreeNode<dynamic> content in child) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  /// The layout configuration to apply to this section.
  ///
  /// This `DocumentLayout` object contains all the page settings that will be
  /// applied to the section, including:
  /// - Page size and orientation
  /// - Margins (top, bottom, left, right, header, footer)
  /// - Column configuration (number of columns, spacing)
  ///
  /// Not implemented yet
  /// - Page numbering settings
  /// - Section type (continuous, nextPage, evenPage, oddPage, nextColumn)
  /// - Header/footer references
  final DocumentLayout layout;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    context.currentContentPart = this;
    final List<XmlElement> elements = <XmlElement>[];
    for (final DocxTreeNode<dynamic> e in child) {
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
      // This creates the section break with the specified layout settings
      // In Word, the <w:sectPr> element typically appears in the last paragraph
      // of a section to define the layout for the NEXT section
      XmlElementWithChild(
        xmlKey: xmlParagraphNode,
        value: XmlDocumentSectionSettingsComponent(
          options: layout,
        ),
      ).buildXml(context),
    ];
  }

  @override
  Section get copy => Section(
        id: id,
        children: child,
        layout: layout,
      );

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final DocxTreeNode<dynamic> element in child) {
      if (element.isEmptyNode()) continue;
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
    if (child.isEmpty) return <DocxTreeNode>[];
    final List<DocxTreeNode> elements = <DocxTreeNode>[];
    for (final DocxTreeNode element in child) {
      if (element.isEmptyNode()) continue;
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
