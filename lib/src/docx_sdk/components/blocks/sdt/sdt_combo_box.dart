import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/string_ext.dart';

/// Combo-box SDT component for editable drop-down selection.
///
/// Represents a `<w:sdt>` element with `w:comboBox` type.
/// Unlike [SdtDropDownList], this allows users to either select
/// a predefined option OR type custom text.
///
/// This is ideal for:
/// - Country selection with "Other" option
/// - Color selection with "Other: [specify]" option
/// - Category selection with "Other" option
///
/// ## XML Structure:
/// ```xml
/// <w:sdt>
///   <w:sdtPr>
///     <w:comboBox>
///       <w:listItem w:displayText="Rojo" w:value="red"/>
///       <w:listItem w:displayText="Azul" w:value="blue"/>
///     </w:comboBox>
///     <w:alias w:val="Color"/>
///     <w:tag w:val="favorite_color"/>
///     <w:id w:val="4001"/>
///   </w:sdtPr>
///   <w:sdtContent>
///     <w:r>
///       <w:t>Azul</w:t>
///     </w:r>
///   </w:sdtContent>
/// </w:sdt>
/// ```
///
/// ## Example usage:
/// ```dart
/// final combo = SdtComboBox(
///   alias: 'Country',
///   tag: 'country',
///   items: [
///     SdtListItem(displayText: 'Spain', value: 'es'),
///     SdtListItem(displayText: 'France', value: 'fr'),
///     SdtListItem(displayText: 'Germany', value: 'de'),
///     SdtListItem(displayText: 'Other', value: 'other'),
///   ],
///   selectedValue: 'es',
/// );
/// ```
///
/// See also:
/// - [SdtDropDownList] for non-editable drop-down
/// - [docs/sdt_elements.md] for complete SDT documentation
class SdtComboBox extends Sdt<List<SdtListItem>> with PrintableMixin {
  SdtComboBox({
    required String alias,
    required this.tag,
    required List<SdtListItem> items,
    String? selectedValue,
    this.placeholder,
    this.showingPlacHdr = true,
    this.lock,
    this.temporary = false,
    super.parent,
    super.id,
    super.sdtId,
  })  : _alias = alias,
        _selectedValue = selectedValue,
        _displayText = _computeDisplayText(items, selectedValue),
        super(child: items);

  /// The alias is the visible label in Word's content control UI.
  final String _alias;
  String get alias => _alias;

  /// Internal tag for programming reference.
  final String tag;

  /// Currently selected value (corresponds to an item's value).
  final String? _selectedValue;
  String? get selectedValue => _selectedValue;

  /// The display text for the selected value.
  final String _displayText;

  /// Placeholder text shown when no selection is made.
  final String? placeholder;

  /// Whether to show the placeholder text.
  final bool showingPlacHdr;

  /// Lock type to prevent editing.
  final StdLock? lock;

  /// If true, the SDT is temporary and not saved permanently.
  final bool temporary;

  /// Helper to compute display text from items and selected value.
  static String _computeDisplayText(
      List<SdtListItem> items, String? selectedValue) {
    if (selectedValue == null) return '';
    for (final SdtListItem item in items) {
      if (item.value == selectedValue) {
        return item.displayText;
      }
    }
    // For comboBox, if value not in list, return it as-is (custom text)
    return selectedValue;
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
    ];
  }

  XmlElement _buildPropertiesXml() {
    final List<XmlNode> children = <XmlNode>[
      XmlElement.tag(
        'w:comboBox',
        children: () {
          final List<XmlNode> nodes = [];
          for (var item in child) {
            nodes.addAll(item.ensureInitialized(context).buildXml());
          }
          return nodes;
        }()
            .toList(),
      ),
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
      XmlElement.tag(
        'w:id',
        attributes: <XmlAttribute>[
          XmlAttribute(
              'w:val'.toName(),
              context.sdtStore
                  .getNextId(nodeId: id, preferredId: sdtId)
                  .toString()),
        ],
        isSelfClosing: true,
      ),
      if (placeholder != null)
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
      XmlElement.tag(
        'w:showingPlacHdr',
        attributes: <XmlAttribute>[
          XmlAttribute('w:val'.toName(), showingPlacHdr ? '1' : '0'),
        ],
        isSelfClosing: true,
      ),
      if (lock != null)
        XmlElement.tag(
          'w:lock',
          attributes: <XmlAttribute>[
            XmlAttribute('w:val'.toName(), lock!.type),
          ],
          isSelfClosing: true,
        ),
      if (temporary)
        XmlElement.tag(
          'w:temporary',
          attributes: <XmlAttribute>[
            XmlAttribute('w:val'.toName(), '1'),
          ],
          isSelfClosing: true,
        ),
    ];

    return XmlElement.tag('w:sdtPr', children: children);
  }

  XmlElement _buildContentXml() {
    final List<XmlNode> runs = TextRun.empty(
      parent: this,
    ).ensureInitialized(context).buildXml();
    return XmlElement.tag('w:sdtContent', children: runs);
  }

  @override
  List<XmlNode> buildXmlStyle() {
    return <XmlNode>[];
  }

  @override
  SdtComboBox get copy => SdtComboBox(
        id: id,
        sdtId: sdtId,
        alias: _alias,
        items: child,
        tag: tag,
        selectedValue: _selectedValue,
        placeholder: placeholder,
        showingPlacHdr: showingPlacHdr,
        lock: lock,
        temporary: temporary,
        parent: parent,
      );

  @override
  SdtComboBox copyWith({
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
    return SdtComboBox(
      sdtId: sdtId ?? this.sdtId,
      alias: alias ?? _alias,
      tag: tag ?? this.tag,
      items: items ?? child,
      selectedValue: selectedValue ?? _selectedValue,
      placeholder: placeholder ?? this.placeholder,
      showingPlacHdr: showingPlacHdr ?? this.showingPlacHdr,
      lock: lock ?? this.lock,
      temporary: temporary ?? this.temporary,
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
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxNode>? foundedEl = element.visitAllElement(
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

  @override
  String toPlainText() => _displayText;

  @override
  String toString() {
    return 'SdtComboBox(alias: $_alias, tag: $tag, items: ${child.length}, selected: $_selectedValue)';
  }
}
