import 'package:xml/xml.dart' as xml;
import '../../../../docx.dart';
import '../../styles/latent_styles.dart';

/// Manages document styles and default formatting properties.
///
/// This class serves as the central repository for all styles used in a document,
/// including paragraph styles, character (run) styles, and their relationships.
/// All styles defined in this class will be written to the `styles.xml` file
/// within the DOCX package.
///
/// Styles can be created programmatically, loaded from XML, or accessed through
/// helper methods for styling relationships and inheritance.
///
/// Example usage:
/// ```dart
/// // Create a new stylesheet with base styles
/// final stylesheet = DocumentStylesSheet.base(
///   options: EditorOptions(fontFamily: 'Arial'),
/// );
///
/// // Add custom styles
/// final updatedStyles = stylesheet.withNewStyles([myCustomStyle]);
///
/// // Find a style by ID
/// final headingStyle = stylesheet.getStyleById('Heading1');
/// ```
class DocumentStylesSheet {
  DocumentStylesSheet({
    required this.styles,
    required this.latentStyles,
    List<Style> docDefaultParagraphStyles = const <Style>[],
    List<Style> docDefaultRunStyles = const <Style>[],
  })  : _docDefaultParagraphStyles = <Style>[...docDefaultParagraphStyles],
        _docDefaultRunStyles = <Style>[...docDefaultRunStyles];

  /// Factory constructor to create a [DocumentStylesSheet] from XML.
  ///
  /// Parses an existing `styles.xml` document to reconstruct the stylesheet.
  /// This is useful when working with existing DOCX documents or templates.
  factory DocumentStylesSheet.fromXmlStyles(xml.XmlDocument styleDoc) {
    return XmlToDocxObjects.xmlToDocumentStylesSheet(styleDoc);
  }

  /// Creates an empty stylesheet with no styles defined.
  ///
  /// Useful as a starting point for creating custom documents from scratch.
  DocumentStylesSheet.empty()
      : styles = <Style>[],
        latentStyles = LatentStyles.base(),
        _docDefaultParagraphStyles = <Style>[],
        _docDefaultRunStyles = <Style>[];

  /// Creates a stylesheet with standard document styles pre-configured.
  ///
  /// Includes default styles from [EasyStyles.standardDocumentStyles] and
  /// configures default run styling based on the provided [EditorOptions].
  ///
  /// Parameters:
  /// - [options]: Editor configuration including font family, size, and language.
  ///   If not provided, defaults to Times New Roman 12pt with US English.
  DocumentStylesSheet.base({EditorOptions? options})
      : styles = <Style>[...EasyStyles.standardDocumentStyles],
        latentStyles = LatentStyles.base(),
        _docDefaultParagraphStyles = <Style>[],
        _docDefaultRunStyles = <Style>[
          StyleBuilder.singularC()
              .fontFamily(options?.fontFamily ?? 'Times New Roman')
              .fontSize(
                (options?.fontSize ?? 10.ptToHalfPoints()).toDouble(),
                options?.complexScriptFontSize.toDouble(),
              )
              .lang(options?.language ??
                  DocxLanguage(language: LanguageCodes.englishUS))
              .build(),
        ];

  // Latent styles refer to style definitions known to an application which have not been included in the current document.
  //
  // The latentStyles elements provides a mechanism for storing information regarding certain behaviors of such styles
  // without storing the actual formatting properties of the styles.
  //
  // Such behaviors include such things as how many latent styles must be initialized to their defaults when the 
  // document is opened, whether latent styles should be locked so that instances of the styles cannot be created, 
  // what the uiPriority should be for latent styles, etc.
  LatentStyles latentStyles;

  /// Default paragraph styles defined in the document.
  ///
  /// These styles are automatically applied to paragraphs unless overridden.
  final List<Style> _docDefaultParagraphStyles;

  /// Default character (run) styles defined in the document.
  ///
  /// These styles are automatically applied to text runs unless overridden.
  final List<Style> _docDefaultRunStyles;

  /// Gets a copy of the default paragraph styles.
  List<Style> get docDefaultParagraphStyles =>
      List<Style>.from(_docDefaultParagraphStyles);

  /// Gets a copy of the default run styles.
  List<Style> get docDefaultRunStyles => List<Style>.from(_docDefaultRunStyles);

  /// Global styles defined in the document.
  ///
  /// This includes all paragraph and character styles that can be referenced
  /// throughout the document via their style IDs.
  final List<Style> styles;

  /// Returns deep relationships for a given style.
  ///
  /// Traverses style relationships recursively, returning all styles that
  /// are linked through the `link` property. Useful for understanding
  /// style inheritance chains.
  Iterable<Iterable<Style>> getDeepRelationships(Style style) {
    return styles.map((Style e) {
      //NOTE: i think that this condition is wrong, need to check again
      if ((e.getConfigurator('link').value as String? ?? '').isEmpty) {
        return <Style>[e];
      }
      return <Style>[e, ...?getRelationships(e)];
    });
  }

  /// Gets the parent style of a given style.
  Style getParentOf(Style style, {bool deep = false}) {
    final Style parent = styles.firstWhere(
      (Style s) => s.styleId == style.basedOn?.value,
      orElse: Style.invalid,
    );
    if (!parent.isInvalid) {
      final String? basedOn = parent.basedOn?.value as String?;
      if (basedOn != null && basedOn.isNotEmpty && deep) {
        return getParentOf(parent);
      }
      return parent;
    }
    return style;
  }

  /// Returns all styles related to the given style.
  ///
  /// Finds styles that reference the given style's ID through their `link`
  /// property. This represents one-way relationships between styles.
  Iterable<Style>? getRelationships(Style style) {
    final String? link = style.link?.value as String?;
    if (link == null || link.isEmpty) return null;
    return styles.where(
      (Style e) => e.id == link || e.styleId == link,
    );
  }

  /// Finds a style by its ID or variant IDs.
  Style? getStyleById(String id, {Set<String> variants = const <String>{}}) {
    return Style.styleOrNull(styles.firstWhere(
      (Style e) =>
          e.id == id ||
          e.styleId == id ||
          variants.contains(e.id) ||
          variants.contains(e.styleId),
      orElse: Style.invalid,
    ));
  }

  /// Finds a style by its display name.
  ///
  /// Searches through all style names defined in the document.
  Style? getStyleByName(String name) {
    return styles.firstWhere(
      (Style e) => e.styleNames().any(
            (StyleConfigurator el) => el.value == name,
          ),
    );
  }

  /// Creates a copy of the stylesheet with optional modifications.
  DocumentStylesSheet copyWith({
    List<Style>? styles,
    List<Style>? docDefaultParagraphStyles,
    List<Style>? docDefaultRunStyles,
    LatentStyles? latentStyles,
  }) {
    return DocumentStylesSheet(
      styles: styles ?? this.styles,
      latentStyles: latentStyles ?? this.latentStyles,
      docDefaultParagraphStyles:
          docDefaultParagraphStyles ?? _docDefaultParagraphStyles,
      docDefaultRunStyles: docDefaultRunStyles ?? _docDefaultRunStyles,
    );
  }

  /// Creates a new stylesheet with additional styles appended.
  DocumentStylesSheet withNewStyles(
    List<Style> styles, {
    List<Style>? docDefaultParagraphStyles,
    List<Style>? docDefaultRunStyles,
  }) {
    return copyWith(
      styles: <Style>[
        ...this.styles,
        ...styles,
      ],
      docDefaultParagraphStyles: docDefaultParagraphStyles,
      docDefaultRunStyles: docDefaultRunStyles,
    );
  }
}
