import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

import '../../docx.dart';
import 'events/docx_event.dart';
import 'xml_components/docProps/xml_app_component.dart';
import 'xml_components/rels/xml_document_rels_component.dart';
import 'xml_components/rels/xml_rels_component.dart';

/// [DocxCompiler] is responsible for compiling a [DocxDocument] object
/// into a .docx file (a ZIP archive containing XML and media files).
/// It orchestrates the generation of various XML parts of the document,
/// manages relationships between them, and includes embedded media.
class DocxCompiler {
  DocxCompiler();

  late final StreamController<DocxEvent> _eventController =
      StreamController<DocxEvent>.broadcast();

  Stream<DocxEvent> get eventStream => _eventController.stream;
  void _emit(DocxEvent event) => _eventController.add(event);

  /// Manages all media-related operations for the current compilation process.
  late final MediaStore store = MediaStore();

  /// Manages all hyperlink-related operations for the current compilation process.
  late final HyperlinkStore hyperlinkStore = HyperlinkStore(); // New property

  Future<Archive?> compile(DocxDocument document) async {
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
    store.reset(); // Reset MediaStore for a new compilation
    hyperlinkStore.reset(); // Reset HyperlinkStore for a new compilation
    _emit(DocxEvent.searching(subject: 'Searching media (images)'));
    store.discoverMedia(document, supportedFileExtensions);
    _emit(DocxEvent.searching(subject: 'Searching hyperlinks'));
    hyperlinkStore.discoverHyperlinks(document);

    final DocumentContext documentContext = DocumentContext(
      hyperlinkStore: hyperlinkStore,
      options: options,
      store: store,
    );

    int lastRId = 1000;
    //TODO: register all extensions in Content_Types
    // 2. Register media, build image relationships, and update lastRId
    _emit(DocxEvent.unknownProgress(subject: 'Registering images'));
    // this part register all the media allow context and different part of the nodes
    // to access to image references
    final List<RelationShip> imageRelationships =
        await store.registerAndBuildImageRelationships(
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

    final List<(String, XmlComponentBase)> components = [
      (
        documentFilePath,
        XmlDocumentComponent(
          body: XmlBodyComponent(
            document: document,
          ),
        )
      ),
      (
        numberingXmlFilePath,
        XmlNumberingComponent(
          context: documentContext,
          options: genDefaultNumberingOptions(),
        )
      ),
      (
        documentXmlRelsFilePath,
        XmlDocumentRelsComponent(
          relations: [
            ...imageRelationships,
            ...hyperlinkRelationships,
          ],
        ),
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
      (coreFilePath, XmlRelsComponent()),
    ];

    for (int i = 0; i < components.length; i++) {
      final XmlComponentBase<dynamic> comp = components[i].$2;
      final String path = components[i].$1;
      _addXmlToArchive(
        archive,
        path,
        () => comp.buildDocument(documentContext),
      );
    }
    //TODO: we need to pass these methods to XmlComponentBase
    // implementations

    _addXmlToArchive(
      archive,
      stylesXmlFilePath,
      () => generateStylesXML(documentContext.options),
    );
    _addXmlToArchive(
      archive,
      coreFilePath,
      () => generateCoreXml(options),
    );
    _addXmlToArchive(
      archive,
      contentTypesPath,
      () => generateContentTypesXml(
        knowedExtensions: store.extensions,
      ),
    );
    _addXmlToArchive(
      archive,
      fontTableXmlFilePath,
      generateFontTableXML,
    );
    _addXmlToArchive(archive, themeXmlFilePath, generateThemesXml);
    _addXmlToArchive(archive, settingsXmlFilePath, generateSettingsXML);
    _addXmlToArchive(archive, webSettingsXmlFilePath, generateWebSettingsXML);

    await for (final (int, int) el in store.saveMedia(archive)) {
      _emit(DocxEvent.progress(
        subject: 'Saving media',
        current: el.$1,
        total: el.$2,
      ));
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
    return Uint8List.fromList(source.codeUnits);
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
