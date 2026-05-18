import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import 'entities/note_properties.dart';

class _XmlBaseNotePrComponent extends XmlComponentBase<NotePropertiesOptions> {
  _XmlBaseNotePrComponent({
    required super.xmlKey,
    required NotePropertiesOptions options,
  }) : super(
          value: options,
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      children: [
        XmlEmptyElementComponent(
          xmlKey: 'w:pos',
          value: value.position.name,
        ).buildXml(context),
        XmlEmptyElementComponent(
          xmlKey: 'w:numFmt',
          value: value.numberFormat.name,
        ).buildXml(context),
        XmlEmptyElementComponent(
          xmlKey: 'w:numStart',
          value: value.numberStart,
        ).buildXml(context),
        XmlEmptyElementComponent(
          xmlKey: 'w:numRestart',
          value: value.numberRestart.name,
        ).buildXml(context),
        // Standard footnote/endnote elements for separators/continuations
        XmlEmptyElementComponent(
          xmlKey: xmlKey.replaceFirst('Pr', ''),
          attrName: 'w:id',
          value: -1,
        ).buildXml(context),
        XmlEmptyElementComponent(
          xmlKey: xmlKey.replaceFirst('Pr', ''),
          attrName: 'w:id',
          value: 0,
        ).buildXml(context),
        if (value.fieldAugmentation == true)
          XmlEmptyElementComponent(
            xmlKey: 'w:fldAugment',
            value: null,
          ).buildXml(context),
        // w:layout typically for footnotes
        if (value.layout != null && xmlKey == 'w:footnotePr')
          XmlEmptyElementComponent(
            xmlKey: 'w:layout',
            value: value.layout!.name,
          ).buildXml(context),
        // Add any additional specified footnote/endnote IDs
        ...value.additionalNoteIds.map((id) {
          return XmlEmptyElementComponent(
            xmlKey: xmlKey.replaceFirst('Pr', ''),
            attrName: 'w:id',
            value: id,
          ).buildXml(context);
        }),
      ],
      isSelfClosing: false,
    );
  }
}

/// Represents the `<w:footnotePr>` element in WordML settings.
class XmlFootnotePrComponent extends _XmlBaseNotePrComponent {
  XmlFootnotePrComponent({
    required super.options,
  }) : super(xmlKey: 'w:footnotePr');
}

/// Represents the `<w:endnotePr>` element in WordML settings.
class XmlEndnotePrComponent extends _XmlBaseNotePrComponent {
  XmlEndnotePrComponent({
    required super.options,
  }) : super(xmlKey: 'w:endnotePr');
}
