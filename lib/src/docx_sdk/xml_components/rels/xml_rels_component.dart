import 'package:xml/xml.dart';

import '../../../../docx.dart';

//NOTE: take care during modifications of this component.
// For some reason, making updates for this one always breaks
// all document until you understand what is failing!
class XmlRelsComponent extends XmlComponentBase<List<RelationShip>> {
  XmlRelsComponent()
      : super(
          xmlKey: 'Relationships',
          attrs: XmlDocAttributes(
            relations: true,
          ),
          value: <RelationShip>[
            RelationShip(
              rId: 'rId1',
              type: namespaces['officeDocumentRelation']!,
              target: DocxPaths.documentFilePath,
              mode: null,
            ),
            RelationShip(
              rId: 'rId2',
              type: namespaces['extendedProperties']!,
              target: DocxPaths.appFilePath,
            ),
            RelationShip(
              rId: 'rId3',
              type: namespaces['corePropertiesRelation']!,
              target: DocxPaths.coreFilePath,
              mode: null,
            ),
          ],
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        ...value.map((RelationShip el) => el.toXml()),
      ],
    );
  }
}
