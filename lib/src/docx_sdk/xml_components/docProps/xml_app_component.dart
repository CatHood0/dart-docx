import 'package:xml/xml.dart';
import '../../../../docx.dart';

class XmlAppComponent extends XmlComponentBase<void> {
  XmlAppComponent({
    required this.title,
    this.pages = 0,
    this.words = 0,
    this.characters = 0,
  }) : super(
          xmlKey: 'Properties',
          attrs: XmlComponentAttributes(xmlAttributes: <String, Object>{
            'xmlns': namespaces['o']!,
            'xmlns:vt': namespaces['vt']!,
          }),
          value: null,
        );
  final String title;
  final int pages, words, characters;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        XmlElement.tag(
          'Application',
          children: <XmlNode>[
            XmlDefaults.text(title),
          ],
          isSelfClosing: false,
        ),
        //TODO: we need to get metadata
        XmlElement.tag(
          'Pages',
          children: <XmlNode>[
            XmlDefaults.text('$pages'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'Words',
          children: <XmlNode>[
            XmlDefaults.text('$words'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'Characters',
          children: <XmlNode>[
            XmlDefaults.text('$characters'),
          ],
          isSelfClosing: false,
        ),
      ],
    );
  }
}
