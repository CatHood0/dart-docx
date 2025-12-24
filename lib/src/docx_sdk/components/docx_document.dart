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

  List<XmlNode> buildXml({required DocumentContext context}) {
    final List<XmlNode> content = <XmlNode>[];
    for (final DocxContent<dynamic> section in sections) {
      if (section is IgnorableMixin &&
          (section as IgnorableMixin).shouldIgnore()) {
        continue;
      }
      context.currentContentPart = section;
      content.addAll(section.buildXml(context: context));
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
