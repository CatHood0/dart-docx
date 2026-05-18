import '../../../../../../docx.dart';
import '../../../../events/docx_event.dart';
import '../../../../utils/logger/logger_configs.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage that discovers all images in the document.
///
/// Iterates over direct children of DocumentRoot and looks for
/// image components ([FloatingImage], [LazyFloatingImage], [Image]) that match
/// the supported file extensions.
class MediaDiscoveryStage extends PipelineStage {
  const MediaDiscoveryStage();

  @override
  String get name => 'MediaDiscovery';

  @override
  int get order => 2;

  @override
  StageCategory get category => StageCategory.discovery;

  @override
  String get description => 'Discovers all images in the document.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipMediaDiscovery;
  }

  @override
  void execute(PipelineContext context) {
    context.emit(DocxEvent.searching(subject: 'Searching media (images)'));
    CompilerLogger.root.debug('Initiating media search.');

    final MediaStore store =
        context.getStoreOfExactType<MediaStore>() ?? MediaStore()
          ..discoverMedia(
            context.document,
            context.options.supportedFileExtensions,
          );

    //TODO: later add more debug info
    if (store.mediaComponents.isNotEmpty &&
        context.getStoreOfExactType<MediaStore>() == null) {
      throw Exception(
        'Found media elements (${store.media.length}) in the '
        'document tree, but not founded '
        'MediaStore into the provided \'stores\' property',
      );
    }

    CompilerLogger.root.debug(
      'Media search completed. '
      'Found ${store.mediaComponents.length} images.',
    );
  }
}
