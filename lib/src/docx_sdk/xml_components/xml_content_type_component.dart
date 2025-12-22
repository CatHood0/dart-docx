import 'package:xml/xml.dart';

import '../../../docx.dart';

class XmlContentTypeComponent
    extends XmlComponentBase<Iterable<XmlComponentBase>> {
  XmlContentTypeComponent({
    required bool applyCustomTheme,
    required Iterable<String> extensions,
  }) : super(
          xmlKey: 'Types',
          attrs: XmlComponentAttributes(
            xmlAttributes: <String, Object>{
              'xmlns': namespaces['contentTypes']!,
            },
          ),
          value: <XmlComponentBase<dynamic>>[
            XmlDefaultElementTypeComponent(
              type: 'rels',
              contentType: namespaces['relationsXml']!,
            ),
            XmlDefaultElementTypeComponent(
              type: 'xml',
              contentType: 'application/xml',
            ),
            ...extensions.map<XmlDefaultElementTypeComponent>((
              String ext,
            ) {
              return XmlDefaultElementTypeComponent(
                type: ext,
                contentType: _mimetypeFromExt(ext),
              );
            }),
            XmlOverrideElementTypeComponent(
              part: '/$documentXmlRelsFilePath',
              contentType: namespaces['relationsXml']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/$documentFilePath',
              contentType: namespaces['documentType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/$appFilePath',
              contentType: namespaces['appType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/$coreFilePath',
              contentType: namespaces['coreType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/$stylesXmlFilePath',
              contentType: namespaces['stylesType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/$numberingXmlFilePath',
              contentType: namespaces['numberingType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/$fontTableXmlFilePath',
              contentType: namespaces['fontTableType']!,
            ),
            //NOTE: any new theme need to be added
            // in content type
            if (applyCustomTheme)
              XmlOverrideElementTypeComponent(
                part: '/$theme1XmlFilePath',
                contentType: namespaces['themeType']!,
              ),
            XmlOverrideElementTypeComponent(
              part: '/$settingsXmlFilePath',
              contentType: namespaces['settingsType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/$webSettingsXmlFilePath',
              contentType: namespaces['webSettingsType']!,
            ),
          ],
        );

  static final Map<String, String> mimetypes =
      Map<String, String>.unmodifiable({
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'svg': 'image/svg+xml',
    'mp4': 'video/mp4',
    'txt': 'text/plain',
    'html': 'text/html',
    'pdf': 'application/pdf',
    'xlsx': namespaces['spreadsheet']!,
  });

  static String _mimetypeFromExt(String ext) =>
      mimetypes[ext.toLowerCase()] ?? 'application/octet-stream';

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        ...value.map<XmlElement>((
          e,
        ) =>
            e.buildXml(context)),
      ],
    );
  }
}

class XmlDefaultElementTypeComponent extends XmlComponentBase {
  XmlDefaultElementTypeComponent({
    required String type,
    required String contentType,
  }) : super(
          xmlKey: 'Default',
          attrs: XmlComponentAttributes(
            xmlAttributes: <String, Object>{
              'Extension': type,
              'ContentType': contentType,
            },
          ),
          value: null,
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

class XmlOverrideElementTypeComponent extends XmlComponentBase {
  XmlOverrideElementTypeComponent({
    required String part,
    required String contentType,
  }) : super(
          xmlKey: 'Override',
          attrs: XmlComponentAttributes(
            xmlAttributes: <String, Object>{
              'PartName': part,
              'ContentType': contentType,
            },
          ),
          value: null,
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
