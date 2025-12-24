import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

import '../../docx.dart';
import 'events/docx_event.dart';
import 'stores/font_store.dart';
import 'stores/numbering_store.dart';
import 'xml_components/docProps/xml_app_component.dart';
import 'xml_components/docProps/xml_core_component.dart';
import 'xml_components/document/xml_body_component.dart';
import 'xml_components/rels/xml_document_rels_component.dart';
import 'xml_components/rels/xml_rels_component.dart';
import 'xml_components/styles/xml_styles_component.dart';
import 'xml_components/themes/xml_theme_component.dart';
import 'xml_components/web_settings/xml_web_settings_component.dart';
import 'xml_components/xml_content_type_component.dart';

/// [DocxCompiler] is responsible for compiling a [DocxDocument] object
/// into a .docx file (a ZIP archive containing XML and media files).
/// It orchestrates the generation of various XML parts of the document,
/// manages relationships between them, and includes embedded media.
class DocxCompiler {
  DocxCompiler();

  late final StreamController<DocxEvent> _eventController =
      StreamController<DocxEvent>.broadcast();

  /// Determines if the fonts will be registing also using the content
  /// of the document to build an efficient [fontTable] file
  ///
  /// If not, set to false, and use [fonts] properties from
  /// [DocumentOptions] to skip this step. Will throw Exception
  /// if [dynamicFontSearch] is false and [fonts] is not setted
  bool dynamicFontSearch = true;

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  bool setNormalStyleToNotStyledParagraphs = true;

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  Style defaultNormalStyle = Style.reference('Normal');

  Stream<DocxEvent> get eventStream => _eventController.stream;
  void _emit(DocxEvent event) => _eventController.add(event);

  /// Manages all media-related operations for the current compilation process.
  late final MediaStore mediaStore = MediaStore();

  /// Manages all numbering definitions and instances for the current compilation process.
  late final NumberingStore numberingStore =
      NumberingStore(); // Initialize here

  /// Manages all hyperlink-related operations for the current compilation process.
  late final HyperlinkStore hyperlinkStore = HyperlinkStore(); // New property

  /// Manages all font definitions and embedded font files for the current compilation process.
  late final FontStore fontStore = FontStore();

  Future<Archive?> compile(
    DocxDocument document, {
    bool applyCustomTheme = false,
  }) async {
    if (document.sections.isEmpty) {
      _emit(DocxEvent.end(error: 'Document content is empty'));
      return null;
    }
    final Set<String> supportedFileExtensions =
        document.options.supportedFileExtensions;
    final Archive archive = Archive();
    final DocumentOptions options = document.options;
    _emit(DocxEvent.start());
    await archive.clear();

    mediaStore.reset();
    hyperlinkStore.reset();
    numberingStore.reset();
    fontStore.reset();

    if (setNormalStyleToNotStyledParagraphs) {
      assert(
        options.docStyles.getStyleById(defaultNormalStyle.styleId) != null,
        'The style "${defaultNormalStyle.styleId}" not '
        'exist in your DocumentStylesSheet',
      );
    }

    final DocumentContext documentContext = DocumentContext(
      options: options,
      store: mediaStore,
      fontStore: fontStore,
      hyperlinkStore: hyperlinkStore,
      numberingStore: numberingStore,
      defaultNormalStyle: defaultNormalStyle,
      setNormalStyleToNotStyledParagraphs: setNormalStyleToNotStyledParagraphs,
    );

    numberingStore.initializeAndApplyContext(documentContext);

    _emit(DocxEvent.searching(subject: 'Searching media (images)'));
    mediaStore.discoverMedia(document, supportedFileExtensions);
    _emit(DocxEvent.searching(subject: 'Searching hyperlinks'));
    hyperlinkStore.discoverHyperlinks(document);

    // Discover fonts (either dynamically or from DocumentOptions)
    _emit(DocxEvent.searching(subject: 'Discovering fonts'));
    fontStore.discoverFonts(
      document,
      dynamicSearchEnabled: dynamicFontSearch,
    );

    int lastRId = 1000;
    _emit(DocxEvent.unknownProgress(subject: 'Registering images'));
    // this part register all the media allow context
    // and different part of the nodes
    // to access to image references
    final List<RelationShip> imageRelationships =
        await mediaStore.registerAndBuildImageRelationships(
      lastRId,
      namespaces['images']!,
    );
    // Update lastRId after adding images
    _emit(DocxEvent.unknownProgress(subject: 'Registering links'));
    lastRId += imageRelationships.length;
    final List<RelationShip> hyperlinkRelationships =
        hyperlinkStore.buildHyperlinkRelationships(
      lastRId,
      namespaces['hyperlinks']!,
    );

    // Update lastRId after adding hyperlinks
    lastRId += hyperlinkRelationships.length;
    String? theme;

    //TODO: fix the issue where something is bad in xml generation
    final List<(String, XmlComponentBase)> components =
        <(String, XmlComponentBase<dynamic>)>[
      // since we need register first the theme
      // we pass document.xml.rels
      // first to take then the generated theme id
      (
        documentXmlRelsFilePath,
        XmlDocumentRelsComponent(
          relations: <RelationShip>[
            ...XmlDocumentRelsComponent.defaultDocumentFileRelations(
              applyCustomTheme,
            ),
            ...imageRelationships,
            ...hyperlinkRelationships,
          ],
        ),
      ),
      // document must be always at the top
      // of the build since numbering, for example
      // needs to know the concrete numbering
      // instances in the doc content before
      // build file
      (
        documentFilePath,
        XmlDocumentComponent(
          body: XmlBodyComponent(
            document: document,
            themeId: theme,
          ),
        )
      ),
      (
        numberingXmlFilePath,
        numberingStore.buildNumberingXmlDocumentComponent(),
      ),
      (
        appFilePath,
        XmlAppComponent(
          title: documentContext.options.title,
          pages: documentContext.options.editorSettings.metadata.pages,
          words: documentContext.options.editorSettings.metadata.words,
          characters:
              documentContext.options.editorSettings.metadata.characters,
        )
      ),
      (relsFilePath, XmlRelsComponent()),
      (coreFilePath, XmlCoreComponent(options: document.options)),
      (stylesXmlFilePath, XmlStylesComponent()),
      (
        fontTableXmlFilePath,
        fontStore.buildFontTableXmlComponent(
          documentContext,
        ),
      ),
      (
        fontTableXmlRelsFilePath,
        fontStore.buildFontTableRelsXmlDocument(
          documentContext,
        ),
      ),
      (
        contentTypesPath,
        XmlContentTypeComponent(
          applyCustomTheme: applyCustomTheme,
          extensions: [
            ...mediaStore.extensions,
            ...fontStore.extensions,
          ],
        )
      ),
      (
        settingsXmlFilePath,
        XmlSettingsComponent(
          options: document.options.settings,
        )
      ),
      if (applyCustomTheme)
        (
          theme1XmlFilePath,
          XmlThemeComponent(options: document.options.theme),
        ),
      (
        webSettingsXmlFilePath,
        XmlWebSettingsComponent(
          options: document.options.webSettings,
        )
      )
    ];

    for (int i = 0; i < components.length; i++) {
      final XmlComponentBase<dynamic> comp = components[i].$2;
      final String path = components[i].$1;
      if (comp is XmlDocumentRelsComponent && applyCustomTheme) {
        theme = comp.theme;
      }
      _addXmlToArchive(
        archive,
        path,
        () => comp.buildDocument(
          documentContext,
        ),
      );
    }
    //TODO: we need to pass these methods to XmlComponentBase
    // implementations

    if (mediaStore.media.isNotEmpty) {
      await for (final (int, int) el in mediaStore.saveMedia(archive)) {
        _emit(DocxEvent.progress(
          subject: 'Saving media',
          current: el.$1,
          total: el.$2,
        ));
      }
    }

    if (fontStore.hasFonts) {
      _emit(DocxEvent.unknownProgress(
        subject: 'Adding embedded font files',
      ));
      await for (final _ in fontStore.addEmbeddedFontFilesToArchive(
        archive,
      )) {
        // _emit(DocxEvent.progress(
        //   subject: 'Saving media',
        //   current: ,
        //   total: el.$2,
        // ));
      }
    }

    try {
      _emit(DocxEvent.end(result: archive));
      return archive;
    } catch (e) {
      _emit(DocxEvent.end(error: e));
      return null;
    }
  }

  void _addXmlToArchive(
    Archive archive,
    String filePath,
    xml.XmlDocument Function() generateXmlDocument,
  ) {
    archive.add(
      ArchiveFile.bytes(
        filePath,
        stringToBytes(
          generateXmlDocument().toXmlString(),
        ),
      ),
    );
  }

  static Uint8List stringToBytes(String source) {
    return utf8.encode(source);
  }

  static String bytesToString(Uint8List source) {
    //NOTE: we will need to check if emojis or complex
    // characters are present in the document and comes
    // with correct byte sequences
    return utf8.decode(source, allowMalformed: false);
  }

  void release() {
    _eventController.close();
  }
}
