import 'package:xml/xml.dart';

import '../../../../docx.dart';

/// A component representing the 'webSettings.xml' part of a DOCX document.
class XmlWebSettingsComponent extends XmlComponentBase<List<XmlComponentBase>> {
  XmlWebSettingsComponent({
    WebSettingsOptions options = const WebSettingsOptions(),
  }) : super(
          xmlKey: 'w:webSettings',
          attrs: XmlDocAttributes(
            w: true,
            r: true,
          ),
          value: <XmlComponentBase>[
            if (options.allowPng)
              XmlEmptyElementComponent(
                xmlKey: 'w:allowPNG',
                value: 1,
              ),
            if (options.targetScreenSize != null)
              XmlEmptyElementComponent(
                xmlKey: 'w:targetScreenSize',
                value: options.targetScreenSize!,
              ),
            if (options.optimizeForBrowser)
              XmlEmptyElementComponent(
                xmlKey: 'w:optimizeForBrowser',
                value: 1,
              ),
            // Default is true, so only add if explicitly false
            if (!options.relyOnVml)
              XmlEmptyElementComponent(
                xmlKey: 'w:relyOnVML',
                value: 0,
              ),
            if (options.doNotRelyOnCss)
              XmlEmptyElementComponent(
                xmlKey: 'w:doNotRelyOnCSS',
                value: 1,
              ),
            //NOTE: we will add more children based on WebSettingsOptions as they are implemented
          ],
        );

  @override
  String get name => 'WebSettings';

  @override
  String get path => DocxPaths.webSettingsXmlFilePath;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        ...value.map<XmlElement>((e) => e.buildXml(context)),
      ],
      isSelfClosing: value.isEmpty, // Self-closing if no children components
    );
  }
}
