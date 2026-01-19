import 'package:xml/xml.dart';

import '../../../../docx.dart';

// <xs:element name="coreProperties" type="CT_CoreProperties"/>

/* cSpell:disable */
// <xs:complexType name="CT_CoreProperties">
//   <xs:all>
//     <xs:element name="category" minOccurs="0" maxOccurs="1" type="xs:string"/>
//     <xs:element name="contentStatus" minOccurs="0" maxOccurs="1" type="xs:string"/>
//     <xs:element ref="dcterms:created" minOccurs="0" maxOccurs="1"/>
//     <xs:element ref="dc:creator" minOccurs="0" maxOccurs="1"/>
//     <xs:element ref="dc:description" minOccurs="0" maxOccurs="1"/>
//     <xs:element ref="dc:identifier" minOccurs="0" maxOccurs="1"/>
//     <xs:element name="keywords" minOccurs="0" maxOccurs="1" type="CT_Keywords"/>
//     <xs:element ref="dc:language" minOccurs="0" maxOccurs="1"/>
//     <xs:element name="lastModifiedBy" minOccurs="0" maxOccurs="1" type="xs:string"/>
//     <xs:element name="lastPrinted" minOccurs="0" maxOccurs="1" type="xs:dateTime"/>
//     <xs:element ref="dcterms:modified" minOccurs="0" maxOccurs="1"/>
//     <xs:element name="revision" minOccurs="0" maxOccurs="1" type="xs:string"/>
//     <xs:element ref="dc:subject" minOccurs="0" maxOccurs="1"/>
//     <xs:element ref="dc:title" minOccurs="0" maxOccurs="1"/>
//     <xs:element name="version" minOccurs="0" maxOccurs="1" type="xs:string"/>
//   </xs:all>
// </xs:complexType>
class XmlCoreComponent extends XmlComponentBase<List<XmlComponentBase>> {
  XmlCoreComponent({required DocumentOptions options})
      : super(
          xmlKey: 'cp:coreProperties',
          attrs: XmlComponentAttributes(xmlAttributes: <String, Object>{
            'xmlns:cp': namespaces['coreProperties']!,
            'xmlns:dc': namespaces['dc']!,
            'xmlns:dcterms': namespaces['dcterms']!,
            'xmlns:dcmitype': namespaces['dcmitype']!,
            'xmlns:xsi': namespaces['xsi']!,
          }),
          value: <XmlComponentBase<dynamic>>[
            XmlTextElementComponent<String>(
              xmlKey: 'dc:title',
              value: options.title,
            ),
            XmlTextElementComponent<String>(
              xmlKey: 'dc:subject',
              value: options.subject,
            ),
            XmlTextElementComponent<String>(
              xmlKey: 'dc:creator',
              value: options.creator,
            ),
            XmlTextElementComponent<String>(
              xmlKey: 'dc:description',
              value: options.description,
            ),
            if (options.keywords.isNotEmpty)
              XmlTextElementComponent<String>(
                xmlKey: 'cp:keywords',
                value: options.keywords,
              ),
            XmlTextElementComponent<String>(
              xmlKey: 'cp:lastModifiedBy',
              value: options.lastModifiedBy,
            ),
            XmlTextElementComponent<int>(
              xmlKey: 'cp:revision',
              value: options.revisions,
            ),
            XmlTextElementComponent<String>(
              xmlKey: 'dcterms:created',
              attrs: const XmlComponentAttributes(
                //TODO: i dont get it this, we need to
                // make a search
                xmlAttributes: <String, Object>{
                  'xsi:type': 'dcterms:W3CDTF',
                },
              ),
              value: DateTime.now()
                  .toIso8601String()
                  .replaceAll(RegExp(r'\..*'), 'Z'),
            ),
            XmlTextElementComponent<String>(
              xmlKey: 'dcterms:modified',
              attrs: const XmlComponentAttributes(
                //TODO: i dont get it this, we need to
                // make a search
                xmlAttributes: <String, Object>{
                  'xsi:type': 'dcterms:W3CDTF',
                },
              ),
              value: options.modifiedAt
                  .toIso8601String()
                  .replaceAll(RegExp(r'\..*'), 'Z'),
            ),
          ],
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: value.map(
        (
          XmlComponentBase<dynamic> el,
        ) =>
            el.buildXml(context),
      ),
    );
  }
}
