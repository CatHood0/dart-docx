import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

import '../../../docx.dart';
import '../core/extensions/string_ext.dart';
import 'events/docx_event.dart';

//TODO: add insert, delete, and replacement capabilities
class DocxSdk {
  DocxSdk({
    required this.options,
    DocxDocument? object,
  }) : lastDocumentObject = object;

  //NOTE: probably we will move these to DocxDocument class
  final DocumentOptions options;
  DocxDocument? lastDocumentObject;

  //
  final Archive _archive = Archive();
  final ZipEncoder _encoder = ZipEncoder();

  // to allow modifying certain parts of the docx result
  // we can implement these methods
  void insert() {}
  void replace() {}
  void delete() {}

  Future<Uint8List?> createDocument(
    DocxDocument data, {
    required Set<String> supportedFileExtensions,
  }) async {
    if (data.sections.isEmpty) return null;
    await _archive.clear();

    final (
      Map<String, ComponentContainer> images,
      Set<String> knowedExtensions
    ) = _getAllMedia(
      data,
      supportedFileExtensions,
    );
    //TODO: register all extensions in Content_Types
    final Map<String, String> registeredMediaNames = {};

    // Build the xml relations ships
    _addXmlToArchive(
      _archive,
      documentXmlRelsFilePath,
      () => generateDocumentXmlRels(
        (int lastId) => _buildRelationShips(
          hyperlinks: _getAllHyperlinks(data),
          images: images,
          registeredMediaNames: registeredMediaNames,
          lastId: lastId,
        ),
      ),
    );

    final Map<String, MediaData> mediaRegistered = await _registerMediaData(
      images,
      registeredMediaNames,
    );

    final DocxComponentContext documentContext = DocxComponentContext(
      media: mediaRegistered,
      options: options,
    );

    _addXmlToArchive(
      _archive,
      documentFilePath,
      () => data.toXml(context: documentContext),
    );
    _addXmlToArchive(
      _archive,
      stylesXmlFilePath,
      () => generateStylesXML(documentContext.options),
    );
    _addXmlToArchive(
      _archive,
      appFilePath,
      () => generateAppXml(options),
    );
    _addXmlToArchive(
      _archive,
      coreFilePath,
      () => generateCoreXml(options),
    );
    _addXmlToArchive(
      _archive,
      contentTypesPath,
      () => generateContentTypesXml(
        knowedExtensions: knowedExtensions,
      ),
    );
    _addXmlToArchive(_archive, relsFilePath, generateRelsXml);
    _addXmlToArchive(
      _archive,
      fontTableXmlFilePath,
      generateFontTableXML,
    );
    _addXmlToArchive(
      _archive,
      numberingXmlFilePath,
      generateNumberingXMLTemplate,
    );
    _addXmlToArchive(_archive, themeXmlFilePath, generateThemesXml);
    _addXmlToArchive(_archive, settingsXmlFilePath, generateSettingsXML);
    _addXmlToArchive(_archive, webSettingsXmlFilePath, generateWebSettingsXML);

    _addMediaFilesToArchive(_archive, mediaRegistered);

    // just assign the value if all is right
    lastDocumentObject = data;

    return _encoder.encodeBytes(
      _archive,
      autoClose: true,
    );
  }

  Stream<DocxEvent> createDocumentStream(
    DocxDocument data, {
    required Set<String> supportedFileExtensions,
  }) async* {
    if (data.sections.isEmpty) {
      yield DocxEvent.end(error: 'Document content is empty');
      return;
    }

    yield DocxEvent.start();
    await _archive.clear();

    //TODO: register all extensions in Content_Types
    final Map<String, String> registeredMediaNames = <String, String>{};
    //
    final Map<String, MediaData> mediaRegistered = <String, MediaData>{};

    yield DocxEvent.searching(subject: 'Searching media (images)');
    final (
      Map<String, ComponentContainer> images,
      Set<String> knowedExtensions
    ) = _getAllMedia(
      data,
      supportedFileExtensions,
    );
    yield DocxEvent.searching(subject: 'Searching hyperlinks');
    final List<RunBase> hyperlinks = _getAllHyperlinks(
      data,
    );

    // this part register all the media to registeredMediaNames
    // and allow context and different part of the nodes
    // to access to image references
    _addXmlToArchive(
      _archive,
      documentXmlRelsFilePath,
      () => generateDocumentXmlRels(
        (int lastId) => _buildRelationShips(
          hyperlinks: hyperlinks,
          images: images,
          registeredMediaNames: registeredMediaNames,
          lastId: lastId,
        ),
      ),
    );

    //TODO: we need to fix lastMediaId
    int lastMediaId = 1;
    for (int index = 0; index < images.values.length; index++) {
      final ComponentContainer img = images.values.elementAt(index);
      if (img is! Image && img is! LazyImage) continue;
      // if lazy images cannot be loaded, we skip them
      if (img is LazyImage && !(await img.canLoad)) {
        continue;
      }
      final MediaData media = MediaData(
        name: registeredMediaNames[img.id] as String,
        extension: img.data.extension,
        id: lastMediaId,
        bytes: img is Image
            ? img.data.bytes
            : await (img.data as LazyImageData).file.readAsBytes(),
        imageRefId: img.rId!,
      );
      yield DocxEvent.progress(
        subject: 'Registering images',
        current: index,
        total: images.values.length,
      );
      img.data.name = media.name;
      mediaRegistered[media.name] = media;
      lastMediaId++;
    }

    final DocxComponentContext documentContext = DocxComponentContext(
      media: mediaRegistered,
      options: options,
    );

    _addXmlToArchive(
      _archive,
      documentFilePath,
      () => data.toXml(context: documentContext),
    );
    _addXmlToArchive(
      _archive,
      stylesXmlFilePath,
      () => generateStylesXML(documentContext.options),
    );
    _addXmlToArchive(
      _archive,
      appFilePath,
      () => generateAppXml(options),
    );
    _addXmlToArchive(
      _archive,
      coreFilePath,
      () => generateCoreXml(options),
    );
    _addXmlToArchive(
      _archive,
      contentTypesPath,
      () => generateContentTypesXml(
        knowedExtensions: knowedExtensions,
      ),
    );
    _addXmlToArchive(_archive, relsFilePath, generateRelsXml);
    _addXmlToArchive(
      _archive,
      fontTableXmlFilePath,
      generateFontTableXML,
    );
    _addXmlToArchive(
      _archive,
      numberingXmlFilePath,
      generateNumberingXMLTemplate,
    );
    _addXmlToArchive(_archive, themeXmlFilePath, generateThemesXml);
    _addXmlToArchive(_archive, settingsXmlFilePath, generateSettingsXML);
    _addXmlToArchive(_archive, webSettingsXmlFilePath, generateWebSettingsXML);

    _addMediaFilesToArchive(
      _archive,
      mediaRegistered,
    );

    // just assign the value if all is right
    lastDocumentObject = data;
    try {
      final Uint8List result = _encoder.encodeBytes(
        _archive,
        autoClose: true,
      );
      yield DocxEvent.end(result: result);
    } catch (e) {
      yield DocxEvent.end(error: e);
    }
  }

  Future<void> save(
    DocxDocument data, {
    required Set<String> supportedFileExtensions,
    required String filePath,
  }) async {
    await _archive.clear();

    final (
      Map<String, ComponentContainer> images,
      Set<String> knowedExtensions
    ) = _getAllMedia(
      data,
      supportedFileExtensions,
    );
    //TODO: register all extensions in Content_Types
    final Map<String, String> registeredMediaNames = {};
    final Map<String, MediaData> mediaRegistered = await _registerMediaData(
      images,
      registeredMediaNames,
    );

    final DocxComponentContext documentContext = DocxComponentContext(
      media: mediaRegistered,
      options: options,
    );

    // Build the xml relations ships
    _addXmlToArchive(
      _archive,
      documentXmlRelsFilePath,
      () => generateDocumentXmlRels(
        (int lastId) => _buildRelationShips(
          hyperlinks: _getAllHyperlinks(data),
          images: images,
          registeredMediaNames: registeredMediaNames,
          lastId: lastId,
        ),
      ),
    );

    _addXmlToArchive(
      _archive,
      documentFilePath,
      () => data.toXml(context: documentContext),
    );
    _addXmlToArchive(
      _archive,
      stylesXmlFilePath,
      () => generateStylesXML(documentContext.options),
    );
    _addXmlToArchive(
      _archive,
      appFilePath,
      () => generateAppXml(options),
    );
    _addXmlToArchive(
      _archive,
      coreFilePath,
      () => generateCoreXml(options),
    );
    _addXmlToArchive(
      _archive,
      contentTypesPath,
      () => generateContentTypesXml(
        knowedExtensions: knowedExtensions,
      ),
    );
    _addXmlToArchive(_archive, relsFilePath, generateRelsXml);
    _addXmlToArchive(
      _archive,
      fontTableXmlFilePath,
      generateFontTableXML,
    );
    _addXmlToArchive(
      _archive,
      numberingXmlFilePath,
      generateNumberingXMLTemplate,
    );
    _addXmlToArchive(_archive, themeXmlFilePath, generateThemesXml);
    _addXmlToArchive(_archive, settingsXmlFilePath, generateSettingsXML);
    _addXmlToArchive(_archive, webSettingsXmlFilePath, generateWebSettingsXML);

    _addMediaFilesToArchive(_archive, mediaRegistered);

    // just assign the value if all is right
    lastDocumentObject = data;

    final OutputFileStream stream = OutputFileStream(filePath);

    _encoder.encode(_archive, autoClose: true, output: stream);

    await stream.close();
  }

  Future<Map<String, MediaData>> _registerMediaData(
    Map<String, ComponentContainer> images,
    Map<String, String> registeredMediaNames, {
    void Function(int, int)? onRegister,
  }) async {
    final Map<String, MediaData> mediaRegistered = <String, MediaData>{};
    int lastMediaId = 1;
    for (int index = 0; index < images.values.length; index++) {
      final ComponentContainer img = images.values.elementAt(index);
      if (img is! Image && img is! LazyImage) continue;
      // if lazy images cannot be loaded, we skip them
      if (img is LazyImage && !(await img.canLoad)) {
        continue;
      }
      final MediaData media = MediaData(
        name: registeredMediaNames[img.id] as String,
        extension: img.data.extension,
        id: lastMediaId,
        bytes: img is Image
            ? img.data.bytes
            : await (img.data as LazyImageData).file.readAsBytes(),
        imageRefId: img.rId!,
      );
      onRegister?.call(index + 1, images.values.length);
      img.data.name = media.name;
      mediaRegistered[media.name] = media;
      lastMediaId++;
    }
    return mediaRegistered;
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

  void _addMediaFilesToArchive(
    Archive archive,
    Map<String, MediaData> mediaRegistered,
  ) {
    for (final MediaData media in mediaRegistered.values) {
      archive.add(
        ArchiveFile.bytes(
          'word/media/'
          '${media.name.removeAllWhitespaces()}.${media.extension}',
          media.bytes,
        ),
      );
    }
  }

  List<RelationShip> _buildRelationShips({
    required List<RunBase> hyperlinks,
    required Map<String, ComponentContainer> images,
    required Map<String, String> registeredMediaNames,
    required int lastId,
  }) {
    int lastMediaId = 1000;
    return <RelationShip>[
      ...images.values.map<RelationShip>(
        (ComponentContainer e) {
          assert(
            e is Image || e is LazyImage,
            'Found element ${e.runtimeType} when Image '
            'or LazyImage were the expected elements',
          );
          e.rId ??= 'rId${lastId + 1}';
          final String name = generateMediaName(
            lastMediaId,
            trim: true,
            isImage: true,
          );
          lastMediaId++;
          registeredMediaNames[e.id] = name;
          lastId++;
          return RelationShip(
            rId: e.rId!,
            target: 'media/${name.removeAllWhitespaces()}.${e.data.extension}',
            type: namespaces['images']!,
            mode: null,
          );
        },
      ),
      ...hyperlinks.map<RelationShip>((RunBase hyperlink) {
        lastId++;
        hyperlink.rId ??= 'rId$lastId';
        return RelationShip(
          rId: hyperlink.rId!,
          target: hyperlink.link,
          type: namespaces['hyperlinks']!,
          mode: 'External',
        );
      }),
    ];
  }

  List<RunBase> _getAllHyperlinks(DocxDocument data) {
    final List<RunBase> hyperlinks = <RunBase>[];
    for (final ComponentContainer parent in data.sections) {
      final List<RunBase> hyperlink = List<RunBase>.from(
        parent.visitAllElement(
              (DocxContent el) => el is HyperlinkRun,
              visitChildrenIfNeeded: true,
            ) ??
            <RunBase>[],
      );
      if (hyperlink.isNotEmpty) {
        hyperlinks.addAll(hyperlink);
      }
    }
    return hyperlinks;
  }

  (Map<String, ComponentContainer>, Set<String>) _getAllMedia(
    DocxDocument data,
    Set<String> supportedFileExtensions,
  ) {
    final Map<String, ComponentContainer> images = <String, Image>{};
    final Set<String> knowedExtensions = <String>{};
    for (final ComponentContainer parent in data.sections) {
      if (parent is Paragraph) {
        final ComponentContainer? image = parent.visitElement(
          (DocxContent el) =>
              (el is Image || el is LazyImage) &&
              supportedFileExtensions.contains(
                el.data.extension,
              ),
          visitChildrenIfNeeded: true,
        ) as ComponentContainer?;
        if (image != null) {
          images[image.id] = image;
          knowedExtensions.add(image.data.extension);
        }
        continue;
      }
      final ComponentContainer? image = parent.visitElement(
        (el) =>
            (el is Image || el is LazyImage) &&
            supportedFileExtensions.contains(
              el.data.extension,
            ),
      ) as ComponentContainer?;
      if (image != null) {
        images[image.id] = image;
        knowedExtensions.add(image.data.extension);
      }
    }
    return (images, knowedExtensions);
  }

  static Uint16List stringToBytes(String source) {
    return Uint16List.fromList(source.codeUnits);
  }

  static String bytesToString(Uint8List source) {
    //NOTE: we will need to check if emojis or complex
    // characters are present in the document and comes
    // with correct byte sequences
    return utf8.decode(source, allowMalformed: false);
  }
}
