import 'package:xml/xml.dart';

import '../../../../docx.dart';

class XmlDocumentRelsComponent extends XmlComponentBase<List<RelationShip>> {
  XmlDocumentRelsComponent({
    required List<RelationShip> relations,
  }) : super(
          attrs: XmlComponentAttributes(xmlAttributes: <String, Object>{
            'xmlns': namespaces['relationship']!,
          }),
          xmlKey: 'Relationships',
          value: relations,
        );

  static List<RelationShip> defaultDocumentFileRelations([
    bool applyCustomTheme = false,
    DocumentRelsCounterStore? store,
  ]) {
    return <RelationShip>[
      //NOTE: to avoid conflicts
      // with users relations, we prefer
      // just having random ids
      RelationShip(
        rId: 'rId${store?.getNextId() ?? nanoid(7)}',
        type: namespaces['styles']!,
        target: 'styles.xml',
        mode: null,
      ),
      RelationShip(
        rId: 'rId${store?.getNextId() ?? nanoid(7)}',
        type: namespaces['settings']!,
        target: 'settings.xml',
      ),
      RelationShip(
        rId: 'rId${store?.getNextId() ?? nanoid(7)}',
        type: namespaces['fontTable']!,
        target: 'fontTable.xml',
      ),
      RelationShip(
        rId: 'rId${store?.getNextId() ?? nanoid(7)}',
        type: namespaces['webSettings']!,
        target: 'webSettings.xml',
      ),
      RelationShip(
        rId: 'rId${store?.getNextId() ?? nanoid(7)}',
        type: namespaces['numbering']!,
        target: 'numbering.xml',
      ),
      if (applyCustomTheme)
        RelationShip(
          rId: 'rId${store?.getNextId() ?? nanoid(7)}',
          type: namespaces['themes']!,
          target: 'theme/theme1.xml',
        ),
    ];
  }

  String? get theme {
    final RelationShip rel = value.firstWhere((RelationShip element) {
      return element.target == 'theme1.xml';
    }, orElse: RelationShip.invalid);
    if (rel.rId.isEmpty || rel.target.isEmpty || rel.type.isEmpty) {
      return null;
    }
    return rel.rId;
  }

  @override
  XmlElement buildXml(DocumentContext context) {
    final Map<String, dynamic> rels = <String, dynamic>{};
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        ...value.map((RelationShip re) {
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
