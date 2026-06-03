import 'package:xml/xml.dart' as xml;
import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../../core/extensions/skippable_iterations_ext.dart';

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
//TODO: we need to think about changing these elements to be
// a HashMap instead of a list
class DocumentStyles {
  DocumentStyles({
    required this.styles,
    required this.latentStyles,
    Map<String, Style> docDefaultParagraphStyles = const <String, Style>{},
    Map<String, Style> docDefaultRunStyles = const <String, Style>{},
  })  : _docDefaultParagraphStyles = <String, Style>{
          ...docDefaultParagraphStyles
        },
        _docDefaultRunStyles = <String, Style>{...docDefaultRunStyles};

  /// Factory constructor to create a [DocumentStyles] from XML.
  ///
  /// Parses an existing `styles.xml` document to reconstruct the stylesheet.
  /// This is useful when working with existing DOCX documents or templates.
  factory DocumentStyles.fromXmlStyles(xml.XmlDocument styleDoc) {
    return XmlToDocxObjects.xmlToDocumentStylesSheet(styleDoc);
  }

  /// Creates an empty stylesheet with no styles defined.
  ///
  /// Useful as a starting point for creating custom documents from scratch.
  DocumentStyles.empty()
      : styles = <String, Style>{},
        latentStyles = LatentStyles.base(),
        _docDefaultParagraphStyles = <String, Style>{},
        _docDefaultRunStyles = <String, Style>{};

  /// Creates a stylesheet with standard document styles pre-configured.
  ///
  /// Includes default styles from [EasyStyles.standardDocumentStyles] and
  /// configures default run styling based on the provided [EditorOptions].
  ///
  /// Parameters:
  /// - [options]: Editor configuration including font family, size, and language.
  ///   If not provided, defaults to Times New Roman 12pt with US English.
  DocumentStyles.base({EditorOptions? options, Map<String, Style>? styles})
      : styles = <String, Style>{
          ...(styles ?? StyleBuilder.standardDocumentStyles)
        },
        latentStyles = LatentStyles.base(),
        _docDefaultParagraphStyles = <String, Style>{},
        _docDefaultRunStyles = <String, Style>{
          'defaultRun': StyleBuilder.character('defaultRun')
              .fontFamily(options?.fontFamily ?? kDefaultFontFamily)
              .fontSize(
                (options?.fontSize ?? Point(10)),
                options?.complexScriptFontSize,
              )
              .lang(options?.language ??
                  DocxLanguage(language: LanguageCodes.englishUS))
              .build(),
        };

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
  final Map<String, Style> _docDefaultParagraphStyles;

  /// Default character (run) styles defined in the document.
  ///
  /// These styles are automatically applied to text runs unless overridden.
  final Map<String, Style> _docDefaultRunStyles;

  /// Gets a copy of the default paragraph styles.
  Map<String, Style> get docDefaultParagraphStyles =>
      Map<String, Style>.from(_docDefaultParagraphStyles);

  /// Gets a copy of the default run styles.
  Map<String, Style> get docDefaultRunStyles =>
      Map<String, Style>.from(_docDefaultRunStyles);

  /// Global styles defined in the document.
  ///
  /// This includes all paragraph and character styles that can be referenced
  /// throughout the document via their style IDs.
  final Map<String, Style> styles;

  // {name: styleId}
  final Map<String, String> indexedNames = {};
  final Map<String, String> indexedIds = {};
  // {id: styleId}
  // NOTE: style.id and styles.styleId can be the elements in the list
  //{link: keys}
  final Map<String, List<String>> indexedLinks = {};
  bool _preventIndex = false;

  void preventIndex() => _preventIndex = true;

  bool add(Style style) {
    return false;
  }

  bool addParagraphDocDefaults(Style style) {
    return false;
  }

  bool addRunDocDefaults(Style style) {
    return false;
  }

  bool removeStyle(String style) {
    return false;
  }

  bool removeStyleParagraphDocDefaults(String style) {
    return false;
  }

  bool removeStyleRunDocDefaults(String style) {
    return false;
  }

  /// Index all the elements and cache them to make search more faster during compilations
  void index() {
    if (_preventIndex) {
      _preventIndex = false;
      return;
    }
    CompilerLogger.root.debug('Starting indexing of styles');
    styles.forEach(
      (String key, Style e) {
        final String? link = e.link?.value?.castOrNull<String?>();

        if (link == null) return;

        if (indexedLinks[link] != null) {
          CompilerLogger.root.debug(
            'Index existing link: $link '
            'with the keys: ${<String>[...?indexedLinks[link], key]}',
          );
          indexedLinks[link]!.add(key);
          return;
        }

        CompilerLogger.root.debug('Index for link: $link to the key: $key');
        indexedLinks.addAll({
          link: <String>[key],
        });
      },
    );
    indexedIds.addAll(styles.map(
      (String key, Style e) {
        CompilerLogger.root.debug('Index for ids: ${e.id} to the key: $key');
        return MapEntry(
          e.id,
          key,
        );
      },
    ));
    indexedNames.addAll(styles.map(
      (String key, Style e) {
        final String name = e.styleNames().first.value!.cast<String>();
        CompilerLogger.root.debug('Index for names: $name to the key: $key');
        return MapEntry(
          name,
          key,
        );
      },
    ));
    CompilerLogger.root.debug(
      'End indexes with '
      '${indexedLinks.length} links indexed, '
      '${indexedIds.length} ids indexed '
      'and ${indexedNames.length} names indexed',
    );
  }

  /// Returns deep relationships for a given style.
  ///
  /// Traverses style relationships recursively, returning all styles that
  /// are linked through the `link` property. Useful for understanding
  /// style inheritance chains.
  Iterable<Iterable<Style>> resolveLinks(Style style) {
    return styles.mapToList((String key, Style e) {
      //NOTE: i think that this condition is wrong, need to check again
      if ((e.link?.value as String? ?? '').isEmpty) {
        return <Style>[e];
      }
      return <Style>[e, ...?getAllLinkMatches(e)].reversed;
    });
  }

  /// Gets the parent style of a given style.
  Style getOriginalBasedStyle(Style style, {bool deep = false}) {
    final Style parent = styles[style.basedOn ?? ''] ?? Style.invalid();
    if (!parent.isInvalid) {
      final String? basedOn = parent.basedOn?.value as String?;
      if (basedOn != null && basedOn.isNotEmpty && deep) {
        return getOriginalBasedStyle(parent);
      }
      return parent;
    }
    return style;
  }

  /// Returns all styles related to the given style.
  ///
  /// Finds styles that reference the given style's ID through their `link`
  /// property. This represents one-way relationships between styles.
  Iterable<Style>? getAllLinkMatches(Style style) {
    final String? link = style.link?.value as String?;
    if (link == null || link.isEmpty) return null;
    if (indexedLinks.isNotEmpty && indexedLinks[link] != null) {
      final List<String> keys = indexedLinks[link]!;
      return keys.map(
        (String e) => styles[e]!,
      );
    }
    return styles.values.where(
      (Style e) => e.id == link || e.styleId == link,
    );
  }

  /// Finds a style by its ID or variant IDs.
  Style? getStyleById(String id, {Set<String> variants = const <String>{}}) {
    return styles[indexedIds[id]] ??
        Style.styleOrNull(
          styles[id] ?? Style.invalid(),
        );
  }

  /// Finds a style by its display name.
  ///
  /// Searches through all style names defined in the document.
  Style? getStyleByName(String name) {
    return styles[indexedNames[name]] ??
        styles.values.firstWhere(
          (Style e) => e.styleNames().any(
                (StyleConfigurator el) => el.value == name,
              ),
        );
  }

  /// Creates a copy of the stylesheet with optional modifications.
  DocumentStyles copyWith({
    Map<String, Style>? styles,
    Map<String, Style>? docDefaultParagraphStyles,
    Map<String, Style>? docDefaultRunStyles,
    LatentStyles? latentStyles,
  }) {
    return DocumentStyles(
      styles: styles ?? this.styles,
      latentStyles: latentStyles ?? this.latentStyles,
      docDefaultParagraphStyles:
          docDefaultParagraphStyles ?? _docDefaultParagraphStyles,
      docDefaultRunStyles: docDefaultRunStyles ?? _docDefaultRunStyles,
    );
  }

  /// Creates a new stylesheet with additional styles appended.
  DocumentStyles withNewStyles(
    List<Style> styles, {
    Map<String, Style>? docDefaultParagraphStyles,
    Map<String, Style>? docDefaultRunStyles,
  }) {
    return copyWith(
      styles: <String, Style>{
        ...this.styles,
        ...styles.toMap(
          (e) => e.styleId,
        ),
      },
      docDefaultParagraphStyles: docDefaultParagraphStyles,
      docDefaultRunStyles: docDefaultRunStyles,
    );
  }
}
