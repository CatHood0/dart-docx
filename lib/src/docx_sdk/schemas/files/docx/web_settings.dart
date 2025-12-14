import 'package:xml/xml.dart';

import '../../../../core/extensions/string_ext.dart';
import '../../../../core/namespaces.dart';
import '../../../sdk.dart';

XmlDocument generateWebSettingsXML() => XmlDocument(
      [
        XmlDefaults.declaration,
        XmlElement.tag(
          'w:webSettings',
          attributes: <XmlAttribute>[
            XmlAttribute('xmlns:w'.toName(), namespaces['w']!),
            XmlAttribute('xmlns:r'.toName(), namespaces['r']!),
          ],
          children: <XmlNode>[],
          isSelfClosing: false,
        ),
      ],
    );
