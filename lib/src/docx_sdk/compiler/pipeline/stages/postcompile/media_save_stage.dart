import '../../../../sdk.dart';

/// Stage que guarda los archivos de medios al archive.
///
/// Itera sobre [MediaStore.media] y añade cada archivo al [Archive]
/// bajo la ruta `word/media/`.
///
/// Si [ExecutionFlags.skipMediaSave] es true, este stage no hace nada.
/// Si no hay medios, simplemente se loguea y continúa.
class MediaSaveStage extends PipelineStage {
  const MediaSaveStage();

  @override
  String get name => 'MediaSave';

  @override
  int get order => 0;

  @override
  StageCategory get category => StageCategory.postCompile;

  @override
  String get description =>
      'Guarda los archivos de medios (imágenes) al archive.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipMediaSave &&
        context.getStoreOfExactType<MediaStore>() != null;
  }

  @override
  Future<void> execute(PipelineContext context) async {
    if (context.getStoreOfExactType<MediaStore>()!.media.isEmpty) {
      CompilerLogger.root.debug('No media files to save.');
      return;
    }

    CompilerLogger.root.debug(
      'Saving media files to archive. Total: ${context.getStoreOfExactType<MediaStore>()!.media.length}',
    );

    int current = 0;
    await for (final (int, int) progress in context
        .getStoreOfExactType<MediaStore>()!
        .saveMedia(context.archive)) {
      current = progress.$1;
      final total = progress.$2;

      context.emit(DocxEvent.progress(
        subject: 'Saving media',
        current: current,
        total: total,
      ));

      CompilerLogger.root.debug('Media saving progress: $current/$total');
    }

    CompilerLogger.root.debug('Media files saved.');
  }
}
