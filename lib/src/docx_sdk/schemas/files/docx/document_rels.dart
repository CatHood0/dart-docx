import 'package:xml/xml.dart';

import '../../../sdk.dart';

XmlDocument generateDocumentXmlRels(List<RelationShip> relations) {
  final List<XmlElement> fixedRelations = [
  ];

  final Iterable<XmlElement> dynamicRelations = relations.map<XmlElement>(
    (RelationShip re) => re.toXml(),
  );

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
