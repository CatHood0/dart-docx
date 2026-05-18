import 'package:xml/xml.dart';

import '../../../../docx.dart';

class XmlThemeComponent extends XmlComponentBase<ThemeOptions> {
  XmlThemeComponent({
    required this.options,
  }) : super(
          xmlKey: 'a:theme',
          attrs: XmlDocAttributes(
            a: true,
            extra: <String, String>{
              'name': options.name,
            },
          ),
          value: options,
        );

  final ThemeOptions options;

  @override
  String get name => 'Theme';

  @override
  String get path => DocxPaths.theme1XmlFilePath;

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        options.themeElements.buildXml(),
        XmlElement.tag('a:objectDefaults'),
        XmlElement.tag('a:extraClrSchemeLst'),
      ],
      isSelfClosing: false,
    );
  }
}
