import '../../../../../core/namespaces.dart';
import '../../../../sdk.dart';

/// Stage that registers discovered images.
///
/// This stage iterates over [MediaStore.mediaComponents], generates unique names
/// for each image, assigns rIds, and creates [RelationShip] for each one.
///
/// Generated relationships are stored in [context.imageRelationships]
/// for use in [DocumentRelsBuildStage].
class ImageRegistrationStage extends PipelineStage {
  const ImageRegistrationStage();

  @override
  String get name => 'ImageRegistration';

  @override
  int get order => 2;

  @override
  StageCategory get category => StageCategory.processing;

  @override
  String get description =>
      'Registers images, generates unique names, and builds relationships.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipImageRegistration;
  }

  @override
  void execute(PipelineContext context) async {
    if (context.getStoreOfExactType<MediaStore>()!.mediaComponents.isEmpty) {
      CompilerLogger.root.debug('No images to register.');
      context.imageRelationships = [];
      return;
    }

    context.emit(DocxEvent.unknownProgress(subject: 'Registering images'));
    CompilerLogger.root.debug('Registering images and building relationships.');

    context.imageRelationships = await context
        .getStoreOfExactType<MediaStore>()!
        .registerAndBuildImageRelationships(
          namespaces['images']!,
        );

    CompilerLogger.root.debug(
      'Image relationships built. Count: ${context.imageRelationships.length}.',
    );
  }
}
