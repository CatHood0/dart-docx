import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/string_ext.dart';

/// Picture SDT component for image content controls.
///
/// Represents a `<w:sdt>` element with `w:picture` type.
/// Used for image placeholders that can be replaced by users.
///
/// ## XML Structure:
/// ```xml
/// <w:sdt>
///   <w:sdtPr>
///     <w:picture/>
///     <w:alias w:val="Logo de Empresa"/>
///     <w:tag w:val="company_logo"/>
///     <w:id w:val="7001"/>
///   </w:sdtPr>
///   <w:sdtContent>
///     <w:r>
///       <w:drawing>
///         <wp:inline>
///           <a:graphic>
///             ...
///           </a:graphic>
///         </wp:inline>
///       </w:drawing>
///     </w:r>
///   </w:sdtContent>
/// </w:sdt>
/// ```
///
/// ## Example usage:
/// ```dart
/// final picture = SdtPicture(
///   alias: 'Logo de Empresa',
///   tag: 'company_logo',
/// );
/// ```
///
/// See also:
/// - [docs/sdt_elements.md] for complete SDT documentation
class SdtPicture extends Sdt<RunBase> with PrintableMixin {
  SdtPicture({
    required String alias,
    required this.tag,
    this.placeholder,
    this.showingPlacHdr = true,
    this.lock,
    this.temporary = false,
    RunBase? content,
    super.parent,
    super.id,
    super.sdtId,
  })  : _alias = alias,
        _content = content,
        super(child: content ?? TextRun.empty()) {
    child
      ..parent = this
      ..index = 0
      ..depth = depth + 1;
  }

  /// The alias is the visible label in Word's content control UI.
  final String _alias;
  String get alias => _alias;

  /// Internal tag for programming reference.
  final String tag;

  /// The image content run.
  final RunBase? _content;

  /// Placeholder text shown when no image is set.
  final String? placeholder;

  /// Whether to show the placeholder text.
  final bool showingPlacHdr;

  /// Lock type to prevent editing.
  final StdLock? lock;

  /// If true, the SDT is temporary and not saved permanently.
  final bool temporary;
  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
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

  XmlElement _buildPropertiesXml(BuildNodeContext context) {
    final List<XmlNode> children = <XmlNode>[
      // w:picture element (self-closing)
      XmlElement.tag('w:picture', isSelfClosing: true),
      XmlElement.tag(
        'w:alias',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), _alias),
        ],
        isSelfClosing: true,
      ),
      XmlElement.tag(
        'w:tag',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), tag),
        ],
        isSelfClosing: true,
      ),
    ];

    // Add id - use SdtStore to get unique ID
    final int actualSdtId =
        context.sdtStore.getNextId(nodeId: id, preferredId: sdtId);
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

  XmlElement _buildContentXml(BuildNodeContext context) {
    final List<XmlNode> runs = child.buildXml(context: context);
    return XmlElement.tag('w:sdtContent', children: runs);
  }

  @override
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) {
    return <XmlNode>[];
  }
  @override
  SdtPicture get copy => SdtPicture(
        id: id,
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
  SdtPicture copyWith({
    RunBase? child,
    DocxNode<dynamic>? parent,
    String? id,
    String? alias,
    String? tag,
    String? placeholder,
    bool? showingPlacHdr,
    StdLock? lock,
    bool? temporary,
    RunBase? content,
    int? sdtId,
  }) {
    return SdtPicture(
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
  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? this
        : !visitChildrenIfNeeded
            ? null
            : child.visitElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? <DocxNode<dynamic>>[this]
        : !visitChildrenIfNeeded
            ? null
            : child.visitAllElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  // ═══════════════════════════════════════════════════════════
  // PRINTABLE MIXIN
  // ═══════════════════════════════════════════════════════════

  @override
  String toPlainText() => '';

  @override
  String toString() {
    return 'SdtPicture(alias: $_alias, tag: $tag)';
  }
}
