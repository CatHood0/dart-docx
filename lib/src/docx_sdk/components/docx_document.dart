import 'package:xml/xml.dart';

import '../mixins/ignorable_mixin.dart';
import '../sdk.dart';

class DocxDocument {
  DocxDocument({
    required this.sections,
    required this.options,
  });

  final Iterable<DocxContent> sections;

  //NOTE: probably we will move these to DocxDocument class
  final DocumentOptions options;

  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlElement> content = <XmlElement>[];
    for (final DocxContent<dynamic> section in sections) {
      if (section is IgnorableMixin &&
          (section as IgnorableMixin).shouldIgnore()) {
        continue;
      }
      context.currentContentPart = section;
      content.add(section.buildXml(context: context) as XmlElement);
    }
    return content;
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
