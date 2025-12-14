import 'package:xml/xml.dart';

import '../../../../core/namespaces.dart';
import '../../../sdk.dart';

XmlDocument generateDocumentXmlRels(RelationShipsBuilder? relationsBuilder) {
  final List<XmlElement> fixedRelations = [
    XmlDefaults.relation(
      rId: 'rId1',
      type: namespaces['styles']!,
      target: 'styles.xml',
      targetMode: null,
    ),
    XmlDefaults.relation(
      rId: 'rId2',
      type: namespaces['settingsType']!,
      target: 'settings.xml',
    ),
    XmlDefaults.relation(
      rId: 'rId3',
      type: namespaces['fontTableType']!,
      target: 'fontTable.xml',
    ),
    XmlDefaults.relation(
      rId: 'rId4',
      type: namespaces['webSettingsType']!,
      target: 'webSettings.xml',
    ),
    XmlDefaults.relation(
      rId: 'rId5',
      type: namespaces['numberingType']!,
      target: 'numbering.xml',
    ),
  ];

  final Iterable<XmlElement> dynamicRelations = relationsBuilder
          ?.call(fixedRelations.length + 1)
          .map<XmlElement>((RelationShip re) => re.toXml()) ??
      <XmlElement>[];

  return XmlDocument(
    [
      XmlDefaults.declaration,
      XmlDefaults.relationships(
        generateDefaultDocumentRelations: false,
        children: [
          ...fixedRelations,
          ...dynamicRelations,
        ],
      ),
    ],
  );
}
