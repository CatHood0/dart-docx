import 'package:xml/xml.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../../../../docx.dart';
import 'sdt_enums.dart';

/// Rich text SDT component for multi-paragraph formatted text input.
///
/// Represents a `<w:sdt>` element with rich text content.
/// Used for complex text inputs like clauses, descriptions, or notes
/// that require multiple paragraphs and rich formatting.
///
/// This is a Content Control that allows users to edit formatted text
/// directly within the Word document while maintaining structure.
///
/// ## Example usage:
/// ```dart
/// final sdt = SdtRichText(
///   alias: 'contract_clause',
///   tag: 'clause_1',
///   content: [
///     Paragraph(children: [
///       TextRun(text: 'PRIMERA. ', bold: true),
///       TextRun(text: 'El presente contrato se rige por...'),
///     ]),
///   ],
/// );
/// ```
///
/// ## Variants:
/// - Basic richText with paragraphs
/// - richText with placeholder (when empty)
/// - richText with formatting properties (rPr)
/// - richText with dataBinding to Custom XML Parts
///
/// See also:
/// - [SdtPlainText] for single-line plain text SDT
/// - [docs/sdt_elements.md] for complete SDT documentation
class SdtRichText extends DocxNode<List<DocxNode>> with PrintableMixin {
  SdtRichText({
    required String alias,
    required this.tag,
    this.sdtId,
    this.placeholder,
    this.showingPlacHdr = true,
    this.lock,
    this.temporary = false,
    Iterable<DocxNode> content = const [],
    super.parent,
    super.id,
  })  : _alias = alias,
        _content = content.toList(),
        super(child: content.toList()) {
    int index = 0;
    for (final DocxNode node in child) {
      node
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PROPIEDADES
  // ═══════════════════════════════════════════════════════════

  /// The alias is the visible label in Word's content control UI.
  final String _alias;
  String get alias => _alias;

  /// Internal tag for programming reference.
  final String tag;

  /// Optional unique identifier for the SDT.
  /// Note: This is different from DocxNode.id which is auto-generated.
  final int? sdtId;

  /// Placeholder text shown when the field is empty.
  final String? placeholder;

  /// Whether to show the placeholder text.
  final bool showingPlacHdr;

  /// Lock type to prevent editing.
  final StdLock? lock;

  /// If true, the SDT is temporary and not saved permanently.
  final bool temporary;

  /// The content paragraphs displayed in the SDT.
  final List<DocxNode> _content;

  // ═══════════════════════════════════════════════════════════
  // MÉTODOS DE BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'w:sdt',
        children: <XmlNode>[
          _buildPropertiesXml(context),
          _buildContentXml(context),
        ],
      ),
    ];
  }

  XmlElement _buildPropertiesXml(DocumentContext context) {
    final List<XmlNode> children = <XmlNode>[
      XmlElement.tag('w:richText', isSelfClosing: true),
    ]

      // Add alias
      ..add(
        XmlElement.tag(
          'w:alias',
          attributes: <XmlAttribute>[
            XmlAttribute('w:val'.toName(), _alias),
          ],
          isSelfClosing: true,
        ),
      )

      // Add tag
      ..add(
        XmlElement.tag(
          'w:tag',
          attributes: <XmlAttribute>[
            XmlAttribute('w:val'.toName(), tag),
          ],
          isSelfClosing: true,
        ),
      );

    // Add id - use SdtStore to get unique ID
    final int actualSdtId = context.sdtStore.getNextId(preferredId: sdtId);
    children.add(
      XmlElement.tag(
        'w:id',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), actualSdtId.toString()),
        ],
        isSelfClosing: true,
      ),
    );

    // Add placeholder
    if (placeholder != null) {
      children.add(
        XmlElement.tag(
          'w:placeholder',
          children: <XmlNode>[
            XmlElement.tag(
              'w:docPart',
              attributes: <XmlAttribute>[
                XmlAttribute('w:val'.toName(), placeholder!),
              ],
              isSelfClosing: true,
            ),
          ],
        ),
      );
    }

    // Add showingPlacHdr
    children.add(
      XmlElement.tag(
        'w:showingPlacHdr',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), showingPlacHdr ? '1' : '0'),
        ],
        isSelfClosing: true,
      ),
    );

    // Add lock if provided
    if (lock != null) {
      children.add(
        XmlElement.tag(
          'w:lock',
          attributes: <XmlAttribute>[
            XmlAttribute('w:val'.toName(), lock!.type),
          ],
          isSelfClosing: true,
        ),
      );
    }

    // Add temporary if true
    if (temporary) {
      children.add(
        XmlElement.tag(
          'w:temporary',
          attributes: <XmlAttribute>[
            XmlAttribute('w:val'.toName(), '1'),
          ],
          isSelfClosing: true,
        ),
      );
    }

    return XmlElement.tag('w:sdtPr', children: children);
  }

  XmlElement _buildContentXml(DocumentContext context) {
    final List<XmlNode> paragraphs = <XmlNode>[];

    if (_content.isEmpty) {
      // Empty content - show placeholder or empty paragraph
      paragraphs.add(
        XmlElement.tag(
          'w:p',
          children: <XmlNode>[
            XmlElement.tag(
              'w:r',
              children: <XmlNode>[
                XmlElement.tag(
                  'w:t',
                  children: <XmlNode>[XmlText('')],
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Build paragraphs from content
      for (final DocxNode node in _content) {
        paragraphs.addAll(node.buildXml(context: context));
      }
    }

    return XmlElement.tag('w:sdtContent', children: paragraphs);
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  // ═══════════════════════════════════════════════════════════
  // COPY PATTERN
  // ═══════════════════════════════════════════════════════════

  @override
  SdtRichText get copy => SdtRichText(
        sdtId: sdtId,
        alias: _alias,
        tag: tag,
        placeholder: placeholder,
        showingPlacHdr: showingPlacHdr,
        lock: lock,
        temporary: temporary,
        content: _content,
        parent: parent,
      );

  @override
  SdtRichText copyWith({
    Iterable<DocxNode>? child,
    DocxNode<dynamic>? parent,
    String? id,
    String? alias,
    String? tag,
    String? placeholder,
    bool? showingPlacHdr,
    StdLock? lock,
    bool? temporary,
    Iterable<DocxNode>? content,
    int? sdtId,
  }) {
    return SdtRichText(
      sdtId: sdtId ?? this.sdtId,
      alias: alias ?? _alias,
      tag: tag ?? this.tag,
      placeholder: placeholder ?? this.placeholder,
      showingPlacHdr: showingPlacHdr ?? this.showingPlacHdr,
      lock: lock ?? this.lock,
      temporary: temporary ?? this.temporary,
      content: content ?? _content,
      parent: parent ?? this.parent,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // VISIT PATTERN
  // ═══════════════════════════════════════════════════════════

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;

    for (final DocxNode node in _content) {
      if (shouldGetElement(node)) return node;
      final DocxNode<dynamic>? found = node.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: true,
      );
      if (found != null) return found;
    }
    return null;
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    final List<DocxNode> elements = <DocxNode>[];

    if (shouldGetElement(this)) elements.add(this);

    if (visitChildrenIfNeeded) {
      for (final DocxNode node in _content) {
        if (shouldGetElement(node)) elements.add(node);
        final List<DocxNode<dynamic>>? found = node.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (found != null) elements.addAll(found);
      }
    }

    return elements.isEmpty ? null : elements;
  }

  // ═══════════════════════════════════════════════════════════
  // PRINTABLE MIXIN
  // ═══════════════════════════════════════════════════════════

  /// Returns the plain text content of this SDT.
  @override
  String toPlainText() {
    final StringBuffer buffer = StringBuffer();
    for (final DocxNode node in _content) {
      if (node is PrintableMixin) {
        buffer.write((node as PrintableMixin).toPlainText());
      }
    }
    return buffer.toString();
  }

  @override
  String toString() {
    return 'SdtRichText(alias: $_alias, tag: $tag, content: ${_content.length} nodes)';
  }
}
