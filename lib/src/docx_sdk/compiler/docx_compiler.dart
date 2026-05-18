import 'package:archive/archive.dart';

import '../../../docx.dart';

//TODO: we will work on configurable outputs now
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
///
/// ## Architecture
///
/// This compiler delegates to [DocxPipeline] for actual compilation logic.
/// The pipeline provides a configurable stage-based system that allows:
/// - Skipping specific stages via [ExecutionFlags]
/// - Custom stores for advanced use cases
/// - Pre/post compile hooks for transformation
///
/// The [compile] method preserves all existing behavior while using the
/// pipeline internally. Stores are synchronized between compiler and pipeline.
class DocxCompiler {
  DocxCompiler({
    LoggablePhaseConfig? config,
    DocxPipeline? pipeline,
  }) : config = config ?? const LoggablePhaseConfig(enabled: false) {
    _pipeline = pipeline ??
        DocxPipeline(
          config: PipelineConfig(
            defaultNormalStyle: Style.ref('Normal'),
            applyNormalStyleIfNeeded: true,
            noTrim: true,
            checkStyleRefExistence: false,
            dynamicFontSearch: true,
          ),
        );
  }

  late final DocxPipeline _pipeline;

  LoggablePhaseConfig config;

  /// Enables dynamic font discovery from document content.
  ///
  /// When true, the compiler analyzes text runs to automatically register
  /// required fonts. When false, only fonts specified in [DocumentOptions.fonts]
  /// are used.
  bool get dynamicFontSearch => _pipeline.config.dynamicFontSearch;
  set dynamicFontSearch(bool value) {
    _pipeline.updateConfig(dynamicFontSearch: value);
  }

  /// Automatically applies the "Normal" paragraph style to unstyled paragraphs.
  ///
  /// When true, paragraphs without explicit styling will receive the default
  /// "Normal" style reference.
  bool get applyNormalStyleIfNeeded =>
      _pipeline.config.applyNormalStyleIfNeeded;
  set applyNormalStyleIfNeeded(bool value) {
    _pipeline.updateConfig(applyNormalStyleIfNeeded: value);
  }

  /// The default "Normal" style to apply when [applyNormalStyleIfNeeded] is true.
  Style get defaultNormalStyle => _pipeline.config.defaultNormalStyle;
  set defaultNormalStyle(Style value) {
    _pipeline.updateConfig(defaultNormalStyle: value);
  }

  /// Preserves whitespace in text runs by adding `xml:space="preserve"` attributes.
  ///
  /// When true, all text runs preserve their original whitespace formatting.
  bool get noTrim => _pipeline.config.noTrim;
  set noTrim(bool value) {
    _pipeline.updateConfig(noTrim: value);
  }

  /// Enables checking every Style.ref used in the Document content.
  ///
  /// This can make the compilation more slow, since every time we found
  /// a Style.ref, we need to request for existence to DocumentStyles
  bool get checkStyleRefExistence => _pipeline.config.checkStyleRefExistence;
  set checkStyleRefExistence(bool value) {
    _pipeline.updateConfig(checkStyleRefExistence: value);
  }

  /// Adds a hook that executes before starting the pipeline.
  void addPreCompileHook(PreCompileHook hook) {
    _pipeline.addPreCompileHook(hook);
  }

  /// Adds a hook that executes after completing the pipeline.
  void addPostCompileHook(PostCompileHook hook) {
    _pipeline.addPostCompileHook(hook);
  }

  /// Adds a hook that executes before each stage.
  void addPreStageHook(StageHook hook) {
    _pipeline.addPreStageHook(hook);
  }

  /// Adds a hook that executes after each stage.
  void addPostStageHook(StageHook hook) {
    _pipeline.addPostStageHook(hook);
  }

  /// Configures custom stores.
  ///
  /// Custom stores replace the default stores.
  /// Useful for advanced use cases requiring custom logic.
  void configureStores({required Iterable<Store> newStores}) {
    _pipeline.configureStores(newStores: newStores);
  }

  /// Configured media store (custom or default).
  void setStandardStores() {
    _pipeline.setStandardStores();
  }

  /// Compiler event stream.
  ///
  /// Delegates to the pipeline's event stream.
  Stream<DocxEvent> get eventStream => _pipeline.eventStream;

  /// Compiles a [DocxDocument] into a .docx archive.
  ///
  /// This method delegates to [DocxPipeline] for actual compilation,
  /// preserving all existing behavior while using the pipeline internally.
  ///
  /// Parameters:
  /// - [document]: The document to compile
  /// - [applyCustomTheme]: Whether to include custom theme XML
  /// - [flags]: The flags the determines what will be executed during compilation
  /// - [stages]: The stages that will be configured for compile
  ///
  /// Returns: A ZIP archive ready for saving as .docx file, or null on failure.
  Future<Archive?> compile(
    DocxDocument document, {
    bool applyCustomTheme = false,
    ExecutionFlags? flags,
    List<PipelineStage>? stages,
  }) async {
    stages ??= DocxPipeline.defaultStages;

    CompilerLogger.root.info(
      'Starting \'${document.options.title}\'.docx compilation process.',
    );

    // Delegate to pipeline - it will create the context using the unified factory
    final archive = await _pipeline.compile(
      document,
      applyCustomTheme: applyCustomTheme,
      flags: flags,
      logConfig: config,
      stages: stages,
    );

    if (archive != null) {
      CompilerLogger.root.info('Docx compilation completed successfully.');
    } else {
      // Get error from pipeline context if available
      final context = _pipeline.context;
      CompilerLogger.root.error(
        'Docx compilation failed: ${context.lastError}',
        context.lastError,
        null,
      );
    }

    return archive;
  }

  /// Releases compiler resources.
  void release() {
    _pipeline.release();
  }
}
