import 'package:xml/xml.dart' as xml;
import '../../sdk.dart';

/// Represents the common styles used by the document
///
/// Note: **all the styles into this class will be writted into [styles.xml]**
class DocumentStylesSheet {
  const DocumentStylesSheet({
    required this.styles,
    DocDefaultParagraphStyles? docDefaultParagraphStyles,
    DocDefaultInlineStyles? docDefaultInlineStyles,
  })  : _docDefaultParagraphStyles = docDefaultParagraphStyles,
        _docDefaultInlineStyles = docDefaultInlineStyles;

  factory DocumentStylesSheet.fromXmlStyles(
    xml.XmlDocument styleDoc, {
    DocDefaultParagraphStyles? docDefaultParagraphStyles,
    DocDefaultInlineStyles? docDefaultInlineStyles,
  }) {
    return DocumentStylesSheet(
      styles: convertXmlStylesToStyles(styleDoc),
      docDefaultParagraphStyles: docDefaultParagraphStyles,
      docDefaultInlineStyles: docDefaultInlineStyles,
    );
  }

  DocumentStylesSheet.base()
      : styles = DefaultDocumentStyles.kDefaultDocumentStyleSheet.styles,
        _docDefaultParagraphStyles = DocDefaultParagraphStyles.base(),
        _docDefaultInlineStyles = DocDefaultInlineStyles.base();

  /// There are the default values for the paragraphs styles used in styles.xml
  final DocDefaultParagraphStyles? _docDefaultParagraphStyles;

  /// There are the default values for the inline text of the paragraphs used in styles.xml
  final DocDefaultInlineStyles? _docDefaultInlineStyles;

  DocDefaultParagraphStyles get docDefaultParagraphStyles =>
      _docDefaultParagraphStyles ?? DocDefaultParagraphStyles.base();

  DocDefaultInlineStyles docDefaultInlineStyles() =>
      _docDefaultInlineStyles ?? DocDefaultInlineStyles.base();

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
}
