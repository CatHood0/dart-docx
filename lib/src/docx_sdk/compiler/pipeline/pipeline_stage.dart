import 'pipeline_context.dart';

/// Stage categories in the compilation pipeline.
///
/// Each category represents a different phase in the DOCX
/// document compilation process.
enum StageCategory {
  /// Stages that run before any processing.
  /// Useful for environment initialization and validation.
  preCompile,

  /// Stages that discover and analyze document elements.
  /// Identify resources such as images, fonts, hyperlinks, etc.
  discovery,

  /// Stages that transform and process discovered data.
  /// Prepare information for XML generation.
  processing,

  /// Stages that build the document XML components.
  /// Generate the final DOCX file content.
  build,

  /// Stages that run after compilation.
  /// Finalize the file and clean up resources.
  postCompile,
}

/// Represents an individual stage in the compilation pipeline.
///
/// Every stage receives a [PipelineContext] and operates exclusively through it.
/// No additional parameters are required, allowing flexible configuration.
///
/// To create a new stage, extend this class and implement:
/// - [name]: Unique stage identifier
/// - [execute]: Main stage logic
/// - [category]: Stage category
///
/// Usage example:
/// ```dart
/// class MediaDiscoveryStage extends PipelineStage {
///   const MediaDiscoveryStage();
///
///   @override
///   String get name => 'media_discovery';
///
///   @override
///   int get order => 10;
///
///   @override
///   StageCategory get category => StageCategory.discovery;
///
///   @override
///   String get description => 'Discovers and registers all media elements';
///
///   @override
///   bool shouldExecute(PipelineContext context) {
///     return !context.flags.skipMediaDiscovery;
///   }
///
///   @override
///   void execute(PipelineContext context) {
///     context.mediaStore.discoverMedia(
///       context.document,
///       context.options.supportedFileExtensions,
///     );
///   }
/// }
/// ```
abstract class PipelineStage {
  const PipelineStage();

  /// Unique stage identifier.
  ///
  /// Must be unique within the pipeline. Used for logging
  /// and to identify the stage in case of errors.
  String get name;

  /// Execution order within its category.
  ///
  /// Stages with lower order execute first.
  /// Order only has meaning between stages in the same category.
  int get order => 0;

  /// Whether this stage should execute.
  ///
  /// Returns true by default. Can be overridden to implement
  /// conditional logic based on context, for example to
  /// skip stages via [ExecutionFlags].
  ///
  /// Example:
  /// ```dart
  /// @override
  /// bool shouldExecute(PipelineContext context) {
  ///   return !context.flags.skipMediaDiscovery;
  /// }
  /// ```
  bool shouldExecute(PipelineContext context) => true;

  /// Executes the stage logic.
  ///
  /// The [context] contains all necessary information to operate.
  /// The context is mutable and changes propagate to subsequent stages.
  ///
  /// The stage must only modify [context] and return nothing.
  /// All information must be available in the context for
  /// subsequent stages.
  void execute(PipelineContext context);

  /// Stage category.
  ///
  /// Determines in which pipeline phase the stage will execute.
  StageCategory get category;

  /// Detailed description for documentation.
  ///
  /// Useful for debugging and generating automatic pipeline documentation.
  String get description;
}
