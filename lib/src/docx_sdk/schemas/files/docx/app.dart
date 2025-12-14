import 'package:xml/xml.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../../../core/namespaces.dart';
import '../../../sdk.dart';

/// Correspond to docProps/app.xml
XmlDocument generateAppXml(DocumentOptions options) => XmlDocument(
      <XmlNode>[
        XmlDefaults.declaration,
        XmlElement.tag(
          'Properties',
          attributes: <XmlAttribute>[
            XmlAttribute('xmlns'.toName(), namespaces['o']!),
            XmlAttribute('xmlns:vt'.toName(), namespaces['vt']!),
          ],
          children: <XmlNode>[
            XmlElement.tag(
              'Application',
              children: [
                XmlDefaults.text(options.title),
              ],
              isSelfClosing: false,
            ),
            //TODO: we need to get metadata
            XmlElement.tag(
              'Pages',
              children: [XmlDefaults.text('0')],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'Words',
              children: [XmlDefaults.text('0')],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'Characters',
              children: [XmlDefaults.text('0')],
              isSelfClosing: false,
            ),
          ],
          isSelfClosing: false,
        ),
      ],
    );
