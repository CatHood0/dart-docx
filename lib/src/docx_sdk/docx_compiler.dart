import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

import '../../docx.dart';
import 'events/docx_event.dart';
import 'utils/logger/logger_configs.dart';
import 'xml_components/docProps/xml_app_component.dart';
import 'xml_components/docProps/xml_core_component.dart';
import 'xml_components/document/xml_body_component.dart';
import 'xml_components/rels/xml_document_rels_component.dart';
import 'xml_components/rels/xml_rels_component.dart';
import 'xml_components/styles/xml_styles_component.dart';
import 'xml_components/themes/xml_theme_component.dart';
import 'xml_components/web_settings/xml_web_settings_component.dart';
import 'xml_components/xml_content_type_component.dart';

class LoggablePhaseConfig {
  const LoggablePhaseConfig({
    this.loggablePhases = const <String>{},
    this.log,
    this.enabled = true,
  });

  final Set<String> loggablePhases;
  final void Function(String)? log;
  final bool enabled;

  void _init() {
    if (enabled) {
      LoggerConfiguration().activeHandler(printer: log);
    }
  }

  bool shouldLogPhase(String phaseName) {
    return loggablePhases.contains(phaseName);
  }
}

/// [DocxCompiler] is responsible for compiling a [DocxDocument] object
/// into a .docx file (a ZIP archive containing XML and media files).
/// It orchestrates the generation of various XML parts of the document,
/// manages relationships between them, and includes embedded media.
class DocxCompiler {
  DocxCompiler({
    LoggablePhaseConfig? config,
  }) : config = config ?? const LoggablePhaseConfig(enabled: false);

  LoggablePhaseConfig config;

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
  late MediaStore mediaStore = MediaStore();

  /// Manages all numbering definitions and instances for the current compilation process.
  late NumberingStore numberingStore = NumberingStore();

  /// Manages all hyperlink-related operations for the current compilation process.
  late HyperlinkStore hyperlinkStore = HyperlinkStore(); // New property

  /// Manages all font definitions and embedded font files for the current compilation process.
  late FontStore fontStore = FontStore();

  /// Manages all drawing definitions for the current compilation process.
  late DrawingElementCounterStore drawingStore = DrawingElementCounterStore();

  int lastRId = 1000;

  DocumentContext buildContext(DocumentOptions options) {
    return DocumentContext(
      options: options,
      mediaStore: mediaStore,
      fontStore: fontStore,
      hyperlinkStore: hyperlinkStore,
      numberingStore: numberingStore,
      drawingStore: drawingStore,
      defaultNormalStyle: defaultNormalStyle,
      setNormalStyleToNotStyledParagraphs: setNormalStyleToNotStyledParagraphs,
    );
  }

  Future<Archive?> compile(
    DocxDocument document, {
    bool applyCustomTheme = false,
  }) async {
    config._init();
    CompilerLogger.root.i('Starting Docx compilation process.');
    if (document.root.isEmpty) {
      CompilerLogger.root.e('Document content is empty. Aborting compilation.');
      _emit(DocxEvent.end(error: 'Document content is empty'));
      return null;
    }
    final Set<String> supportedFileExtensions =
        document.options.supportedFileExtensions;
    final Archive archive = Archive();
    final DocumentOptions options = document.options;
    _emit(DocxEvent.start());
    await archive.clear();

    lastRId = 1000;
    mediaStore.reset();
    hyperlinkStore.reset();
    numberingStore.reset();
    fontStore.reset();
    drawingStore.reset();
    mediaStore.drawingStore = drawingStore;
    drawingStore.mediaStore = mediaStore;

    final DocumentContext documentContext = buildContext(options);
    CompilerLogger.root.d('Document context built successfully.');

    if (setNormalStyleToNotStyledParagraphs) {
      assert(
        options.docStyles.getStyleById(defaultNormalStyle.styleId) != null,
        'The style "${defaultNormalStyle.styleId}" not '
        'exist in your DocumentStylesSheet',
      );
      CompilerLogger.root.d('Normal style check passed.');
    }

    numberingStore.initializeAndApplyContext(documentContext);
    CompilerLogger.root.d('Numbering store initialized.');

    _emit(DocxEvent.searching(subject: 'Searching media (images)'));
    CompilerLogger.root.d('Initiating media search.');
    mediaStore.discoverMedia(document, supportedFileExtensions);
    CompilerLogger.root.d(
        'Media search completed. Found ${mediaStore.mediaComponents.length} images.');

    _emit(DocxEvent.searching(subject: 'Searching hyperlinks'));
    CompilerLogger.root.d('Initiating hyperlink search.');
    hyperlinkStore.discoverHyperlinks(document);
    CompilerLogger.root.d(
        'Hyperlink search completed. Found ${hyperlinkStore.hyperlinks.length} hyperlinks.');

    // Discover fonts (either dynamically or from DocumentOptions)
    _emit(DocxEvent.searching(subject: 'Discovering fonts'));
    CompilerLogger.root.d('Initiating font discovery.');
    fontStore.discoverFonts(
      document,
      dynamicSearchEnabled: dynamicFontSearch,
    );
    CompilerLogger.root.d(
        'Font discovery completed. Found ${fontStore.hasFonts ? fontStore.fonts.length : 0} fonts.');

    _emit(DocxEvent.unknownProgress(subject: 'Registering images'));
    // this part register all the media allow context
    // and different part of the nodes
    // to access to image references
    CompilerLogger.root.d('Registering images and building relationships.');
    final List<RelationShip> imageRelationships =
        await mediaStore.registerAndBuildImageRelationships(
      lastRId,
      namespaces['images']!,
    );
    CompilerLogger.root
        .d('Image relationships built. Count: ${imageRelationships.length}.');

    // Update lastRId after adding images
    _emit(DocxEvent.unknownProgress(subject: 'Registering links'));
    CompilerLogger.root.d('Registering hyperlinks and building relationships.');
    lastRId += imageRelationships.length;
    final List<RelationShip> hyperlinkRelationships =
        hyperlinkStore.buildHyperlinkRelationships(
      lastRId,
      namespaces['hyperlinks']!,
    );

    CompilerLogger.root.d(
        'Hyperlink relationships built. Count: ${hyperlinkRelationships.length}.');

    // Update lastRId after adding hyperlinks
    lastRId += hyperlinkRelationships.length;
    String? theme;
    CompilerLogger.root.d('Building XML components.');

    final List<(String, XmlComponentBase)> components =
        <(String, XmlComponentBase<dynamic>)>[
      (DocxPaths.relsFilePath, XmlRelsComponent()),
      (
        DocxPaths.appFilePath,
        XmlAppComponent(
          title: documentContext.options.title,
          pages: documentContext.options.editorSettings.metadata.pages,
          words: documentContext.options.editorSettings.metadata.words,
          characters:
              documentContext.options.editorSettings.metadata.characters,
        )
      ),
      (DocxPaths.coreFilePath, XmlCoreComponent(options: document.options)),
      // since we need register first the theme
      // we pass document.xml.rels
      // first to take then the generated theme id
      (
        DocxPaths.documentXmlRelsFilePath,
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
        DocxPaths.documentFilePath,
        XmlDocumentComponent(
          body: XmlBodyComponent(
            document: document,
            themeId: theme,
          ),
        )
      ),
      (
        DocxPaths.numberingXmlFilePath,
        numberingStore.buildNumberingXmlDocumentComponent(),
      ),
      (DocxPaths.stylesXmlFilePath, XmlStylesComponent()),
      (
        DocxPaths.fontTableXmlFilePath,
        fontStore.buildFontTableXmlComponent(
          documentContext,
        ),
      ),
      (
        DocxPaths.fontTableXmlRelsFilePath,
        fontStore.buildFontTableRelsXmlDocument(
          documentContext,
        ),
      ),
      (
        DocxPaths.contentTypesPath,
        XmlContentTypeComponent(
          applyCustomTheme: applyCustomTheme,
          overrides: mediaStore.overrides,
          extensions: [
            ...mediaStore.extensions,
            ...fontStore.extensions,
          ],
        )
      ),
      (
        DocxPaths.settingsXmlFilePath,
        XmlSettingsComponent(
          options: document.options.settings,
        )
      ),
      if (applyCustomTheme)
        (
          DocxPaths.theme1XmlFilePath,
          XmlThemeComponent(options: document.options.theme),
        ),
      (
        DocxPaths.webSettingsXmlFilePath,
        XmlWebSettingsComponent(
          options: document.options.webSettings,
        )
      )
    ];

    for (int i = 0; i < components.length; i++) {
      final XmlComponentBase<dynamic> comp = components[i].$2;
      final String path = components[i].$1;
      CompilerLogger.root.d('Building XML component: $path');
      if (comp is XmlDocumentRelsComponent && applyCustomTheme) {
        theme = comp.theme;
      }
      _addXmlToArchive(
        archive,
        path,
        () => comp.buildDocument(
          documentContext,
        ),
        path,
      );
    }
    CompilerLogger.root.d('All XML components built and added to archive.');

    if (mediaStore.media.isNotEmpty) {
      CompilerLogger.root.d(
          'Saving media files to archive. Total: ${mediaStore.media.length}');
      await for (final (int, int) el in mediaStore.saveMedia(archive)) {
        _emit(DocxEvent.progress(
          subject: 'Saving media',
          current: el.$1,
          total: el.$2,
        ));
        CompilerLogger.root.d('Media saving progress: ${el.$1}/${el.$2}');
      }
      CompilerLogger.root.d('Media files saved.');
    }

    if (fontStore.hasFonts) {
      _emit(DocxEvent.unknownProgress(
        subject: 'Adding embedded font files',
      ));
      CompilerLogger.root.d('Adding embedded font files to archive.');
      await for (final _ in fontStore.addEmbeddedFontFilesToArchive(
        archive,
      )) {
        // _emit(DocxEvent.progress(
        //   subject: 'Saving media',
        //   current: ,
        //   total: el.$2,
        // ));
      }
      CompilerLogger.root.d('Embedded font files added.');
    }

    try {
      CompilerLogger.root.i('Docx compilation completed successfully.');
      _emit(DocxEvent.end(result: archive));
      return archive;
    } catch (e, s) {
      CompilerLogger.root.e(
        'Docx compilation failed: $e',
        e,
        s,
      );
      _emit(DocxEvent.end(error: e));
      return null;
    }
  }

  void _addXmlToArchive(
    Archive archive,
    String filePath,
    xml.XmlDocument Function() generateXmlDocument,
    String phaseName,
  ) {
    final xml.XmlDocument document = generateXmlDocument();
    if (config.shouldLogPhase(phaseName)) {
      CompilerLogger.root.i(
          'XML Content for $phaseName:\n${document.toXmlString(pretty: true)}');
    }
    archive.add(
      ArchiveFile.bytes(
        filePath,
        stringToBytes(
          document.toXmlString(),
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
