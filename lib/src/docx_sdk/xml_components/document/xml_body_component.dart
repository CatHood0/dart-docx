import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/xml.dart' show XmlElement;

import '../../../../docx.dart';
import 'xml_section_configuration_component.dart';

class XmlBodyComponent extends XmlComponentBase<DocxNode> {
  XmlBodyComponent({
    required DocxNode body,
    this.themeId,
  }) : super(
          value: body,
          xmlKey: 'w:body',
        );
  final String? themeId;

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      children: <XmlNode>[
        ...value.buildXml(context: context),
        XmlDocumentSectionSettingsComponent(
          options: context.options.layoutOptions,
          themeId: themeId,
        ).buildXml(context),
      ],
    );
  }
}
