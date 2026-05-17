import 'package:xml/xml.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../../../../docx.dart';
import 'sdt_enums.dart';

/// Plain text SDT component for single-line text input fields.
///
/// Represents a `<w:sdt>` element with `w:plainText` type.
/// Used for simple text inputs like names, IDs, or short values.
///
/// This is a Content Control that allows users to edit text directly
/// within the Word document while maintaining structure.
///
/// ## Example usage:
/// ```dart
/// final sdt = SdtPlainText(
///   alias: 'client_name',
///   tag: 'client_name',
///   placeholder: '[Enter name]',
///   content: 'John Doe',
/// );
/// ```
///
/// ## Variants:
/// - Basic plainText with content
/// - plainText with placeholder (when empty)
/// - plainText with maxLength validation
/// - plainText with dataBinding to Custom XML Parts
///
/// See also:
/// - [SdtRichText] for multi-paragraph rich text SDT
/// - [docs/sdt_elements.md] for complete SDT documentation
class SdtPlainText extends DocxNode<List<RunBase>> with PrintableMixin {
  SdtPlainText({
    required String alias,
    required this.tag,
    this.sdtId,
    this.placeholder,
    this.showingPlacHdr = true,
    this.maxLength,
    this.lock,
    this.temporary = false,
    List<RunBase> content = const [],
    super.parent,
    super.id,
  })  : _alias = alias,
        _content = content,
        super(child: <RunBase>[...content]) {
    int index = 0;
    for (final RunBase run in child) {
      run
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

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

  /// Maximum character length allowed.
  final int? maxLength;

  /// Lock type to prevent editing.
  final StdLock? lock;

  /// If true, the SDT is temporary and not saved permanently.
  final bool temporary;

  /// The content runs displayed in the SDT.
  final List<RunBase> _content;

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
      XmlElement.tag('w:plainText', isSelfClosing: true),
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

    // Add maxLength if provided
    if (maxLength != null) {
      children.add(
        XmlElement.tag(
          'w:text',
          attributes: <XmlAttribute>[
            XmlAttribute('w:maxLength'.toName(), maxLength.toString()),
          ],
          isSelfClosing: true,
        ),
      );
    }

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
    final List<XmlNode> runs = <XmlNode>[];

    if (_content.isEmpty) {
      // Empty content - show placeholder or empty run
      runs.add(
        XmlElement.tag(
          'w:r',
          children: <XmlNode>[
            XmlElement.tag(
              'w:t',
              children: <XmlNode>[XmlText('')],
            ),
          ],
        ),
      );
    } else {
      // Build runs from content
      for (final RunBase run in _content) {
        runs.addAll(run.buildXml(context: context));
      }
    }

    return XmlElement.tag('w:sdtContent', children: runs);
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  SdtPlainText get copy => SdtPlainText(
        sdtId: sdtId,
        alias: _alias,
        tag: tag,
        placeholder: placeholder,
        showingPlacHdr: showingPlacHdr,
        maxLength: maxLength,
        lock: lock,
        temporary: temporary,
        content: _content,
        parent: parent,
      );

  @override
  SdtPlainText copyWith({
    List<RunBase>? child,
    DocxNode<dynamic>? parent,
    String? id,
    String? alias,
    String? tag,
    String? placeholder,
    bool? showingPlacHdr,
    int? maxLength,
    StdLock? lock,
    bool? temporary,
    List<RunBase>? content,
    int? sdtId,
  }) {
    return SdtPlainText(
      sdtId: sdtId ?? this.sdtId,
      alias: alias ?? _alias,
      tag: tag ?? this.tag,
      placeholder: placeholder ?? this.placeholder,
      showingPlacHdr: showingPlacHdr ?? this.showingPlacHdr,
      maxLength: maxLength ?? this.maxLength,
      lock: lock ?? this.lock,
      temporary: temporary ?? this.temporary,
      content: content ?? _content,
      parent: parent ?? this.parent,
    );
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;

    for (final RunBase run in _content) {
      if (shouldGetElement(run)) return run;
      final DocxNode<dynamic>? found = run.visitElement(
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
      for (final RunBase run in _content) {
        if (shouldGetElement(run)) elements.add(run);
        final List<DocxNode<dynamic>>? found = run.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (found != null) elements.addAll(found);
      }
    }

    return elements.isEmpty ? null : elements;
  }

  /// Returns the plain text content of this SDT.
  @override
  String toPlainText() {
    final StringBuffer buffer = StringBuffer();
    for (final RunBase run in _content) {
      buffer.write(run.toPlainText());
    }
    return buffer.toString();
  }

  @override
  String toString() {
    return 'SdtPlainText(alias: $_alias, tag: $tag, content: ${_content.length} runs)';
  }
}
