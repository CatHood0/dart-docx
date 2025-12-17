import 'package:xml/xml.dart';

import '../../../../docx.dart';

class XmlRelsComponent extends XmlComponentBase<List<RelationShip>> {
  XmlRelsComponent()
      : super(
          xmlKey: 'Relationships',
          value: [
            RelationShip(
              rId: 'rId1',
              type: namespaces['officeDocumentRelation']!,
              target: documentFilePath,
              mode: null,
            ),
            RelationShip(
              rId: 'rId2',
              type: namespaces['extendedProperties']!,
              target: appFilePath,
            ),
            RelationShip(
              rId: 'rId3',
              type: namespaces['corePropertiesRelation']!,
              target: coreFilePath,
              mode: null,
            ),
          ],
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      children: [
        ...value.map((el) => el.toXml()),
      ],
    );
  }
}
