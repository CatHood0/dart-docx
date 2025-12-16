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
          value: <RelationShip>[
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
            ...relations,
          ],
        );

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
