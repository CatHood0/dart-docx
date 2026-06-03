import 'package:xml/xml.dart';

import '../../../../docx.dart';
import 'xml_section_configuration_component.dart';

class XmlBodyComponent extends XmlComponentBase<DocxNode> {
  XmlBodyComponent({
    required DocxNode body,
    required this.options,
    this.themeId,
  }) : super(
          value: body,
          xmlKey: 'w:body',
        );

  final String? themeId;
  final DocumentOptions options;

  @override
  XmlElement buildXml() {
    return XmlElement.tag(
      xmlKey,
      children: <XmlNode>[
        ...value.buildXml(),
        XmlDocumentSectionSettingsComponent(
          options: options.layoutOptions,
          themeId: themeId,
        ).buildXml(),
      ],
    );
  }
}
