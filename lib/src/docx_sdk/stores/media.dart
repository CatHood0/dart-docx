import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';

import '../../../docx.dart';
import '../../core/extensions/string_ext.dart';
import '../mixins/ignorable_mixin.dart';

/// Manages all media-related operations for a Docx document,
/// including discovering, registering, and creating relationships for images.
class MediaStore {
  MediaStore();
  static const String mediaPath = 'word/media/';
  static const String rels = 'word/media/';

  /// Stores registered [MediaData] objects, keyed by their generated unique name.
  final Map<String, MediaData> media = <String, MediaData>{};

  /// Stores discovered media components ([Image], [LazyImage]), keyed by their internal ID.
  final Map<String, ComponentContainer<ImageData<dynamic>>> mediaComponents =
      <String, ComponentContainer<ImageData<dynamic>>>{};

  /// Stores all unique file extensions found among the discovered media.
  final Set<String> extensions = <String>{};

  /// Internal counter for generating unique media file names.
  int _lastMediaNameId = 1;

  /// Resets the media store to its initial state, clearing all discovered and registered data.
  void reset() {
    _lastMediaNameId = 1;
    extensions.clear();
    media.clear();
  }

  /// Whether the store is empty and requires to got in XmlComponent tree
  bool get needStore => media.isEmpty;

  /// Store all the media in the tree
  void discoverMedia(
    DocxDocument data, [
    Set<String> supportedFileExtensions = const <String>{},
  ]) {
    for (final DocxContent parent in data.sections) {
      final DocxContent? image = parent.visitElement(
        (DocxContent<dynamic> el) =>
            (el is Image || el is LazyImage) &&
            supportedFileExtensions.contains(el.data.extension),
      );
      if (image != null) {
        mediaComponents[image.id] = image as ComponentContainer<ImageData>;
        extensions.add(image.data.extension);
      }
    }
  }

  /// Registers discovered media components, loads lazy images (if applicable),
  /// generates unique names for media files, and constructs [RelationShip] objects
  /// for these images.
  ///
  /// This method clears any previously registered [media] data before processing.
  ///
  /// [startingRId] is the initial relationship ID to begin assigning from.
  /// [imageNamespace] is the XML namespace URI that identifies image relationships
  /// (e.g., `http://schemas.openxmlformats.org/officeDocument/2006/relationships/image`).
  /// [onProgress] is an optional callback that provides updates during the registration process,
  /// receiving `(current, total)` items processed.
  ///
  /// Returns a [Future] that completes with a list of [RelationShip] objects
  /// corresponding to the registered images.
  Future<List<RelationShip>> registerAndBuildImageRelationships(
    int startingRId,
    String imageNamespace, {
    void Function(int, int)? onProgress,
  }) async {
    int currentRId = startingRId;
    final List<RelationShip> imageRelationships = [];

    // Clear previously registered media before re-registering
    media.clear();

    for (int index = 0; index < mediaComponents.values.length; index++) {
      final ComponentContainer<ImageData<dynamic>> imgComponent =
          mediaComponents.values.elementAt(index);
      onProgress?.call(index + 1, mediaComponents.values.length);

      // Skip when required 
      if (imgComponent is IgnorableMixin &&
          (imgComponent as IgnorableMixin).shouldIgnore()) {
        continue;
      }

      // Increment RId for each new image relationship
      currentRId++;
      // Assign unique rId to the component
      imgComponent.rId ??= 'rId$currentRId';

      final String generatedMediaName = generateMediaName(
        // Increment internal ID for filename generation
        _lastMediaNameId++,
        trim: true,
        isImage: true,
      );

      final ImageData<dynamic> imageData = imgComponent.data
        ..name = generatedMediaName; // Store generated name in ImageData

      final MediaData mediaData = MediaData(
        name: generatedMediaName,
        extension: imageData.extension,
        // This ID is often used for `rid` in content XML
        id: currentRId,
        bytes: imageData is ImageData<Uint8List>
            ? imageData.buffer
            : await (imageData as ImageData<File>).buffer.readAsBytes(),
        imageRefId: imgComponent.rId!,
      );

      // Store MediaData by its generated name
      media[generatedMediaName] = mediaData;

      onProgress?.call(index + 1, mediaComponents.values.length);

      imageRelationships.add(
        RelationShip(
          rId: imgComponent.rId!,
          target: '$mediaPath${buildMediaFileName(mediaData)}',
          type: imageNamespace,
          mode: null,
        ),
      );
    }
    return imageRelationships;
  }

  /// Adds all registered media files to the provided [Archive].
  ///
  /// This method iterates through all [MediaData] objects stored in `media`
  /// and adds them as `ArchiveFile.bytes` to the archive under the `word/media/` path.
  ///
  /// [archive] The `Archive` instance to which media files will be added.
  /// Returns a [Stream<(index, total)>] that yields after each file is added (can be used for progress).
  Stream<(int, int)> saveMedia(
    Archive archive,
  ) async* {
    int index = 0;
    for (final MediaData data in media.values) {
      archive.add(
        ArchiveFile.bytes(
          '$mediaPath${buildMediaFileName(data)}',
          data.bytes,
        ),
      );
      yield (index, media.length);
      index++;
    }
  }

  /// Constructs the final file name for a [MediaData] object within the archive.
  /// The name is typically cleaned of whitespaces.
  ///
  /// [data] The [MediaData] object containing the name and extension.
  /// Returns the formatted media file name (e.g., 'image1.png').
  String buildMediaFileName(MediaData data) =>
      '${data.name.removeAllWhitespaces()}.${data.extension}';

  int? getMediaIdForRef(String imageRefId) {
    if (mediaComponents[imageRefId] != null) {
      final ComponentContainer<ImageData<dynamic>>? component =
          mediaComponents[imageRefId];
      if (component == null) return null;
      assert(component.rId != null,
          'rId must be defined at this point of the generation');
      assert(
        media[component.data.name] != null,
        '"name" property of the component '
        'rId: ${component.rId}, id: ${component.id} '
        'must be defined. Ensure you are calling '
        'discoverMedia first and '
        'registerAndBuildImageRelationships then',
      );
      return media[component.data.name]!.id;
    }
    for (final MediaData media in media.values) {
      if (media.imageRefId == imageRefId) {
        return media.id;
      }
    }
    return null;
  }

  int generateMediaId() {
    if (media.isEmpty) return 1;
    _lastMediaNameId = media.entries.last.value.id;
    return _lastMediaNameId;
  }
}
