import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/string_ext.dart';

/// Drop-down list SDT component for selecting from fixed options.
///
/// Represents a `<w:sdt>` element with `w:dropDownList` type.
/// The user can only select from predefined options - no free text allowed.
///
/// This is ideal for:
/// - Document type selection (DNI, Passport, NIE)
/// - Country/region selection
/// - Civil status selection
/// - Department selection
///
/// ## XML Structure:
/// ```xml
/// <w:sdt>
///   <w:sdtPr>
///     <w:dropDownList>
///       <w:listItem w:displayText="DNI" w:value="dni"/>
///       <w:listItem w:displayText="Pasaporte" w:value="passport"/>
///     </w:dropDownList>
///     <w:alias w:val="Tipo de Documento"/>
///     <w:tag w:val="doc_type"/>
///     <w:id w:val="3001"/>
///   </w:sdtPr>
///   <w:sdtContent>
///     <w:r>
///       <w:t>DNI</w:t>
///     </w:r>
///   </w:sdtContent>
/// </w:sdt>
/// ```
///
/// ## Example usage:
/// ```dart
/// final dropdown = SdtDropDownList(
///   alias: 'Document Type',
///   tag: 'doc_type',
///   items: [
///     SdtListItem(displayText: 'DNI', value: 'dni'),
///     SdtListItem(displayText: 'Pasaporte', value: 'passport'),
///     SdtListItem(displayText: 'NIE', value: 'nie'),
///   ],
///   selectedValue: 'dni',
/// );
/// ```
///
/// See also:
/// - [SdtComboBox] for editable drop-down
/// - [docs/sdt_elements.md] for complete SDT documentation
class SdtDropDownList extends DocxNode<RunBase> with PrintableMixin {
  SdtDropDownList({
    required String alias,
    required this.tag,
    required List<SdtListItem> items,
    String? selectedValue,
    this.sdtId,
    this.placeholder,
    this.showingPlacHdr = true,
    this.lock,
    this.temporary = false,
    super.parent,
    super.id,
  })  : _alias = alias,
        _items = items,
        _selectedValue = selectedValue,
        _displayText = _computeDisplayText(items, selectedValue),
        super(
            child: TextRun.text(
          text: _computeDisplayText(items, selectedValue),
        ));

  // ═══════════════════════════════════════════════════════════
  // PROPIEDADES
  // ═══════════════════════════════════════════════════════════

  /// The alias is the visible label in Word's content control UI.
  final String _alias;
  String get alias => _alias;

  /// Internal tag for programming reference.
  final String tag;

  /// List of available options in the drop-down.
  final List<SdtListItem> _items;

  /// Currently selected value (corresponds to an item's value).
  final String? _selectedValue;
  String? get selectedValue => _selectedValue;

  /// The display text for the selected value.
  final String _displayText;

  /// Optional unique identifier for the SDT.
  /// Note: This is different from DocxNode.id which is auto-generated.
  final int? sdtId;

  /// Placeholder text shown when no selection is made.
  final String? placeholder;

  /// Whether to show the placeholder text.
  final bool showingPlacHdr;

  /// Lock type to prevent editing.
  final StdLock? lock;

  /// If true, the SDT is temporary and not saved permanently.
  final bool temporary;

  /// Helper to compute display text from items and selected value.
  static String _computeDisplayText(List<SdtListItem> items, String? selectedValue) {
    if (selectedValue == null) return '';
    for (final SdtListItem item in items) {
      if (item.value == selectedValue) {
        return item.displayText;
      }
    }
    return '';
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD XML
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
      XmlElement.tag(
        'w:dropDownList',
        children: _items.expand((item) => item.buildXml(context: context)).toList(),
      ),
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
    final List<XmlNode> runs = child.buildXml(context: context);
    return XmlElement.tag('w:sdtContent', children: runs);
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  // ═══════════════════════════════════════════════════════════
  // COPY PATTERN
  // ═══════════════════════════════════════════════════════════

  @override
  SdtDropDownList get copy => SdtDropDownList(
        sdtId: sdtId,
        alias: _alias,
        tag: tag,
        items: _items,
        selectedValue: _selectedValue,
        placeholder: placeholder,
        showingPlacHdr: showingPlacHdr,
        lock: lock,
        temporary: temporary,
        parent: parent,
      );

  @override
  SdtDropDownList copyWith({
    RunBase? child,
    DocxNode<dynamic>? parent,
    String? id,
    String? alias,
    String? tag,
    String? selectedValue,
    String? placeholder,
    bool? showingPlacHdr,
    StdLock? lock,
    bool? temporary,
    List<SdtListItem>? items,
    int? sdtId,
  }) {
    return SdtDropDownList(
      sdtId: sdtId ?? this.sdtId,
      alias: alias ?? _alias,
      tag: tag ?? this.tag,
      items: items ?? _items,
      selectedValue: selectedValue ?? _selectedValue,
      placeholder: placeholder ?? this.placeholder,
      showingPlacHdr: showingPlacHdr ?? this.showingPlacHdr,
      lock: lock ?? this.lock,
      temporary: temporary ?? this.temporary,
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
  String toPlainText() => _displayText;

  @override
  String toString() {
    return 'SdtDropDownList(alias: $_alias, tag: $tag, items: ${_items.length}, selected: $_selectedValue)';
  }
}
