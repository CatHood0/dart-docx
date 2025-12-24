import 'package:xml/xml.dart' show XmlElement;

import '../../../../docx.dart';
import 'xml_section_configuration_component.dart';

class XmlBodyComponent extends XmlComponentBase<DocxDocument> {
  XmlBodyComponent({
    required DocxDocument document,
    this.themeId,
  }) : super(
          value: document,
          xmlKey: 'w:body',
        );
  final String? themeId;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      children: [
        ...value.buildXml(context: context),
        XmlDocumentSectionSettingsComponent(
          options: context.options,
          themeId: themeId,
        ).buildXml(context),
      ],
    );
  }
}
