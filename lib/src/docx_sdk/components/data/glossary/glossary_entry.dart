import 'package:xml/xml.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../base/docx_node.dart';
import 'glossary_enums.dart';

/// Represents a single glossary entry (docPart) in a DOCX document.
///
/// A glossary entry contains reusable content that can be referenced
/// from Structured Document Tags (SDT) using the placeholder mechanism.
///
/// ## Structure
/// ```xml
/// <w:docPart>
///   <w:docPartPr>
///     <w:name w:val="EntryName" />
///     <w:type w:val="bbPlcHdr" />
///     <w:category w:val="Category" />
///     <w:behavior w:val="p" />
///   </w:docPartPr>
///   <w:docPartBody>
///     <!-- Content goes here -->
///   </w:docPartBody>
/// </w:docPart>
/// ```
///
/// ## Example usage:
/// ```dart
/// final entry = GlossaryEntry(
///   name: 'PlcHdr_Nombre',
///   type: GlossaryEntryType.placeholder,
///   category: 'Form Placeholders',
///   behavior: GlossaryBehavior.content,
///   body: [
///     Paragraph(
///       children: [
///         TextRun.text(
///           text: 'Enter name here...',
///           styles: [italic, color(gray)],
///         ),
///       ],
///     ),
///   ],
/// );
/// ```
///
/// See also:
/// - [GlossaryEntryType] for available entry types
/// - [GlossaryBehavior] for insertion behaviors
/// - [GlossaryStore] for managing multiple entries
class GlossaryEntry {
  /// Creates a new glossary entry.
  ///
  /// The [name] must be unique within the glossary and is used
  /// to reference this entry from SDT placeholders.
  ///
  /// The [body] contains the DocxNode elements that make up
  /// the actual content of this entry.
  GlossaryEntry({
    required this.name,
    required List<DocxNode> body,
    this.type = GlossaryEntryType.placeholder,
    this.category,
    this.description,
    this.behavior = GlossaryBehavior.content,
  }) : _body = body;

  /// The unique name of this entry.
  ///
  /// Used as `w:name w:val="..."` and referenced by SDT placeholders.
  /// Must be unique within the document's glossary.
  final String name;

  /// The type of this glossary entry.
  ///
  /// Defaults to [GlossaryEntryType.placeholder].
  final GlossaryEntryType type;

  /// Optional category for organizing entries.
  ///
  /// Used as `w:category w:val="..."`.
  /// Example: "Form Placeholders", "Legal Text", etc.
  final String? category;

  /// Optional description of this entry.
  ///
  /// Used as `w:description w:val="..."`.
  final String? description;

  /// How this entry behaves when inserted.
  ///
  /// Defaults to [GlossaryBehavior.content].
  final GlossaryBehavior behavior;

  final List<DocxNode> _body;

  /// The body content of this entry as DocxNodes.
  ///
  /// These will be built into `w:docPartBody` XML elements.
  List<DocxNode> get body => List.unmodifiable(_body);

  /// Adds a node to the body.
  void addNode(DocxNode node) {
    _body.add(node);
  }

  /// Adds multiple nodes to the body.
  void addNodes(List<DocxNode> nodes) {
    _body.addAll(nodes);
  }

  /// Builds the `w:docPartPr` XML element containing entry properties.
  XmlElement buildPropertiesXml() {
    final List<XmlNode> children = <XmlNode>[
      XmlElement.tag(
        'w:name',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), name),
        ],
        isSelfClosing: true,
      ),
      XmlElement.tag(
        'w:type',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), type.xmlValue),
        ],
        isSelfClosing: true,
      ),
    ];

    if (category != null) {
      children.add(
        XmlElement.tag(
          'w:category',
          attributes: <XmlAttribute>[
            XmlAttribute('w:val'.toName(), category!),
          ],
          isSelfClosing: true,
        ),
      );
    }

    if (description != null) {
      children
        ..add(
          XmlElement.tag(
            'w:docPartPr',
            children: <XmlNode>[
              XmlElement.tag(
                'w:ver',
                attributes: <XmlAttribute>[
                  XmlAttribute('w:val'.toName(), '1'),
                ],
                isSelfClosing: true,
              ),
              XmlElement.tag(
                'w:attr',
                attributes: <XmlAttribute>[
                  XmlAttribute('w:val'.toName(), 'description'),
                ],
                isSelfClosing: true,
              ),
              XmlElement.tag(
                'w:global',
                isSelfClosing: true,
              ),
            ],
          ),
        )
        ..add(
          XmlElement.tag(
            'w:description',
            attributes: <XmlAttribute>[
              XmlAttribute('w:val'.toName(), description!),
            ],
            isSelfClosing: true,
          ),
        );
    }

    children.add(
      XmlElement.tag(
        'w:behavior',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), behavior.xmlValue),
        ],
        isSelfClosing: true,
      ),
    );

    return XmlElement.tag('w:docPartPr', children: children);
  }

  /// Builds the `w:docPartBody` XML element containing entry content.
  XmlElement buildBodyXml() {
    final List<XmlNode> contentNodes = <XmlNode>[];

    for (final DocxNode node in _body) {
      contentNodes.addAll(node.buildXml());
    }

    return XmlElement.tag('w:docPartBody', children: contentNodes);
  }

  /// Builds the complete `w:docPart` XML element.
  XmlElement buildXml() {
    return XmlElement.tag(
      'w:docPart',
      children: <XmlNode>[
        buildPropertiesXml(),
        buildBodyXml(),
      ],
    );
  }

  /// Creates a copy of this entry with optional overrides.
  GlossaryEntry copyWith({
    String? name,
    GlossaryEntryType? type,
    String? category,
    String? description,
    GlossaryBehavior? behavior,
    List<DocxNode>? body,
  }) {
    return GlossaryEntry(
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      behavior: behavior ?? this.behavior,
      body: body ?? List.from(_body),
    );
  }

  @override
  String toString() {
    return 'GlossaryEntry(name: $name, type: $type, category: $category, bodyNodes: ${_body.length})';
  }
}
