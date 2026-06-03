import 'package:xml/xml.dart';
import '../../../../docx.dart';

class XmlAppComponent extends XmlComponentBase<EditorMetadata> {
  XmlAppComponent({
    required EditorMetadata metadata,
    required this.docOps,
  }) : super(
          xmlKey: 'Properties',
          value: metadata,
        );

  final DocumentOptions docOps; 

  @override
  String get name => 'App';

  @override
  String get path => DocxPaths.appFilePath;

  @override
  XmlElement buildXml() {
    return XmlElement.tag(
      xmlKey,
      attributes: XmlComponentAttributes(xmlAttributes: <String, Object>{
        'xmlns': namespaces['extendedProperties']!,
        'xmlns:vt': namespaces['vt']!,
      }).buildXml(),
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
          children: <XmlNode>[XmlText(docOps.company)],
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
            XmlDefaults.text('${docOps.sharedDoc}'),
          ],
          isSelfClosing: false,
        ),
        //TODO: need to be true when incremental changes and partial compilation
        // will working
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
