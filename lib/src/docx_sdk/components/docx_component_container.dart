import 'package:xml/xml.dart';

import '../sdk.dart';

class DocxComponentContainer {
  DocxComponentContainer({
    required this.contents,
  });

  final Iterable<ComponentContainer<dynamic>> contents;

  String toPlainText() {
    final StringBuffer buffer = StringBuffer();
    for (final Paragraph pr in contents.whereType<Paragraph>()) {
      for (final PrintableMixin content
          in pr.data.whereType<PrintableMixin>()) {
        buffer.write(content.toPlainText());
      }
    }
    return '$buffer';
  }

  XmlDocument toXml({required DocxComponentContext context}) {
    return XmlDocument(
      <XmlNode>[
        XmlDefaults.declaration,
        XmlElement.tag(
          'w:document',
          attributes: XmlDefaults.documentAttributes,
          children: <XmlNode>[
            XmlElement.tag(
              'w:body',
              children: <XmlNode>[
                ...contents.map(
                  (ComponentContainer e) {
                    context.currentContentPart = e;
                    return e.buildXml(context: context);
                  },
                ),
                XmlDefaults.sectPr(properties: context.options),
              ],
            ),
          ],
          isSelfClosing: false,
        ),
      ],
    );
  }
}
