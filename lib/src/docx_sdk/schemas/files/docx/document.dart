import 'package:xml/xml.dart';

import '../../../sdk.dart';

XmlDocument generateDocumentXml(
  DocumentContext context, {
  required Iterable<XmlElement> contents,
}) =>
    XmlDocument(
      <XmlNode>[
        XmlDefaults.declaration,
        XmlElement.tag(
          'w:document',
          attributes: XmlDefaults.documentAttributes,
          children: [
            XmlElement.tag(
              'w:body',
              children: [
                ...contents,
                XmlDefaults.documentSectPr(properties: context.options),
              ],
            ),
          ],
          isSelfClosing: false,
        ),
      ],
    );
