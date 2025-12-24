import 'package:xml/xml.dart' as xml;
import '../../../../docx.dart';
import '../../utils/language_codes.dart';

/// Represents the common styles used by the document
///
/// Note: **all the styles into this class will be writted into [styles.xml]**
class DocumentStylesSheet {
  DocumentStylesSheet({
    required this.styles,
    List<Style> docDefaultParagraphStyles = const [],
    List<Style> docDefaultRunStyles = const [],
  })  : _docDefaultParagraphStyles = [...docDefaultParagraphStyles],
        _docDefaultRunStyles = [...docDefaultRunStyles];

  factory DocumentStylesSheet.fromXmlStyles(xml.XmlDocument styleDoc) {
    return XmlToDocxObjects.xmlToDocumentStylesSheet(styleDoc);
  }

  DocumentStylesSheet.empty()
      : styles = [],
        _docDefaultParagraphStyles = [],
        _docDefaultRunStyles = [];

  DocumentStylesSheet.base({EditorOptions? options})
      : styles = [...EasyStyles.standardDocumentStyles],
        _docDefaultParagraphStyles = [
          StyleBuilder.singularP()
              .spacing(after: 120, line: 240, rule: LineRule.atLeast)
              .build(),
        ],
        _docDefaultRunStyles = [
          StyleBuilder.singularC()
              .fontFamily(options?.fontFamily ?? 'Times New Roman')
              .fontSize(
                (options?.fontSize ?? 12).toDouble(),
                options?.complexScriptFontSize.toDouble(),
              )
              .lang(options?.language ??
                  DocxLanguage(language: LanguageCodes.englishUS))
              .spacing(after: 120, line: 240, rule: LineRule.atLeast)
              .build(),
        ];

  //TODO: probably we will just create a new class for these elements
  /// There are the default values for the paragraphs styles used in styles.xml
  final List<Style> _docDefaultParagraphStyles;

  //TODO: probably we will just create a new class for these elements
  /// There are the default values for the inline text of the paragraphs used in styles.xml
  final List<Style> _docDefaultRunStyles;

  List<Style> get docDefaultParagraphStyles =>
      List<Style>.from(_docDefaultParagraphStyles);

  List<Style> get docDefaultRunStyles => List<Style>.from(_docDefaultRunStyles);

  /// These are the global styles
  final List<Style> styles;

  /// Return a deep collection with the styles that contains the id that relatedWith param has
  ///
  /// If a internal style contains a link to another Style, will search to found a style that does
  /// not contain a relation
  Iterable<Iterable<Style>> getDeepRelationships(Style style) {
    return styles.map((Style e) {
      //NOTE: i think that this condition is wrong, need to check again
      if ((e.getConfigurator('link').value as String? ?? '').isEmpty) {
        return <Style>[e];
      }
      return <Style>[e, ...?getRelationships(e)];
    });
  }

  Style getParentOf(Style style, {bool deep = false}) {
    final Style parent = styles.firstWhere(
      (Style s) => s.styleId == style.basedOn?.value,
      orElse: Style.invalid,
    );
    if (parent.id != 'invalid') {
      final String? basedOn = parent.basedOn?.value as String?;
      if (basedOn != null && basedOn.isNotEmpty && deep) {
        return getParentOf(parent);
      }
      return parent;
    }
    return style;
  }

  /// Return all the styles that contains the id that relatedWith param has
  Iterable<Style>? getRelationships(Style style) {
    final String? link = style.link?.value as String?;
    if (link == null || link.isEmpty) return null;
    return styles.where(
      (Style e) => e.id == link || e.styleId == link,
    );
  }

  Style? getStyleById(String id, {Set<String> variants = const <String>{}}) {
    if (id.isEmpty) return null;
    return styles.firstWhere(
      (Style e) =>
          e.id == id ||
          e.styleId == id ||
          variants.contains(e.id) ||
          variants.contains(e.styleId),
      orElse: Style.invalid,
    );
  }

  Style? getStyleByName(String name) {
    if (name.isEmpty) return null;
    return styles.firstWhere(
      (Style e) => e.styleName == name,
    );
  }

  DocumentStylesSheet copyWith({
    List<Style>? styles,
    List<Style>? docDefaultParagraphStyles,
    List<Style>? docDefaultRunStyles,
  }) {
    return DocumentStylesSheet(
      styles: styles ?? this.styles,
      docDefaultParagraphStyles:
          docDefaultParagraphStyles ?? _docDefaultParagraphStyles,
      docDefaultRunStyles: docDefaultRunStyles ?? _docDefaultRunStyles,
    );
  }

  DocumentStylesSheet withNewStyles(
    List<Style> styles, {
    List<Style>? docDefaultParagraphStyles,
    List<Style>? docDefaultRunStyles,
  }) {
    return copyWith(
      styles: [
        ...this.styles,
        ...styles,
      ],
      docDefaultParagraphStyles: docDefaultParagraphStyles,
      docDefaultRunStyles: docDefaultRunStyles,
    );
  }
}
