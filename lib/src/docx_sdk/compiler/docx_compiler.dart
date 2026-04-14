import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

import '../../../docx.dart';
import '../../core/extensions/cast_ext.dart';
import '../events/docx_event.dart';
import '../utils/logger/logger_configs.dart';
import '../xml_components/docProps/xml_app_component.dart';
import '../xml_components/docProps/xml_core_component.dart';
import '../xml_components/document/xml_body_component.dart';
import '../xml_components/rels/xml_document_rels_component.dart';
import '../xml_components/rels/xml_rels_component.dart';
import '../xml_components/styles/xml_styles_component.dart';
import '../xml_components/themes/xml_theme_component.dart';
import '../xml_components/web_settings/xml_web_settings_component.dart';
import '../xml_components/xml_content_type_component.dart';

/// Core compiler that transforms [DocxDocument] objects into .docx files.
///
/// This class orchestrates the entire document compilation process, including:
/// - XML generation for all document components (styles, content, properties)
/// - ZIP archive creation with proper DOCX structure
/// - Media management (images, fonts, hyperlinks)
/// - Progress reporting through event streams
///
/// The compiler follows the Open Packaging Conventions (OPC) to create
/// valid .docx files that are compatible with Microsoft Word and other editors.
///
/// Example usage:
/// ```dart
/// final compiler = DocxCompiler(config: LoggablePhaseConfig(enabled: true));
/// final archive = await compiler.compile(document);
/// final bytes = ZipEncoder().encode(archive);
/// await File('output.docx').writeAsBytes(bytes!);
/// ```
class DocxCompiler {
  DocxCompiler({
    LoggablePhaseConfig? config,
  }) : config = config ?? const LoggablePhaseConfig(enabled: false);

  LoggablePhaseConfig config;

  late StreamController<DocxEvent> _eventController =
      StreamController<DocxEvent>.broadcast();

  /// Enables dynamic font discovery from document content.
  ///
  /// When true, the compiler analyzes text runs to automatically register
  /// required fonts. When false, only fonts specified in [DocumentOptions.fonts]
  /// are used.
  bool dynamicFontSearch = true;

  /// Automatically applies the "Normal" paragraph style to unstyled paragraphs.
  ///
  /// When true, paragraphs without explicit styling will receive the default
  /// "Normal" style reference.
  bool applyNormalStyleIfNeeded = true;

  /// The default "Normal" style to apply when [applyNormalStyleIfNeeded] is true.
  Style defaultNormalStyle = Style.ref('Normal');

  /// Preserves whitespace in text runs by adding `xml:space="preserve"` attributes.
  ///
  /// When true, all text runs preserve their original whitespace formatting.
  bool noTrim = true;

  /// Enables checking every Style.ref used in the Document content.
  ///
  /// This can make the compilation more slow, since every time we found
  /// a Style.ref, we need to request for existence to DocumentStyles
  bool checkStyleRefExistence = false;

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

  /// Manages all drawing definitions for the current compilation process.
  late DocumentRelsCounterStore docRelsStore = DocumentRelsCounterStore();

  DocumentContext buildContext(DocumentOptions options) {
    return DocumentContext(
      options: options,
      mediaStore: mediaStore,
      fontStore: fontStore,
      hyperlinkStore: hyperlinkStore,
      numberingStore: numberingStore,
      drawingStore: drawingStore,
      defaultNormalStyle: defaultNormalStyle,
      setNormalStyleToNotStyledParagraphs: applyNormalStyleIfNeeded,
      noTrim: noTrim,
      checkStyleRefExistence: checkStyleRefExistence,
    );
  }

  /// Compiles a [DocxDocument] into a .docx archive.
  ///
  /// This is the main entry point for document generation. It orchestrates:
  /// 1. Document structure analysis and preparation
  /// 2. Media discovery and registration
  /// 3. XML generation for all document parts
  /// 4. ZIP archive assembly with proper relationships
  ///
  /// Parameters:
  /// - [document]: The document to compile
  /// - [applyCustomTheme]: Whether to include custom theme XML
  ///
  /// Returns: A ZIP archive ready for saving as .docx file, or null on failure.
  Future<Archive?> compile(
    DocxDocument document, {
    bool applyCustomTheme = false,
  }) async {
    config.init();

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

    docRelsStore.reset();
    mediaStore.reset();
    hyperlinkStore.reset();
    numberingStore.reset();
    fontStore.reset();
    drawingStore.reset();
    mediaStore.drawingStore = drawingStore;
    drawingStore.mediaStore = mediaStore;
    mediaStore.docRelsStore = docRelsStore;
    hyperlinkStore.docRelsStore = docRelsStore;

    final DocumentContext documentContext = buildContext(options);

    CompilerLogger.root.d('Document context built successfully.');

    if (applyNormalStyleIfNeeded) {
      assert(
        options.docStyles.getStyleById(defaultNormalStyle.styleId) != null,
        'The style "${defaultNormalStyle.styleId}" not '
        'exist in your DocumentStylesSheet',
      );
      CompilerLogger.root.d('Normal style check passed.');
    }

    final List<PageColumn>? columns = document.root.visitAllElement(
      visitChildrenIfNeeded: false,
      (DocxTreeNode<dynamic> el) {
        return el is PageColumn;
      },
    )?.cast();

    if (columns != null) {
      int index = 0;
      for (final PageColumn column in columns) {
        if (index > 0) {
          final DocxTreeNode<dynamic>? paragraph = column.child.firstOrNull;
          if (paragraph == null || paragraph is! Paragraph) {
            CompilerLogger.root.i(
              'Inserting column '
              'break in element at $index by no '
              'existent paragraph',
            );
            column.addFirst(
              Paragraph(
                children: <RunBase<dynamic>>[
                  Run(component: Break.columnBreak()),
                ],
              ),
            );
            break;
          }
          CompilerLogger.root.i(
            'Inserting column '
            'break in first '
            'element of the column at $index',
          );
          paragraph.addRunFirst(Run(component: Break.columnBreak()));
        }
        index++;
      }
    }

    final bool hasNumberingUsage = document.root.visitElement(
          visitChildrenIfNeeded: true,
          (DocxTreeNode<dynamic> el) {
            return el is Paragraph && el.cast<Paragraph>().numbering != null;
          },
        ) !=
        null;

    numberingStore.initializeAndApplyContext(documentContext);

    CompilerLogger.root.d('Numbering store initialized.');
    final List<RelationShip> defaultDocRelations =
        XmlDocumentRelsComponent.defaultDocumentFileRelations(
      applyCustomTheme,
      docRelsStore,
      hasNumberingUsage,
    );

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
      namespaces['images']!,
    );
    CompilerLogger.root
        .d('Image relationships built. Count: ${imageRelationships.length}.');

    // Update lastRId after adding images
    _emit(DocxEvent.unknownProgress(subject: 'Registering links'));
    CompilerLogger.root.d('Registering hyperlinks and building relationships.');
    final List<RelationShip> hyperlinkRelationships =
        hyperlinkStore.buildHyperlinkRelationships(
      namespaces['hyperlinks']!,
    );

    CompilerLogger.root.d(
        'Hyperlink relationships built. Count: ${hyperlinkRelationships.length}.');

    String? theme;
    CompilerLogger.root.d('Building XML components.');

    final List<XmlComponentBase> components = <XmlComponentBase<dynamic>>[
      XmlContentTypeComponent(
        applyCustomTheme: applyCustomTheme,
        overrides: mediaStore.overrides,
        extensions: <String>[
          ...mediaStore.extensions,
          ...fontStore.extensions,
        ],
      ),
      XmlRelsComponent(),
      XmlCoreComponent(options: document.options),
      XmlAppComponent(
          metadata: documentContext.options.editorSettings.metadata),

      // since we need register first the theme
      // we pass document.xml.rels
      // first to take then the generated theme id
      XmlDocumentRelsComponent(
        relations: <RelationShip>[
          ...defaultDocRelations,
          ...imageRelationships,
          ...hyperlinkRelationships,
        ],
      ),
      // document must be always at the top
      // of the build since numbering, for example
      // needs to know the concrete numbering
      // instances in the doc content before
      // build file
      XmlDocumentComponent(
        body: XmlBodyComponent(
          document: document,
          themeId: theme,
        ),
      ),
      if (hasNumberingUsage)
        numberingStore.buildNumberingXmlDocumentComponent(),
      XmlStylesComponent(),
      fontStore.buildFontTableXmlComponent(documentContext),
      if (dynamicFontSearch && fontStore.fontRelations.isNotEmpty)
        fontStore.buildFontTableRelsXmlDocument(documentContext),
      XmlSettingsComponent(options: document.options.settings),
      if (applyCustomTheme) XmlThemeComponent(options: document.options.theme),
      XmlWebSettingsComponent(options: document.options.webSettings)
    ];

    for (int i = 0; i < components.length; i++) {
      final XmlComponentBase<dynamic> comp = components[i];
      final String path = components[i].path;
      CompilerLogger.root
          .d('Building named ${comp.name} component to - "$path"');
      if (comp is XmlDocumentRelsComponent &&
          comp.path == DocxPaths.documentXmlRelsFilePath &&
          applyCustomTheme) {
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
      await for (void _ in fontStore.addEmbeddedFontFilesToArchive(
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
      _eventController.close();
      _eventController = StreamController<DocxEvent>.broadcast();
      return archive;
    } catch (e, s) {
      CompilerLogger.root.e(
        'Docx compilation failed: $e',
        e,
        s,
      );
      _emit(DocxEvent.end(error: e));
      _eventController = StreamController<DocxEvent>.broadcast();
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
