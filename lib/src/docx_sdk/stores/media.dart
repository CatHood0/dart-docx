import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';

import '../../../docx.dart';
import '../../core/extensions/cast_ext.dart';
import '../../core/extensions/string_ext.dart';
import '../mixins/ignorable_mixin.dart';
import '../utils/logger/logger_configs.dart';
import '../xml_components/xml_content_type_component.dart';

//TODO: add listeners to events
/// Manages all media-related operations for a Docx document,
/// including discovering, registering, and creating relationships for images.
class MediaStore {
  MediaStore();
  static const String mediaPath = 'word/media/';

  // both are closely related, so, both have a pointer
  // to get and set elements with fastly
  late DrawingElementCounterStore drawingStore;

  // both are closely related, so, both have a pointer
  // to get and set elements with fastly
  late DocumentRelsCounterStore docRelsStore;

  /// Stores registered [MediaData] objects, keyed by their generated unique name.
  final Map<String, MediaData> media = <String, MediaData>{};

  /// Stores discovered media components ([FloatingImage], [LazyFloatingImage]), keyed by their internal ID.
  final Map<String, DocxTreeNode<ImageData<dynamic>>> mediaComponents =
      <String, DocxTreeNode<ImageData<dynamic>>>{};

  final List<XmlOverrideElementTypeComponent> overrides =
      <XmlOverrideElementTypeComponent>[];

  /// Stores all unique file extensions found among the discovered media.
  final Set<String> extensions = <String>{};

  /// Internal counter for generating unique media file names.
  int _lastMediaNameId = 1;

  /// Resets the media store to its initial state, clearing all discovered and registered data.
  void reset() {
    _lastMediaNameId = 1;
    extensions.clear();
    media.clear();
    overrides.clear();
  }

  /// Whether the store is empty and requires to got in XmlComponent tree
  bool get needStore => media.isEmpty;

  /// Store all the media in the tree
  void discoverMedia(
    DocxDocument data, [
    Set<String> supportedFileExtensions = const <String>{},
  ]) {
    //TODO: use parent methods of DocumentRoot
    for (final DocxTreeNode parent in data.root.child) {
      CompilerLogger.root.d(
        'Discovering images in '
        'parent ${parent.runtimeType}:${parent.id}',
      );
      // since we can have multiple images in one element,
      // we need to get all of them
      final List<DocxTreeNode<dynamic>> images = parent.visitAllElement(
            visitChildrenIfNeeded: true,
            (DocxTreeNode<dynamic> el) {
              return el.child is ImageData &&
                  supportedFileExtensions.contains(
                    el.child.extension,
                  );
            },
          ) ??
          <DocxTreeNode<dynamic>>[];
      if (images.isNotEmpty) {
        // sorry, i know that at this point, this is a classic O(n^2)
        // but its so boring making another solution at this moment of my
        // life
        images.forEach((image) {
          final DocxTreeNode<ImageData<Object>> imageComponent = image
              .visitElement(
                  visitChildrenIfNeeded: true,
                  (
                    DocxTreeNode<dynamic> el,
                  ) =>
                      el.child is ImageData<Object>)!
              .cast<DocxTreeNode<ImageData<Object>>>();
          CompilerLogger.root.d(
            'Registering ${imageComponent.id} of path ${imageComponent.child.buffer.castOrNull<File>() ?? 'Unknown'}',
          );
          mediaComponents[imageComponent.id] = imageComponent;
          extensions.add(imageComponent.child.extension);
        });
      }
    }

    CompilerLogger.root
        .i('End discover with ${mediaComponents.length} elements');
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
    String imageNamespace, {
    void Function(int, int)? onProgress,
  }) async {
    final List<RelationShip> imageRelationships = <RelationShip>[];

    for (int index = 0; index < mediaComponents.values.length; index++) {
      final DocxTreeNode<ImageData<dynamic>> imgComponent =
          mediaComponents.values.elementAt(index);
      onProgress?.call(index + 1, mediaComponents.values.length);

      CompilerLogger.root.d(
        'Building image relation for $index ${imgComponent.id}',
      );

      // Skip when required
      if (imgComponent is IgnorableMixin &&
          (imgComponent as IgnorableMixin).shouldIgnore()) {
        CompilerLogger.root.d(
          'Ignored ${imgComponent.id}',
        );
        continue;
      }

      // Increment RId for each new image relationship
      final int currentRId = docRelsStore.getNextId(imgComponent.id);
      // Assign unique rId to the component
      CompilerLogger.root.d(
        'Generated Relation ID for ${imgComponent.id}: $currentRId',
      );

      final String generatedMediaName = generateMediaName(
        // Increment internal ID for filename generation
        _lastMediaNameId++,
        trim: true,
        isImage: true,
      );

      CompilerLogger.root.d(
        'Generated Media Name for ${imgComponent.id}: $generatedMediaName',
      );

      imgComponent.rId = 'rId$currentRId';
      final ImageData<dynamic> imageData = imgComponent.child
        ..name = generatedMediaName;

      final MediaData mediaData = MediaData(
        name: generatedMediaName,
        fileName: generatedMediaName.trim().replaceAll(' ', ''),
        extension: imageData.extension,
        // This ID is often used for `rid` in content XML
        id: currentRId,
        bytes: imageData.buffer is Uint8List
            ? imageData.buffer
            : await (imageData.buffer as File).readAsBytes(),
        relationshipId: imgComponent.rId!,
      );

      // Store MediaData by its generated name
      media[generatedMediaName] = mediaData;

      CompilerLogger.root.d(
        'Stored ${imgComponent.id} => $generatedMediaName',
      );

      onProgress?.call(index + 1, mediaComponents.values.length);

      final String fullPath =
          '$mediaPath${mediaData.fileName}.${mediaData.extension}';

      CompilerLogger.root.d(
        'Full path of ${imgComponent.id} => $fullPath',
      );

      // these things are passed to the content type since it's used
      // to let to the editor to know how use images
      overrides.add(
        XmlOverrideElementTypeComponent(
          part: '/$fullPath',
          contentType:
              XmlContentTypeComponent.mimetypeFromExt(mediaData.extension),
        ),
      );

      imageRelationships.add(
        RelationShip(
          rId: imgComponent.rId!,
          // word folder is not required
          target: 'media/${mediaData.fileName}.${mediaData.extension}',
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
      final String fullPath = '$mediaPath${data.fileName}.${data.extension}';
      archive.add(
        ArchiveFile.bytes(
          fullPath,
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

  /// Gets the id that is aiming to the document.xml.rels
  ///
  /// We store both ids in two different versions
  ///
  /// [id]: the number assigned to the relation ship
  /// [imageRefId]: the same, but in string way. Something as: `rId$assignedId`
  int? getAssignedIdForRef(String imageRefId) {
    if (mediaComponents[imageRefId] != null) {
      final DocxTreeNode<ImageData<dynamic>>? component =
          mediaComponents[imageRefId];
      if (component == null) return null;
      assert(component.rId != null,
          'rId must be defined at this point of the generation');
      assert(
        media[component.child.name] != null,
        '"name" property of the component '
        'rId: ${component.rId}, id: ${component.id} '
        'must be defined. Ensure you are calling '
        'discoverMedia first and '
        'registerAndBuildImageRelationships then',
      );
      return media[component.child.name]!.id;
    }
    for (final MediaData media in media.values) {
      if (media.relationshipId == imageRefId ||
          media.id == int.tryParse(imageRefId)) {
        return media.id;
      }
    }
    return null;
  }

  /// Gets the index of the graphic where this media is
  int getIndexId() {
    return drawingStore.getNextId();
  }

  /// Gets the raw `rId` that was inserted in document.xml.rels
  String? getRelationshipIdForRef(String imageRefId) {
    if (mediaComponents[imageRefId] != null) {
      final DocxTreeNode<ImageData<dynamic>>? component =
          mediaComponents[imageRefId];
      if (component == null) return null;
      assert(component.rId != null,
          'rId must be defined at this point of the generation');
      assert(
        media[component.child.name] != null,
        '"name" property of the component '
        'rId: ${component.rId}, id: ${component.id} '
        'must be defined. Ensure you are calling '
        'discoverMedia first and '
        'registerAndBuildImageRelationships then',
      );
      return media[component.child.name]!.relationshipId;
    }
    for (final MediaData media in media.values) {
      if (media.relationshipId == imageRefId ||
          media.id == int.tryParse(imageRefId)) {
        return media.relationshipId;
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
