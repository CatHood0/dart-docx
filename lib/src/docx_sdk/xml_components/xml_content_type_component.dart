import 'package:xml/xml.dart';

import '../../../docx.dart';
import '../../core/extensions/skippable_iterations_ext.dart';

class XmlContentTypeComponent
    extends XmlComponentBase<Iterable<XmlComponentBase>> {
  XmlContentTypeComponent({
    required bool applyCustomTheme,
    required Iterable<String> extensions,
    this.overrides,
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
            ...extensions.skippableMap<XmlDefaultElementTypeComponent>((
              String ext,
            ) {
              if (ext == 'odttf') return null;
              return XmlDefaultElementTypeComponent(
                type: ext,
                contentType: mimetypeFromExt(ext),
              );
            }),
            if (overrides != null) ...overrides,
            XmlOverrideElementTypeComponent(
              part: '/${DocxPaths.documentFilePath}',
              contentType: namespaces['documentType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/${DocxPaths.documentXmlRelsFilePath}',
              contentType: namespaces['relationsXml']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/${DocxPaths.relsFilePath}',
              contentType: namespaces['relationsXml']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/${DocxPaths.appFilePath}',
              contentType: namespaces['appType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/${DocxPaths.coreFilePath}',
              contentType: namespaces['coreType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/${DocxPaths.stylesXmlFilePath}',
              contentType: namespaces['stylesType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/${DocxPaths.numberingXmlFilePath}',
              contentType: namespaces['numberingType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/${DocxPaths.fontTableXmlFilePath}',
              contentType: namespaces['fontTableType']!,
            ),
            //NOTE: any new theme need to be added
            // in content type
            if (applyCustomTheme)
              XmlOverrideElementTypeComponent(
                part: '/${DocxPaths.theme1XmlFilePath}',
                contentType: namespaces['themeType']!,
              ),
            XmlOverrideElementTypeComponent(
              part: '/${DocxPaths.settingsXmlFilePath}',
              contentType: namespaces['settingsType']!,
            ),
            XmlOverrideElementTypeComponent(
              part: '/${DocxPaths.webSettingsXmlFilePath}',
              contentType: namespaces['webSettingsType']!,
            ),
          ],
        );

  @override
  String get name => 'ContentType';

  @override
  String get path => DocxPaths.contentTypesPath;

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
  final Iterable<XmlOverrideElementTypeComponent>? overrides;

  static String mimetypeFromExt(String ext) =>
      mimetypes[ext.toLowerCase()] ?? 'application/octet-stream';

  @override
  XmlElement buildXml() {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        ...value.map<XmlElement>((
          e,
        ) =>
            e.buildXml()),
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
  XmlElement buildXml() {
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
  XmlElement buildXml() {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}
