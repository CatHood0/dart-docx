import 'package:archive/archive.dart';

import '../../../docx.dart';
import '../utils/values.dart';
import '../xml_components/fonts/xml_font_table_component.dart';
import '../xml_components/rels/xml_document_rels_component.dart';

/// Manages font definitions and embedded font files for a Docx document.
///
/// This store is responsible for:
/// - Discovering fonts if `dynamicFontSearch` is enabled.
/// - Registering custom fonts to be embedded.
/// - Generating the `fontTable.xml` component.
/// - Generating the `fontTable.xml.rels` relationships for embedded fonts.
/// - Adding obfuscated font binary files to the DOCX archive.
class FontStore {
  FontStore();

  /// The file path for the font table XML within the DOCX archive.
  static String get filePath => fontTableXmlFilePath;

  /// The file path for the font table relationships XML.
  static String get relsFilePath => fontTableXmlRelsFilePath;

  /// Stores all [FontProperties] that will be included in `fontTable.xml`.
  final List<FontProperties> _documentFonts = [];

  final Set<String> _availableFamilies = <String>{};

  bool get hasFonts => _documentFonts.isNotEmpty;

  /// Stores the binary data of embedded fonts, keyed by their `fontKey` (GUID).
  final Map<String, FontBinaryData> _embeddedFontBinaries =
      <String, FontBinaryData>{};

  /// Stores relationships for embedded fonts, keyed by rId.
  final Map<String, RelationShip> _fontRelationships = <String, RelationShip>{};

  /// Collects extensions of embedded font files (e.g., 'odttf').
  final Set<String> extensions = <String>{};

  /// Stores all the families registered in this instance
  Set<String> get availableFamilies => Set<String>.from(_availableFamilies);

  Map<String, RelationShip> get fontRelations => Map.from(_fontRelationships);

  /// Current highest rId used for font relationships.
  int _lastFontRId = 0;

  /// Resets the font store to its initial state.
  void reset() {
    _documentFonts.clear();
    _embeddedFontBinaries.clear();
    _fontRelationships.clear();
    _availableFamilies.isNotEmpty;
    extensions.clear();
    _lastFontRId = 0;
  }

  /// Discovers fonts from the document content (if `dynamicFontSearch` is true)
  /// or adds predefined fonts from [DocumentOptions].
  ///
  /// [document] The [DocxDocument] to scan for fonts (if dynamic search).
  /// [options] The [DocumentOptions] which might contain predefined fonts.
  void discoverFonts(
    DocxDocument document, {
    bool dynamicSearchEnabled = false,
  }) {
    // Add predefined fonts from options
    if (document.options.fonts.isNotEmpty) {
      for (final FontProperties fp in document.options.fonts) {
        addFont(fp);
      }
    }

    // Discover fonts from content if dynamic search is enabled
    if (dynamicSearchEnabled) {
      _discoverFontsFromDocumentContent(document);
    }

    // Ensure default fonts like Calibri/Times New Roman are always present if not overridden
    if (_availableFamilies.contains('Calibri')) {
      addFont(const FontProperties(
        name: 'Calibri',
        family: 'swiss',
        charset: CharacterSet.ansi,
        pitch: 'variable',
      ));
    }
    if (_availableFamilies.contains('Times New Roman')) {
      addFont(const FontProperties(
        name: 'Times New Roman',
        family: 'roman',
        charset: CharacterSet.ansi,
        pitch: 'variable',
      ));
    }
  }

  /// Scans the document's content (paragraphs, runs, styles)
  /// to find referenced font names and adds them as basic [FontProperties].
  void _discoverFontsFromDocumentContent(
    DocxDocument document,
  ) {
    final Set<String> discoveredFontNames = {};

    for (final DocxContent parent in document.sections) {
      final List<DocxContent> elementsWithFonts = parent.visitAllElement(
            (
              DocxContent el,
            ) =>
                el is TextRun || el is Paragraph,
            visitChildrenIfNeeded: true,
          ) ??
          <DocxContent>[];

      for (final DocxContent content in elementsWithFonts) {
        final List<Style> styles = [];
        if (content is TextRun) {
          styles.addAll(content.data.styles.whereType<Style>());
        } else if (content is Paragraph) {
          styles.addAll(content.styles);
        }

        for (final Style style in styles) {
          final Style deepStyle =
              style.getDeepStyleRelation(document.options.docStyles);
          final StyleConfigurator? rPr =
              deepStyle.getConfiguratorOrNull('w:rPr', fullName: true);
          if (rPr != null) {
            final StyleConfigurator? rFonts =
                rPr.getConfiguratorOrNull('w:rFonts', fullName: true);
            if (rFonts != null) {
              final String? fontFamily =
                  rFonts.attributes?['w:ascii'] as String?;
              if (fontFamily != null && fontFamily.isNotEmpty) {
                discoveredFontNames.add(fontFamily);
              }
            }
          }
        }
      }
    }

    for (final Style style in document.options.docStyles.styles) {
      final Style deepStyle = !style.isReference
          ? style
          : style.getDeepStyleRelation(document.options.docStyles);
      final StyleConfigurator? rPr =
          deepStyle.getConfiguratorOrNull('w:rPr', fullName: true);
      if (rPr != null) {
        final StyleConfigurator? rFonts =
            rPr.getConfiguratorOrNull('w:rFonts', fullName: true);
        if (rFonts != null) {
          final String? fontFamily = rFonts.attributes?['w:ascii'] as String?;
          //TODO: we need to implement logger to notify about issues like these
          if (fontFamily != null && fontFamily.isNotEmpty) {
            discoveredFontNames.add(fontFamily);
          }
        }
      }
    }

    // Add discovered font names as basic FontProperties
    for (final String fontName in discoveredFontNames) {
      // ignores all the fonts that are already registered
      if (_availableFamilies.contains(fontName)) {
        continue;
      }
      addFont(FontProperties(
        name: fontName,
        family: 'auto',
        pitch: 'variable',
        charset: CharacterSet.ansi,
      ));
    }
  }

  /// Adds a [FontProperties] to the store.
  /// If the font has [FontBinaryData], it also registers the binary for embedding
  /// and creates a relationship entry in `fontTable.xml.rels`.
  void addFont(FontProperties font) {
    // Ensure that any font with binary data is fully added,
    // and its embedRId is correctly set during addFont.
    if (_availableFamilies.contains(font.name)) {
      throw '${font.name} is already registered. Please, '
          'ensure that you are passing '
          'non duplicated font names';
    }
    final int existingIndex = _documentFonts.indexWhere(
      (
        FontProperties f,
      ) =>
          f.name == font.name,
    );

    FontProperties finalFont = font;
    if (font.fontBinaryData != null) {
      final FontBinaryData binary = font.fontBinaryData!;
      // Ensure fontKey is set, generate if null
      final String actualFontKey = binary.fontKey;
      _embeddedFontBinaries[actualFontKey] = binary;

      _lastFontRId++;
      final String currentRId = 'rId$_lastFontRId';
      final String obfuscatedFileName = '${font.name.replaceAll(
        ' ',
        '',
      )}.${binary.extension}.odttf';

      // Create relationship for fontTable.xml.rels
      _fontRelationships[currentRId] = RelationShip(
        rId: currentRId,
        // Relationship type for embedded fonts
        type: namespaces['font']!,
        // Target path for obfuscated font file
        target: 'fonts/$obfuscatedFileName',
        mode: 'Internal',
      );

      // Create EmbeddedFontRefOptions to be included in the FontProperties
      final EmbeddedFontRefOptions embeddedRef = EmbeddedFontRefOptions(
        rId: currentRId,
        fontKey: actualFontKey,
        //TODO: should we allow arbitrary true?
        subsetted: true,
      );

      // Create a new FontProperties instance with
      // updated embedRegular (or other variant)
      finalFont = font.copyWithEmbeddedRef(
        embedRegular: embeddedRef,
      );

      // Add the obfuscated font extension to the set of known extensions
      extensions.add('odttf');
      if (existingIndex != -1) {
        _documentFonts[existingIndex] = finalFont;
        return;
      }
    }
    _documentFonts.add(finalFont);
  }

  /// Builds the [XmlFontTableComponent] for the `fontTable.xml` part.
  XmlComponentBase buildFontTableXmlComponent(
    DocumentContext context,
  ) {
    return XmlFontTableComponent(
      fonts: _documentFonts,
    );
  }

  /// Builds rels for `fontTable.xml.rels` part.
  /// This contains relationships for embedded fonts.
  XmlComponentBase buildFontTableRelsXmlDocument(
    DocumentContext context,
  ) {
    return XmlDocumentRelsComponent(
      relations: _fontRelationships.values.toList(),
    );
  }

  /// Adds all embedded font binary files to the provided [Archive].
  ///
  /// These files are assumed to be already obfuscated and are added as `.odttf` files.
  /// [archive] The `Archive` instance to which font files will be added.
  Stream<void> addEmbeddedFontFilesToArchive(Archive archive) async* {
    for (final FontProperties font in _documentFonts) {
      if (font.fontBinaryData != null) {
        final FontBinaryData binary = font.fontBinaryData!;
        final String obfuscatedFileName = '${font.name.replaceAll(
          ' ',
          '',
        )}.${binary.extension}.odttf';

        archive.add(
          ArchiveFile.bytes(
            'word/fonts/$obfuscatedFileName',
            binary.bytes,
          ),
        );
        yield null;
      }
    }
  }

  String generateObfuscationKey() {
    return generateFontGuid();
  }
}
