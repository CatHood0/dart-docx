import 'package:xml/xml.dart';

import '../../../../core/namespaces.dart';
import '../../../sdk.dart';

/// Correspond to file _rels/.rels
XmlDocument generateRelsXml() => XmlDocument(
      [
        XmlDefaults.declaration,
        XmlDefaults.relationships(
          generateDefaultDocumentRelations: false,
          children: <XmlElement>[
            XmlDefaults.relation(
              rId: 'rId1',
              type: namespaces['officeDocumentRelation']!,
              target: documentFilePath,
              targetMode: null,
            ),
            XmlDefaults.relation(
              rId: 'rId2',
              type: namespaces['extendedProperties']!,
              target: appFilePath,
            ),
            XmlDefaults.relation(
              rId: 'rId3',
              type: namespaces['corePropertiesRelation']!,
              target: coreFilePath,
              targetMode: null,
            ),
          ],
        ),
      ],
    );
