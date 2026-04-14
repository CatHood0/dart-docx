import 'package:xml/xml.dart';
import '../../../../docx.dart';

class XmlAppComponent extends XmlComponentBase<EditorMetadata> {
  XmlAppComponent({required EditorMetadata metadata})
      : super(
          xmlKey: 'Properties',
          attrs: XmlComponentAttributes(xmlAttributes: <String, Object>{
            'xmlns': namespaces['extendedProperties']!,
            'xmlns:vt': namespaces['vt']!,
          }),
          value: metadata,
        );

  @override
  String get name => 'App';

  @override
  String get path => DocxPaths.appFilePath;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        XmlElement.tag(
          'Pages',
          children: <XmlNode>[
            XmlDefaults.text('${value.pages}'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'Words',
          children: <XmlNode>[
            XmlDefaults.text('${value.words}'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'Characters',
          children: <XmlNode>[
            XmlDefaults.text('${value.characters}'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'Application',
          children: <XmlNode>[XmlText(value.application)],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'DocSecurity',
          children: <XmlNode>[
            XmlDefaults.text('${value.docSecurity}'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'Lines',
          children: <XmlNode>[
            XmlDefaults.text('${value.lines}'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'Paragraphs',
          children: <XmlNode>[
            XmlDefaults.text('${value.paragraphs}'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'ScaleCrop',
          children: <XmlNode>[XmlText('false')],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'Company',
          children: <XmlNode>[XmlText(context.options.company)],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'LinksUpToDate',
          children: <XmlNode>[
            XmlDefaults.text('${value.linksUpToDate}'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'CharactersWithSpaces',
          children: <XmlNode>[
            XmlDefaults.text('${value.charactersWithSpaces}'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'SharedDoc',
          children: <XmlNode>[
            XmlDefaults.text('${context.options.sharedDoc}'),
          ],
          isSelfClosing: false,
        ),
        XmlElement.tag(
          'HyperlinksChanged',
          children: <XmlNode>[
            XmlDefaults.text('${value.hyperlinksChanged}'),
          ],
          isSelfClosing: false,
        ),
        if (value.wordVersion.isNotEmpty)
          XmlElement.tag(
            'AppVersion',
            children: <XmlNode>[
              XmlDefaults.text(value.wordVersion),
            ],
            isSelfClosing: false,
          ),
      ],
    );
  }
}
