import 'package:xml/xml.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/extensions/style_to_from_node.dart';
import '../../../util/line_tokenizer.dart';
import '../../sdk.dart';

class TextRun extends RunBase<TextPart> {
  TextRun({
    required super.data,
    super.parent,
  });

  static final RegExp _consecutiveWhitespacesRegExp = RegExp(r'\s{2,}');

  @override
  bool get isEmptyData => data.text.replaceAll('\n', '').isEmpty;

  bool get requirePreserve => _consecutiveWhitespacesRegExp.hasMatch(
        data.text,
      );

  @override
  TextRun get copy => TextRun(
        data: TextPart(
          text: data.text,
          styles: data.styles,
        ),
        parent: parent,
      );

  @override
  XmlElement buildXml({required DocumentContext context}) {
    final List<String> lines = tokenizeWithNewLines(data.text);
    if (lines.length > 1) {
      return super.runParent(
        runProperties: buildXmlStyle(context: context),
        nodes: <XmlNode>[
          ...lines.map((line) {
            if (line == '\n') {
              return XmlElement('w:br'.toName());
            }
            return XmlDefaults.textRunWithText(
              line,
              attributes: <XmlAttribute>[
                if (requirePreserve)
                  XmlAttribute('xml:space'.toName(), 'preserve'),
              ],
            );
          }),
        ],
      );
    }
    return super.runParent(
      runProperties: buildXmlStyle(context: context),
      nodes: <XmlNode>[
        if (data.text.isNotEmpty && data.text != '\n')
          XmlElement.tag(
            xmlTextNode,
            attributes: [
              if (requirePreserve)
                XmlAttribute(
                  'xml:space'.toName(),
                  'preserve',
                ),
            ],
            children: [
              XmlText(data.text),
            ],
            isSelfClosing: false,
          )
      ],
    );
  }

  @override
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    final List<Object> styles = <Object>[...data.styles];
    if (styles.any(
        (Object e) => e is TextRunAttribution && e.scope != Scope.portion)) {
      throw Exception('The styles passed in $runtimeType are invalid. '
          'All of them must implement "Scope.portion" value');
    }
    final List<XmlElement> xmlStyles = <XmlElement>[];
    for (final Object style in styles) {
      if (style is Style && style.isInvalid) continue;
      final XmlElement? styleXml = style is TextRunAttribution
          ? style.toXml()
          : (style as Style)
              .forRunStyle(
                // only not reference styles have configurators
                useConfigurators: !style.isReference,
                shouldShowStyleRef: style.isReference,
              )
              .single;
      if (styleXml != null) xmlStyles.add(styleXml);
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
    this.styles = const <Object>[],
  })  : assert(
          !text.contains('\n'),
          'text cannot '
          'contains \\n in it. Please, divide your '
          'text in multiple paragraph to avoid '
          'this error',
        ),
        assert(styles.every(
          (
            Object element,
          ) =>
              element is Style || element is TextRunAttribution,
        ));

  final String text;

  /// All the related styles with this run
  ///
  /// Only two objects are accepted:
  ///  * Style
  ///  * TextRunAttribution
  final List<Object> styles;

  @override
  String toString() {
    return 'TextPart(data: $text, styles: $styles)';
  }
}
