import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import 'entities/compat_settings.dart';

/// Represents the `<w:compat>` element in WordML settings.
class XmlCompatComponent extends XmlComponentBase<List<CompatSetting>> {
  XmlCompatComponent({required List<CompatSetting> compatSettings})
      : super(
          xmlKey: 'w:compat',
          value: compatSettings,
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      children: value.map((s) => s.buildXml()).toList(),
    );
  }
}
