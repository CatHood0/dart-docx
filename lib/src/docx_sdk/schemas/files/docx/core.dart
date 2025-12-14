import 'package:xml/xml.dart';
import '../../../../../docx_transformer.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/extensions/string_ext.dart';
import '../../../../core/namespaces.dart';
import '../../../sdk.dart';

/// Correspond to file docProps/core.xml
XmlDocument generateCoreXml(DocumentOptions options) => XmlDocument(
      [
        XmlDefaults.declaration,
        XmlElement.tag(
          'cp:coreProperties',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'xmlns:cp'.toName(),
              namespaces['coreProperties']!,
            ),
            XmlAttribute('xmlns:dc'.toName(), namespaces['dc']!),
            XmlAttribute(
              'xmlns:dcterms'.toName(),
              namespaces['dcterms']!,
            ),
            XmlAttribute(
              'xmlns:dcmitype'.toName(),
              namespaces['dcmitype']!,
            ),
            XmlAttribute(
              'xmlns:xsi'.toName(),
              namespaces['xsi']!,
            ),
          ],
          children: <XmlNode>[
            XmlElement.tag(
              'dc:title',
              children: [
                if (options.title.isNotEmpty)
                  XmlDefaults.text(options.title),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dc:subject',
              children: [
                if (options.subject.isNotEmpty)
                  XmlDefaults.text(options.subject),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dc:creator',
              children: [
                if (options.owner.isNotEmpty)
                  XmlDefaults.text(options.owner)
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dc:keywords',
              children: [
                if (options.keywords.isNotEmpty)
                  XmlDefaults.text(options.keywords),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dc:description',
              children: [
                if (options.description.isNotEmpty)
                  XmlDefaults.text(options.description),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dc:lastModifiedBy',
              children: [
                if (options.lastModifiedBy.isNotEmpty)
                  XmlDefaults.text(options.lastModifiedBy),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'cp:revision',
              children: [
                XmlDefaults.text('${options.revisions.nonNegative}'),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dcterms:created',
              attributes: [XmlAttribute('xsi:type'.toName(), 'dcterms:W3CDTF')],
              children: [
                XmlDefaults.text(
                    options.createdAt.toUtc().toIso8601String()),
              ],
              isSelfClosing: false,
            ),
            XmlElement.tag(
              'dcterms:modified',
              attributes: [XmlAttribute('xsi:type'.toName(), 'dcterms:W3CDTF')],
              children: [
                XmlDefaults.text(
                    options.modifiedAt.toUtc().toIso8601String()),
              ],
              isSelfClosing: false,
            ),
          ],
          isSelfClosing: false,
        ),
      ],
    );
