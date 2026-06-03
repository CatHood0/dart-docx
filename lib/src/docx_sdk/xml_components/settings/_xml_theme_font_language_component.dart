import 'package:xml/xml.dart';
import '../../../../../docx.dart';

/// Represents the `<w:themeFontLang>` element in WordML settings.
//NOTE: i think that we should add cs and bidi
class XmlThemeFontLangComponent extends XmlComponentBase {
  XmlThemeFontLangComponent({
    required String val,
    required String eastAsia,
  }) : super(
          xmlKey: 'w:themeFontLang',
          value: null,
          attrs: XmlComponentAttributes(
            xmlAttributes: {
              'w:val': val,
              'w:eastAsia': eastAsia,
            },
          ),
        );

  @override
  XmlElement buildXml() {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}
