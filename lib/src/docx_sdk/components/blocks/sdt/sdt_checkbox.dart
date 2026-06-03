import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/string_ext.dart';
import '../../../stores/inherited_stores/glossary_provider.dart';
import '../../../stores/inherited_stores/sdt_store_provider.dart';

/// Checkbox SDT component for binary on/off selection.
///
/// Represents a `<w:sdt>` element with `w14:checkbox` type.
/// Displays a checkbox that can be checked or unchecked by the user.
///
/// ## XML Structure:
/// ```xml
/// <w:sdt>
///   <w:sdtPr>
///     <w14:checkbox>
///       <w14:checked w14:val="1"/>
///       <w14:checkedState w14:val="2612" w14:font="MS Gothic"/>
///       <w14:uncheckedState w14:val="2610" w14:font="MS Gothic"/>
///     </w14:checkbox>
///     <w:alias w:val="Acepto los términos"/>
///     <w:tag w:val="accept_terms"/>
///     <w:id w:val="6001"/>
///   </w:sdtPr>
///   <w:sdtContent>
///     <w:r>
///       <w:t>☒</w:t>
///     </w:r>
///   </w:sdtContent>
/// </w:sdt>
/// ```
///
/// ## Example usage:
/// ```dart
/// final checkbox = SdtCheckbox(
///   alias: 'Acepto los términos',
///   tag: 'accept_terms',
///   checked: true,
/// );
/// ```
///
/// See also:
/// - [docs/sdt_elements.md] for complete SDT documentation
class SdtCheckbox extends Sdt<RunBase> with PrintableMixin {
  SdtCheckbox({
    required String alias,
    required this.tag,
    required bool checked,
    SdtCheckboxState checkedState = SdtCheckboxState.checked,
    SdtCheckboxState uncheckedState = SdtCheckboxState.unchecked,
    this.placeholder,
    this.showingPlacHdr = true,
    this.lock,
    this.temporary = false,
    this.glossaryEntry,
    super.parent,
    super.id,
    super.sdtId,
  })  : _alias = alias,
        _checked = checked,
        this.checkedState = checkedState,
        this.uncheckedState = uncheckedState,
        _displayText = checked ? checkedState.symbol : uncheckedState.symbol,
        super(
            child: TextRun.text(
          text: checked ? checkedState.symbol : uncheckedState.symbol,
        ));

  /// The alias is the visible label in Word's content control UI.
  final String _alias;
  String get alias => _alias;

  /// Internal tag for programming reference.
  final String tag;

  /// Whether the checkbox is currently checked.
  final bool _checked;
  bool get checked => _checked;

  /// The symbol to show when checked.
  final SdtCheckboxState checkedState;

  /// The symbol to show when unchecked.
  final SdtCheckboxState uncheckedState;

  /// The display text (checkbox symbol).
  final String _displayText;

  /// Placeholder text shown when the checkbox is empty.
  final String? placeholder;

  /// Whether to show the placeholder text.
  final bool showingPlacHdr;

  /// Lock type to prevent editing.
  final StdLock? lock;

  /// If true, the SDT is temporary and not saved permanently.
  final bool temporary;

  /// Glossary entry for placeholder content.
  ///
  /// When provided, this entry is auto-registered to the [GlossaryStore]
  /// and its name is used as the placeholder reference.
  final GlossaryEntry? glossaryEntry;

  /// Returns the placeholder name to use in XML.
  ///
  /// If [glossaryEntry] is provided, uses its name; otherwise uses [placeholder].
  String? get placeholderName => glossaryEntry?.name ?? placeholder;

  @override
  void perform() {
    // Auto-register glossary entry if provided
    if (glossaryEntry != null && isChildOf<GlossaryProvider>()) {
      GlossaryProvider.of(this).addEntry(glossaryEntry!);
    }
    super.perform();
  }

  @override
  List<XmlElement> buildXml() {
    return <XmlElement>[
      XmlElement.tag(
        'w:sdt',
        children: <XmlNode>[
          _buildPropertiesXml(),
          _buildContentXml(),
        ],
      ),
      ...Run.lineBreak().paragraph().buildXml(),
    ];
  }

  XmlElement _buildPropertiesXml() {
    final List<XmlNode> children = <XmlNode>[
      // w14:checkbox element
      XmlElement.tag(
        'w14:checkbox',
        children: <XmlNode>[
          // w14:checked
          XmlElement.tag(
            'w14:checked',
            attributes: <XmlAttribute>[
              XmlAttribute('w14:val'.toName(), _checked ? '1' : '0'),
            ],
            isSelfClosing: true,
          ),
          // w14:checkedState
          XmlElement.tag(
            'w14:checkedState',
            attributes: <XmlAttribute>[
              XmlAttribute('w14:val'.toName(), checkedState.code),
              XmlAttribute('w14:font'.toName(), checkedState.font),
            ],
            isSelfClosing: true,
          ),
          // w14:uncheckedState
          XmlElement.tag(
            'w14:uncheckedState',
            attributes: <XmlAttribute>[
              XmlAttribute('w14:val'.toName(), uncheckedState.code),
              XmlAttribute('w14:font'.toName(), uncheckedState.font),
            ],
            isSelfClosing: true,
          ),
        ],
      ),
      XmlElement.tag(
        'w:alias',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), _alias),
        ],
        isSelfClosing: true,
      ),
      XmlElement.tag(
        'w:label',
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

    final int actualSdtId = SdtStoreProvider.of(this).getNextId(
      nodeId: id,
      preferredId: sdtId,
    );
    children.add(
      XmlElement.tag(
        'w:id',
        attributes: <XmlAttribute>[
          XmlAttribute(
            'w:val'.toName(),
            actualSdtId.toString(),
          ),
        ],
        isSelfClosing: true,
      ),
    );

    // Add placeholder
    if (placeholderName != null) {
      children.add(
        XmlElement.tag(
          'w:placeholder',
          children: <XmlNode>[
            XmlElement.tag(
              'w:docPart',
              attributes: <XmlAttribute>[
                XmlAttribute('w:val'.toName(), placeholderName!),
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

  XmlElement _buildContentXml() {
    final List<XmlNode> runs = child.buildXml();
    return XmlElement.tag('w:sdtContent', children: runs);
  }

  @override
  List<XmlNode> buildXmlStyle() {
    return <XmlNode>[];
  }

  @override
  SdtCheckbox get copy => SdtCheckbox(
        id: id,
        sdtId: sdtId,
        alias: _alias,
        tag: tag,
        checked: _checked,
        checkedState: this.checkedState,
        uncheckedState: this.uncheckedState,
        placeholder: placeholder,
        showingPlacHdr: showingPlacHdr,
        lock: lock,
        temporary: temporary,
        glossaryEntry: glossaryEntry,
        parent: parent,
      );

  @override
  SdtCheckbox copyWith({
    RunBase? child,
    DocxNode<dynamic>? parent,
    String? id,
    String? alias,
    String? tag,
    bool? checked,
    SdtCheckboxState? checkedState,
    SdtCheckboxState? uncheckedState,
    String? placeholder,
    bool? showingPlacHdr,
    StdLock? lock,
    bool? temporary,
    GlossaryEntry? glossaryEntry,
    int? sdtId,
  }) {
    return SdtCheckbox(
      sdtId: sdtId ?? this.sdtId,
      alias: alias ?? _alias,
      tag: tag ?? this.tag,
      checked: checked ?? _checked,
      checkedState: checkedState ?? this.checkedState,
      uncheckedState: uncheckedState ?? this.uncheckedState,
      placeholder: placeholder ?? this.placeholder,
      showingPlacHdr: showingPlacHdr ?? this.showingPlacHdr,
      lock: lock ?? this.lock,
      temporary: temporary ?? this.temporary,
      glossaryEntry: glossaryEntry ?? this.glossaryEntry,
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

  @override
  String toPlainText() => _displayText;

  @override
  String toString() {
    return 'SdtCheckbox(alias: $_alias, tag: $tag, checked: $_checked)';
  }
}
