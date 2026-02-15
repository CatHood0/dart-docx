import 'package:xml/xml.dart';

import '../../../docx.dart' show XmlComponentBase, XmlComponentAttributes;
import '../docx_component_context.dart';

// ---- SCHEMA ----
// <complexType name="CT_LatentStyles">
// 	<sequence>
// 	<element name="lsdException" type="CT_LsdException" minOccurs="0" maxOccurs="unbounded"/>
// 	</sequence>
// 	<attribute name="defLockedState" type="ST_OnOff"/>
// 	<attribute name="defUIPriority" type="ST_DecimalNumber"/>
// 	<attribute name="defSemiHidden" type="ST_OnOff"/>
// 	<attribute name="defUnhideWhenUsed" type="ST_OnOff"/>
// 	<attribute name="defQFormat" type="ST_OnOff"/>
// 	<attribute name="count" type="ST_DecimalNumber"/>
// </complexType>

/// Defines all the default metadata of every style in the document
///
/// These are used when you want to define the default behavior of styles that are not defined in the document but are known
/// to the hosting application (for example, Microsoft Word). This is useful in scenarios such as:
///
/// * Document protection: If the use of styles not defined in the document is blocked, you need to know which ones should be blocked.
/// * Managing hidden or invisible styles: Preventing certain styles from appearing in the user interface.
/// * Interface priorities: Defining which styles are displayed first in style menus.
/// * Styles that are unlocked when used: Allowing certain styles to be displayed only when they are used in the text.
///
/// For more info, check: https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_latentStyles_topic_ID0EFKMT.html
class LatentStyles extends XmlComponentBase<void> {
  LatentStyles({
    required this.defSemiHidden,
    required this.defUnhideWhenUsed,
    required this.defUIPriority,
    required this.defLockedState,
    required this.defQFormat,
    required this.count,
    required this.exceptions,
  }) : super(
          value: null,
          xmlKey: 'w:latentStyles',
        );

  LatentStyles.base()
      : defSemiHidden = true,
        defUnhideWhenUsed = true,
        defLockedState = false,
        defUIPriority = 9,
        defQFormat = false,
        count = 0,
        exceptions = <LatentException>[],
        super(
          value: null,
          xmlKey: 'w:latentStyles',
        );

  final bool defSemiHidden;
  final bool defUnhideWhenUsed;
  final bool defLockedState;
  final bool defQFormat;
  final int defUIPriority;

  /// The amount of styles that must be defined
  /// with the default metadata
  final int count;

  /// The styles that contains different metadata and them need to be marked
  final List<LatentException> exceptions;

  LatentStyles copyWith({
    bool? defSemiHidden,
    bool? defUnhideWhenUsed,
    bool? defLockedState,
    bool? defQFormat,
    int? defUIPriority,
    int? count,
    List<LatentException>? exceptions,
  }) {
    return LatentStyles(
      defSemiHidden: defSemiHidden ?? this.defSemiHidden,
      defUnhideWhenUsed: defUnhideWhenUsed ?? this.defUnhideWhenUsed,
      defUIPriority: defUIPriority ?? this.defUIPriority,
      defLockedState: defLockedState ?? this.defLockedState,
      defQFormat: defQFormat ?? this.defQFormat,
      count: count ?? this.count,
      exceptions: exceptions ?? this.exceptions,
    );
  }

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: XmlComponentAttributes(xmlAttributes: <String, String>{
        'w:defQFormat': defQFormat.toString(),
        'w:defUnhideWhenUsed': defUnhideWhenUsed.toString(),
        'w:defLockedState': defLockedState.toString(),
        'w:defSemiHidden': defSemiHidden.toString(),
        'w:uiPriority': defUIPriority.toString(),
        if (count > 0) 'w:count': count.toString(),
      }).buildXml(),
      children: <XmlNode>[
        ...exceptions.map(
          (
            LatentException el,
          ) =>
              el.buildXml(context),
        ),
      ],
      isSelfClosing: false,
    );
  }
}

class LatentException extends XmlComponentBase<void> {
  LatentException({
    required String styleName,
    required Map<String, Object> metadata,
  }) : super(
          value: null,
          xmlKey: 'w:lsdException',
          attrs: XmlComponentAttributes(
            xmlAttributes: <String, Object>{
              'w:name': styleName,
              ...metadata,
            },
          ),
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}
