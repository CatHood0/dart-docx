import 'package:xml/xml.dart';
import '../../../../../docx.dart';

/// Represents the `<w:clrSchemeMapping>` element in WordML settings.
class XmlColorSchemeMappingComponent extends XmlComponentBase<void> {
  XmlColorSchemeMappingComponent({
    required Map<String, String> mapping,
  }) : super(
          xmlKey: 'w:clrSchemeMapping',
          value: null,
          attrs: XmlComponentAttributes(
            xmlAttributes: Map.fromEntries(
              mapping.entries.map(
                (n) => MapEntry(
                  'w:${n.key}',
                  n.value,
                ),
              ),
            ),
          ),
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}
