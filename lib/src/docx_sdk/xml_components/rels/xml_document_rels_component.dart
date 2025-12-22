import 'package:xml/xml.dart';

import '../../../../docx.dart';

class XmlDocumentRelsComponent extends XmlComponentBase<List<RelationShip>> {
  XmlDocumentRelsComponent({
    required List<RelationShip> relations,
  }) : super(
          attrs: XmlComponentAttributes(xmlAttributes: {
            'xmlns': namespaces['relationship']!,
          }),
          xmlKey: 'Relationships',
          value: relations,
        );

  static List<RelationShip> defaultDocumentFileRelations(
      [bool applyCustomTheme = false]) {
    return <RelationShip>[
      //NOTE: to avoid conflicts
      // with users relations, we prefer
      // just having random ids
      RelationShip(
        rId: 'rId${nanoid(7)}',
        type: namespaces['styles']!,
        target: 'styles.xml',
        mode: null,
      ),
      RelationShip(
        rId: 'rId${nanoid(7)}',
        type: namespaces['settingsType']!,
        target: 'settings.xml',
      ),
      RelationShip(
        rId: 'rId${nanoid(7)}',
        type: namespaces['fontTableType']!,
        target: 'fontTable.xml',
      ),
      RelationShip(
        rId: 'rId${nanoid(7)}',
        type: namespaces['webSettingsType']!,
        target: 'webSettings.xml',
      ),
      RelationShip(
        rId: 'rId${nanoid(7)}',
        type: namespaces['numberingType']!,
        target: 'numbering.xml',
      ),
      if (applyCustomTheme)
        RelationShip(
          rId: 'rId${nanoid(7)}',
          type: namespaces['themeType']!,
          target: 'theme1.xml',
        ),
    ];
  }

  String? get theme {
    final rel = value.firstWhere((element) {
      return element.target == 'theme1.xml';
    }, orElse: RelationShip.invalid);
    if (rel.rId.isEmpty || rel.target.isEmpty || rel.type.isEmpty) {
      return null;
    }
    return rel.rId;
  }

  @override
  XmlElement buildXml(DocumentContext context) {
    final Map<String, dynamic> rels = {};
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: [
        ...value.map((re) {
          // we cant allow duplcates
          if (rels[re.rId] != null) {
            throw Exception(
              'Duplicated rId '
              'founded at element $re',
            );
          }
          rels[re.rId] = 1;
          return re.toXml();
        }),
      ],
    );
  }
}
