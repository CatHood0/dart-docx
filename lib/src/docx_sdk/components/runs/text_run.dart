import 'package:xml/xml.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/extensions/style_to_from_node.dart';
import '../../sdk.dart';

class TextRun extends RunBase<TextPart> {
  TextRun({
    required super.data,
    super.parent,
    super.id,
  });

  TextRun.fromString({
    required String text,
    List<Object> styles = const <Object>[],
    super.parent,
    super.id,
  }) : super(
          data: TextPart(
            text: text,
            styles: List<Object>.from(styles),
          ),
        );

  TextRun.empty({
    super.parent,
    super.id,
  }) : super(
          data: TextPart(
            text: '',
            styles: <Object>[],
          ),
        );

  static final RegExp _consecutiveWhitespacesRegExp = RegExp(r'\s{2,}');

  @override
  bool get isEmptyData => data.text.replaceAll('\n', '').isEmpty;

  bool get requirePreserve => _consecutiveWhitespacesRegExp.hasMatch(
        data.text,
      );

  @override
  TextRun get copy => TextRun(
        id: id,
        data: TextPart(
          text: data.text,
          styles: data.styles,
        ),
        parent: parent,
      );

  @override
  bool shouldIgnore() {
    return false;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return [
      super.runParent(
        runProperties: buildXmlStyle(context: context),
        nodes: <XmlNode>[
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
      ),
    ];
  }

  @override
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    final List<Object> styles = <Object>[...data.styles];
    if (styles.any(
      (Object e) => e is TextRunAttribution && e.scope != Scope.portion,
    )) {
      throw Exception('The styles passed in $runtimeType are invalid. '
          'All of them must implement "Scope.portion" value');
    }
    final List<XmlElement> xmlStyles = <XmlElement>[];
    for (final Object style in styles) {
      if (style is Style && style.isInvalid) continue;
      if (style is TextRunAttribution) {
        final el = style.toXml();
        if (el != null) xmlStyles.add(el);
      } else {
        final List<XmlElement> elements = (style as Style).forRunStyle(
          // only not reference styles have configurators
          useConfigurators: !style.isReference,
          shouldShowStyleRef: style.isReference,
        );
        xmlStyles.addAll(elements);
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
