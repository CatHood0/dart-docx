import 'package:flutter_quill_delta_easy_parser/extensions/helpers/string_helper.dart';
import 'package:xml/xml.dart';
import '../../../core/extensions/string_ext.dart';
import '../../sdk.dart';

class TextRun extends RunBase<TextPart> {
  TextRun({
    required super.data,
    super.parent,
  });

  @override
  bool get isLink {
    return false;
  }

  @override
  bool get isEmptyData => data.text.replaceAll('\n', '').isEmpty;

  @override
  String get link {
    return '';
  }

  @override
  TextRun get copy => TextRun(
        data: TextPart(
          text: data.text,
          styles: data.styles,
        ),
        parent: parent,
      );

  @override
  XmlElement buildXml({required DocxComponentContext context}) {
    final List<String> lines = tokenizeWithNewLines(data.text);
    if (lines.length > 1) {
      return super.runParent(
        runProperties: buildXmlStyle(context: context),
        nodes: <XmlNode>[
          ...lines.map((line) {
            if (line == '\n') {
              return XmlElement('w:br'.toName());
            }
            return XmlDefaults.textRunWithText(line);
          }),
        ],
      );
    }
    return super.runParent(
      runProperties: buildXmlStyle(context: context),
      nodes: [
        if (data.text.isNotEmpty && data.text != '\n')
          XmlElement.tag(
            xmlTextNode,
            children: [
              XmlText(data.text),
            ],
            isSelfClosing: false,
          )
      ],
    );
  }

  @override
  List<XmlElement> buildXmlStyle({required DocxComponentContext context}) {
    final List<TextRunAttribution> styles = <TextRunAttribution>[...data.styles];
    if (styles.any((TextRunAttribution e) => e.scope != Scope.portion)) {
      throw Exception('The styles passed in $runtimeType are invalid. '
          'All of them must implement "Scope.portion" value');
    }
    final List<XmlElement> xmlStyles = <XmlElement>[];
    for (final TextRunAttribution style in styles) {
      final XmlElement? styleXml = style.toXml();
      if (styleXml != null) {
        xmlStyles.add(styleXml);
      }
    }
    return <XmlElement>[
      ...xmlStyles,
    ];
  }

  @override
  String toPlainText() {
    return data.text;
  }

  @override
  String toString() {
    return 'TextRun(id: $id, data: $data)';
  }
}

class TextPart {
  TextPart({
    required this.text,
    this.styles = const <TextRunAttribution>[],
  });

  final String text;
  final List<TextRunAttribution> styles;

  @override
  String toString() {
    return 'TextPart(data: $text, styles: $styles)';
  }
}
