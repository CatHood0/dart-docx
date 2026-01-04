import 'package:archive/archive.dart';

import '../../../docx.dart';
import '../utils/values.dart';
import '../xml_components/fonts/xml_font_table_component.dart';
import '../xml_components/rels/xml_document_rels_component.dart';

//TODO: add listeners to events
//TODO add log capabilities
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

  bool get hasFonts => _fontsByName.isNotEmpty;

  /// Stores all [FontProperties] that will be included in `fontTable.xml`.
  final Map<String, FontProperties> _fontsByName = {};

  /// Stores all [FontProperties] count changes from last time using name as key.
  ///
  /// Used by compiler to know if we will need to recompile the `fontTable.xml`
  final Map<String, int> _fontsChanges = {};

  /// Stores the binary data of embedded fonts, keyed by their `fontKey` (GUID).
  final Map<String, FontBinaryData> _embeddedBinariesByKey =
      <String, FontBinaryData>{};

  /// Stores relationships for embedded fonts, keyed by rId.
  final Map<String, RelationShip> _relationshipsByRId =
      <String, RelationShip>{};

  /// Collects extensions of embedded font files (e.g., 'odttf').
  final Set<String> extensions = <String>{'odttf'};

  /// Stores all the families registered in this instance
  Map<String, RelationShip> get fontRelations => Map.from(_relationshipsByRId);

  List<FontProperties> get fonts => List.from(_fontsByName.values);

  /// Current highest rId used for font relationships.
  int _lastFontRId = 0;

  void resetChanges() {
    _fontsChanges.clear();
  }

  /// Resets the font store to its initial state.
  void reset() {
    _fontsByName.clear();
    _embeddedBinariesByKey.clear();
    _relationshipsByRId.clear();
    extensions
      ..clear()
      ..add('odttf');
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

    _checkForDefaultFontsExistence();
  }

  /// Scans the document's content (paragraphs, runs, styles)
  /// to find referenced font names and adds them as basic [FontProperties].
  void _discoverFontsFromDocumentContent(
    DocxDocument document,
  ) {
    final Set<String> discoveredFontNames = {};

    //TODO: use parent methods of DocumentRoot
    for (final DocxTreeNode parent in document.root.data) {
      final List<DocxTreeNode> elementsWithFonts = parent.visitAllElement(
            (
              DocxTreeNode el,
            ) =>
                el is TextRun || el is Paragraph,
            visitChildrenIfNeeded: true,
          ) ??
          <DocxTreeNode>[];

      for (final DocxTreeNode content in elementsWithFonts) {
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
      // // ignores all the fonts that are already registered
      // if (_availableFamilies.contains(fontName)) {
      //   continue;
      // }
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
    FontProperties resolved = font;

    if (font.fontBinaryData != null) {
      resolved = _registerEmbeddedFont(font);
    }

    // increment changes
    if (_fontsByName.containsKey(resolved.name)) {
      _fontsChanges[resolved.name] =
          (_fontsByName[resolved.name] as int? ?? 0) + 1;
    }
    _fontsByName[resolved.name] = resolved;
  }

  /// Builds the [XmlFontTableComponent] for the `fontTable.xml` part.
  XmlComponentBase buildFontTableXmlComponent(DocumentContext context) =>
      XmlFontTableComponent(fonts: fonts);

  /// Builds rels for `fontTable.xml.rels` part.
  /// This contains relationships for embedded fonts.
  XmlComponentBase buildFontTableRelsXmlDocument(DocumentContext context) =>
      XmlDocumentRelsComponent(relations: _relationshipsByRId.values.toList());

  /// Adds all embedded font binary files to the provided [Archive].
  ///
  /// These files are assumed to be already obfuscated and are added as `.odttf` files.
  /// [archive] The `Archive` instance to which font files will be added.
  Stream<void> addEmbeddedFontFilesToArchive(Archive archive) async* {
    for (final FontProperties font in _fontsByName.values) {
      if (font.fontBinaryData != null) {
        final FontBinaryData binary = font.fontBinaryData!;
        final String obfuscatedFileName =
            _obfuscatedFileName(font.name, binary.extension);

        archive.add(
          ArchiveFile.bytes(
            '${DocxPaths.fontStorageFilePath}/$obfuscatedFileName',
            binary.bytes,
          ),
        );
        yield null;
      }
    }
  }

  FontProperties _registerEmbeddedFont(FontProperties font) {
    final FontBinaryData binary = font.fontBinaryData!;

    _embeddedBinariesByKey[binary.fontKey] = binary;

    final String rId = _nextFontRId();
    final String fileName = _obfuscatedFileName(font.name, binary.extension);
    extensions.add(binary.extension);

    _relationshipsByRId[rId] = RelationShip(
      rId: rId,
      type: namespaces['font']!,
      target: 'fonts/$fileName',
      mode: 'Internal',
    );

    return font.copyWithEmbeddedRef(
      embedRegular: EmbeddedFontRefOptions(
        rId: rId,
        fontKey: binary.fontKey,
        subsetted: true,
      ),
    );
  }

  String _obfuscatedFileName(String name, String extension) {
    return '${name.replaceAll(
      ' ',
      '',
    )}.$extension.odttf';
  }

  String _nextFontRId() {
    _lastFontRId++;
    return 'rId$_lastFontRId';
  }

  void _checkForDefaultFontsExistence() {
    // Ensure default fonts like Calibri/Times New Roman are always present if not overridden
    if (_fontsByName['Calibri'] == null) {
      addFont(const FontProperties(
        name: 'Calibri',
        family: 'swiss',
        charset: CharacterSet.ansi,
        pitch: 'variable',
      ));
    }
    if (_fontsByName['Times New Roman'] == null) {
      addFont(const FontProperties(
        name: 'Times New Roman',
        family: 'roman',
        charset: CharacterSet.ansi,
        pitch: 'variable',
      ));
    }
  }

  String generateObfuscationKey() {
    return generateFontGuid();
  }
}
