import 'package:xml/xml.dart';

import '../../../../core/namespaces.dart';
import '../../../sdk.dart';

/// Correspond to file [Content_Types].xml
XmlDocument generateContentTypesXml({
  Iterable<String> knowedExtensions = const [],
}) {
  final Set<String> allExtensions = {...knowedExtensions}
    ..add('png')
    ..add('jpg')
    ..add('jpeg')
    ..add('gif');
  return XmlDocument(
    [
      XmlDefaults.declaration,
      XmlElement.tag(
        'Types',
        attributes: [
          XmlAttribute(
            XmlName.fromString('xmlns'),
            namespaces['contentTypes']!,
          ),
        ],
        children: [
          _defaultElement(
            'rels',
            namespaces['relationsXml']!,
          ),
          _defaultElement('xml', 'application/xml'),
          ...allExtensions.map<XmlNode>((String ext) {
            String contentType;
            switch (ext.toLowerCase()) {
              case 'png':
                contentType = 'image/png';
                break;
              case 'jpg':
              case 'jpeg':
                contentType = 'image/jpeg';
                break;
              case 'gif':
                contentType = 'image/gif';
                break;
              case 'svg':
                contentType = 'image/svg+xml';
                break;
              case 'mp4':
                contentType = 'video/mp4';
                break;
              default:
                contentType = 'application/octet-stream';
            }
            return _defaultElement(ext, contentType);
          }),
          _overrideElement(
            '/$documentXmlRelsFilePath',
            namespaces['relationsXml']!,
          ),
          _overrideElement(
            '/$documentFilePath',
            namespaces['documentType']!,
          ),
          _overrideElement(
            '/$stylesXmlFilePath',
            namespaces['stylesType']!,
          ),
          _overrideElement(
            '/$numberingXmlFilePath',
            namespaces['numberingType']!,
          ),
          _overrideElement(
            '/$fontTableXmlFilePath',
            namespaces['fontTableType']!,
          ),
          _overrideElement(
            '/$coreFilePath',
            namespaces['corePropsType']!,
          ),
          _overrideElement(
            '/$settingsXmlFilePath',
            namespaces['settingsType']!,
          ),
          _overrideElement(
            '/$webSettingsXmlFilePath',
            namespaces['webSettingsType']!,
          ),
        ],
        isSelfClosing: false,
      ),
    ],
  );
}

XmlElement _defaultElement(String type, String contentType) {
  return XmlElement(
    XmlName('Default'),
    [
      XmlAttribute(XmlName('Extension'), type),
      XmlAttribute(XmlName('ContentType'), contentType),
    ],
    [],
    true,
  );
}

XmlElement _overrideElement(String part, String contentType) {
  return XmlElement(
    XmlName('Override'),
    [
      XmlAttribute(XmlName('PartName'), part),
      XmlAttribute(XmlName('ContentType'), contentType),
    ],
    <XmlNode>[],
    true,
  );
}
