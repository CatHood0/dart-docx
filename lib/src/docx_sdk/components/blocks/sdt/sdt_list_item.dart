import 'package:xml/xml.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../../sdk.dart';

/// List item for drop-down and combo-box SDT controls.
///
/// Represents a single option in a drop-down list or combo-box,
/// with display text shown to users and an internal value.
class SdtListItem extends DocxNode<void> {
  SdtListItem({
    required this.displayText,
    required this.value,
    super.id,
    super.parent,
  }) : super(child: null);

  /// The text shown in the UI when this item is selected.
  final String displayText;

  /// The internal value stored when this item is selected.
  final String value;

  /// Builds the XML element for this list item.
  @override
  List<XmlNode> buildXml() {
    return [
      XmlElement.tag(
        'w:listItem',
        attributes: <XmlAttribute>[
          XmlAttribute('w:displayText'.toName(), displayText),
          XmlAttribute('w:value'.toName(), value),
        ],
        isSelfClosing: true,
      ),
    ];
  }

  @override
  SdtListItem get copy => SdtListItem(
        id: id,
        displayText: displayText,
        value: value,
        parent: parent,
      );

  @override
  SdtListItem copyWith({String? displayText, String? value, String? id, DocxNode<void>? parent}) {
    return SdtListItem(
      id: id ?? this.id,
      displayText: displayText ?? this.displayText,
      value: value ?? this.value,
      parent: parent ?? this.parent,
    );
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
