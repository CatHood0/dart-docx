import 'package:xml/xml.dart';

import '../sdk.dart';

class DocxDocument {
  DocxDocument({
    required this.sections,
    required this.options,
  });

  final Iterable<ComponentContainer<dynamic>> sections;

  //NOTE: probably we will move these to DocxDocument class
  final DocumentOptions options;

  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      ...sections.map(
        (ComponentContainer e) {
          context.currentContentPart = e;
          return e.buildXml(context: context) as XmlElement;
        },
      ),
    ];
  }

  String toPlainText() {
    final StringBuffer buffer = StringBuffer();
    for (final Paragraph pr in sections.whereType<Paragraph>()) {
      for (final PrintableMixin content
          in pr.data.whereType<PrintableMixin>()) {
        buffer.write(content.toPlainText());
      }
    }
    return '$buffer';
  }
}
