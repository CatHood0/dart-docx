import 'dart:typed_data';
import 'sdk.dart';

class DocxComponentContext {
  DocxComponentContext({
    required this.options,
    required Map<String, MediaData> media,
  }) : _media = media;

  final DocumentOptions options;

  DocumentStylesSheet get styles => options.docStyles;

  // all the media are saved
  // {filename: rid}
  final Map<String, MediaData> _media;

  Map<String, MediaData> get media =>
      Map<String, MediaData>.unmodifiable(_media);

  int _lastIdGenerated = 1;

  int? getMediaIdForImage(String imageRefId) {
    for (final MediaData media in _media.values) {
      if (media.imageRefId == imageRefId) {
        return media.id;
      }
    }
    return null;
  }

  int generateMediaId() {
    if (media.isEmpty) return 1;
    _lastIdGenerated = media.entries.last.value.id;
    return _lastIdGenerated;
  }

  DocxContent? _currentContentPart;
  DocxContent? get currentContentPart => _currentContentPart?.copy;
  set currentContentPart(DocxContent? content) {
    if (_currentContentPart == content) return;
    _currentContentPart = content;
  }
}

class MediaData {
  MediaData({
    required this.name,
    required this.id,
    required this.extension,
    required this.bytes,
    required this.imageRefId,
  });

  // this is the rId of the image
  final String imageRefId;
  final Uint8List bytes;
  // the name of the image into DOCX file
  final String name;
  // this id is auto-generated
  // to be pasted
  final int id;
  // the extension of this media
  final String extension;

  @override
  String toString() {
    return 'MediaData(name: $name.$extension, id: $id)';
  }
}
