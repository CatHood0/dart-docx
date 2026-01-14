import 'package:xml/xml.dart';

import '../../../../docx.dart';

class XmlCoreComponent extends XmlComponentBase<List<XmlComponentBase>> {
  XmlCoreComponent({required DocumentOptions options})
      : super(
          xmlKey: 'cp:Properties',
          attrs: XmlComponentAttributes(xmlAttributes: {
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
              xmlKey: 'dc:keywords',
              value: options.keywords,
            ),
            XmlTextElementComponent<String>(
              xmlKey: 'dc:description',
              value: options.description,
            ),
            XmlTextElementComponent<String>(
              xmlKey: 'dc:lastModifiedBy',
              value: options.lastModifiedBy,
            ),
            XmlTextElementComponent<int>(
              xmlKey: 'dc:revision',
              value: options.revisions,
            ),
            XmlTextElementComponent<String>(
              xmlKey: 'dcterms:modified',
              attrs: const XmlComponentAttributes(
                //TODO: i dont get it this, we need to
                // make a search
                xmlAttributes: {
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
