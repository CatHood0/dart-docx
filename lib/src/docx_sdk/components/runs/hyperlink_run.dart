import 'package:xml/xml.dart';

import '../../../core/extensions/style_to_from_node.dart';
import '../../../core/styles_builder/easy_styles.dart';
import '../../sdk.dart';

class HyperlinkRun extends RunBase<HyperlinkTextPart> {
  HyperlinkRun({
    required super.data,
    super.parent,
    this.style,
  });

  final Style? style;

  @override
  bool get isLink => true;

  @override
  String get link => data.hyperlink;

  @override
  bool get isEmptyData => data.text.isEmpty;

  @override
  HyperlinkRun get copy => HyperlinkRun(
        data: HyperlinkTextPart(
          hyperlink: data.hyperlink,
          text: data.text,
          styles: data.styles,
        ),
        parent: parent,
      );

  @override
  XmlElement buildXml({required DocxComponentContext context}) {
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
    Style hyperlinkStyle = EasyStyles.hyperlink;
    if (style != null && !style!.isInvalid) {
      //TODO: we need to create a logger to allow to user knows that its style
      // reference is not taking effect
      final Style? result =
          context.options.docStyles.getStyleById(id, variants: {
        // we can give to the user several variants of a link
        'hyperlink',
        'href',
        'link',
      });
      if (result != null && !result.isInvalid) {
        hyperlinkStyle = result;
      }
    }
    return <XmlElement>[
      if (!hyperlinkStyle.isInvalid) ...hyperlinkStyle.toRunStyleNodes(),
      ...xmlStyles,
    ];
  }

  @override
  String toPlainText() {
    return data.text;
  }

  @override
  String toString() {
    return 'HyperlinkRun(id: $id, data: $data)';
  }

  @override
  HyperlinkRun? visitElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    if (shouldGetElement(this)) return this;
    return null;
  }
}

class HyperlinkTextPart extends TextPart {
  HyperlinkTextPart({
    required super.text,
    required this.hyperlink,
    super.styles,
  }) : assert(linkDetectorMatcher.hasMatch(hyperlink),
            'The link: "$hyperlink" is not a valid like');
  final String hyperlink;

  @override
  String toString() {
    return 'Hyperlink(link: $hyperlink)';
  }
}
