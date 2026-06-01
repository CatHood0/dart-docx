import 'dart:async';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../../core/extensions/cast_ext.dart';
import '../../registry/docx_registry.dart';
import '../../sdk.dart';
import 'stages/building/glossary_build_stage.dart';
import 'stages/discovery/glossary_usage_discovery_stage.dart';

/// DOCX document compilation pipeline.
///
/// This class orchestrates the execution of all stages in the correct order.
/// Allows extensive configuration of stores, hooks, and execution flags.
///
/// Usage example:
/// ```dart
/// final pipeline = DocxPipeline(
///   config: PipelineConfig(
///     applyCustomTheme: true,
///     defaultNormalStyle: Style.ref('Normal'),
///   ),
/// )
/// .configureStores(
///   newStores: <Store>[MyCustomMediaStore()],
/// )
/// .addPreCompileHook((ctx) => print('Starting compilation'))
/// .addPostCompileHook((ctx, archive) => print('Done!'));
///
/// final archive = await pipeline.compile(document);
/// ```
class DocxPipeline {
  DocxPipeline({
    PipelineConfig? config,
    ExecutionFlags? defaultFlags,
    Iterable<Store>? stores,
  })  : _config = config ?? PipelineConfig(),
        _stores = <Type, Store>{
          ...?stores?.toMap((
            Store e,
          ) =>
              e.runtimeType),
        },
        _defaultFlags = defaultFlags ?? const ExecutionFlags(),
        _effectiveFlags = defaultFlags ?? const ExecutionFlags();

  PipelineConfig _config;
  final ExecutionFlags _defaultFlags;
  ExecutionFlags _effectiveFlags;

  //TODO: stores are still "harcoded"
  // since we don't support yet wrapping
  // custom providers
  final Map<Type, Store> _stores;

  final List<PreCompileHook> _preCompileHooks = [];
  final List<PostCompileHook> _postCompileHooks = [];
  final List<StageHook> _preStageHooks = [];
  final List<StageHook> _postStageHooks = [];

  late StreamController<DocxEvent> _eventController =
      StreamController<DocxEvent>.broadcast();

  /// The pipeline context, reused across compilations.
  ///
  /// Created lazily on first [compile] call or when explicitly set via
  /// [setContext]. This allows DocxCompiler to provide its own context
  /// with pre-configured stores.
  PipelineContext? _context;

  /// Gets the current pipeline context.
  ///
  /// Throws if context has not been initialized yet.
  PipelineContext get context {
    if (_context == null) {
      throw StateError(
        'PipelineContext has not been initialized. '
        'Call compile() first or set the context explicitly.',
      );
    }
    return _context!;
  }

  /// Updates the pipeline configuration.
  ///
  /// Allows external code (like DocxCompiler) to modify the config
  /// without creating a new pipeline instance.
  void updateConfig({
    bool? applyCustomTheme,
    Style? defaultNormalStyle,
    bool? applyNormalStyleIfNeeded,
    bool? noTrim,
    bool? checkStyleRefExistence,
    bool? dynamicFontSearch,
  }) {
    _config = _config.copyWith(
      applyCustomTheme: applyCustomTheme ?? _config.applyCustomTheme,
      normalStyle: defaultNormalStyle ?? _config.normalStyle,
      normalStyleIfNeeded:
          applyNormalStyleIfNeeded ?? _config.normalStyleIfNeeded,
      noTrim: noTrim ?? _config.noTrim,
      checkStyleRefExistence:
          checkStyleRefExistence ?? _config.checkStyleRefExistence,
      dynamicFontSearch: dynamicFontSearch ?? _config.dynamicFontSearch,
    );
  }

  /// Configures custom stores.
  ///
  /// Custom stores replace the default stores.
  /// Useful for advanced use cases requiring custom logic.
  DocxPipeline configureStores({required Iterable<Store> newStores}) {
    for (final Store el in newStores) {
      _stores[el.runtimeType] = el;
    }
    return this;
  }

  /// Configured media store (custom or default).
  DocxPipeline setStandardStores() {
    return configureStores(
      newStores: <Store>[
        SdtStore(),
        FontStore(),
        MediaStore(),
        NumberingStore(),
        HyperlinkStore(),
        DocumentRelsCounterStore(),
        DrawingElementCounterStore(),
        GlossaryStore(),
      ],
    );
  }

  /// Adds a hook that executes before starting the pipeline.
  DocxPipeline addPreCompileHook(PreCompileHook hook) {
    _preCompileHooks.add(hook);
    return this;
  }

  /// Adds a hook that executes after completing the pipeline.
  DocxPipeline addPostCompileHook(PostCompileHook hook) {
    _postCompileHooks.add(hook);
    return this;
  }

  /// Adds a hook that executes before each stage.
  DocxPipeline addPreStageHook(StageHook hook) {
    _preStageHooks.add(hook);
    return this;
  }

  /// Adds a hook that executes after each stage.
  DocxPipeline addPostStageHook(StageHook hook) {
    _postStageHooks.add(hook);
    return this;
  }

  /// Clears all registered hooks.
  DocxPipeline clearHooks() {
    _preCompileHooks.clear();
    _postCompileHooks.clear();
    _preStageHooks.clear();
    _postStageHooks.clear();
    return this;
  }

  /// Resets the pipeline for a new compilation.
  void reset() {
    if (_context != null) {
      _context = null;
    }
    _effectiveFlags = _defaultFlags;
  }

  /// Compiles the document and returns the archive.
  ///
  /// If [flags] is provided, uses those flags for this compilation
  /// (temporarily overrides the effective flags).
  /// If [flags] is null, uses the current pipeline flags.
  ///
  /// The [applyCustomTheme] parameter allows including a custom theme.
  Future<Archive?> compile(
    DocxDocument document, {
    List<PipelineStage>? stages,
    bool applyCustomTheme = false,
    ExecutionFlags? flags,
    LoggablePhaseConfig? logConfig,
  }) async {
    if (flags != null) {
      _effectiveFlags = flags;
    }

    if (!_eventController.isClosed) {
      _eventController.close();
    }

    DocxElements.instance.initializeCompilation(true);
    _eventController = StreamController<DocxEvent>.broadcast();
    _eventController.add(DocxEvent.start());

    _context = PipelineContext(
      tree: document.root,
      document: document,
      options: document.options,
      config: _config.copyWith(applyCustomTheme: applyCustomTheme),
      flags: _effectiveFlags,
      logConfig: logConfig,
      stores: _stores,
    );

    _context!.logConfig.init();

    for (final PreCompileHook hook in _preCompileHooks) {
      hook(context);
    }

    // try {
    final List<PipelineStage> effectiveStages =
        List.from(stages ?? DocxPipeline.defaultStages)
          ..sort((a, b) {
            final categoryCompare =
                a.category.index.compareTo(b.category.index);
            if (categoryCompare != 0) return categoryCompare;
            return a.order.compareTo(b.order);
          });

    for (final PipelineStage stage in effectiveStages) {
      if (stage.shouldExecute(context)) {
        for (final StageHook hook in _preStageHooks) {
          hook(context, stage);
        }

        stage.execute(context);

        for (final StageHook hook in _postStageHooks) {
          hook(context, stage);
        }
      }
    }

    for (final PostCompileHook hook in _postCompileHooks) {
      hook(context, context.archive);
    }

    context.isCompiled = true;
    _eventController.add(DocxEvent.end(result: context.archive));
    DocxElements.instance.initializeCompilation(false);
    return context.archive;
    // } catch (e, s) {
    //   context
    //     ..registerError(
    //       e,
    //       s,
    //       true,
    //     )
    //     ..isCompiled = false;
    //   _eventController.add(DocxEvent.end(error: e));
    //   return null;
    // } finally {
    // }
  }

  /// Compiles the document from an existing ZIP file (template).
  ///
  /// If [flags] is provided, uses those flags for this compilation.
  /// The ZIP must be a valid .docx file to be used as a template.
  Future<Archive?> compileFromZip(
    Uint8List zipBytes,
    DocxDocument document, {
    bool applyCustomTheme = false,
    ExecutionFlags? flags,
  }) async {
    if (flags != null) {
      _effectiveFlags = flags;
    }

    sharedData['zipBytes'] = zipBytes;
    return compile(document, applyCustomTheme: applyCustomTheme);
  }

  /// Pipeline configuration.
  PipelineConfig get config => _config;

  /// Current pipeline flags.
  ExecutionFlags get flags => _effectiveFlags;

  /// Compiler event stream.
  Stream<DocxEvent> get eventStream => _eventController.stream;

  /// Data shared between stages.
  final Map<String, dynamic> sharedData = {};

  /// Releases pipeline resources.
  void release() {
    _eventController.close();
  }

  /// Executes the pipeline with specific flags.
  ///
  /// Useful for changing behavior without creating a new instance.
  /// The specified flags are used only for this compilation.
  DocxPipeline withFlags(ExecutionFlags flags) {
    _effectiveFlags = flags;
    return this;
  }

  /// Resets flags to default values.
  void resetFlags() {
    _effectiveFlags = _defaultFlags;
  }

  /// Gets the list of all pipeline stages.
  ///
  /// Includes PreCompile stages implemented in Phase 2.
  /// Other categories will be added in later phases.
  //TODO: divide stages by the target of what it does
  // and groups them
  static List<PipelineStage> get defaultStages {
    return <PipelineStage>[
      ...preCompileDiscoveryAndSetup,
      ...registerElementsInStoreStages,
      ...buildStages,
      ...saveInternalFilesAndMediaStages,
    ];
  }

  static List<PipelineStage> get preCompileDiscoveryAndSetup {
    return <PipelineStage>[
      const NumberingUsageDiscoveryStage(),
      const StoresInjectionStage(),
      const GlossaryUsageDiscoveryStage(),
      const StyleValidationStage(),
      const EnvironmentSetupStage(),
      const OptionsValidationStage(),
      const ArchiveInitStage(),
      const ColumnDiscoveryStage(),
      const NumberingDiscoveryStage(),
      const MediaDiscoveryStage(),
      const HyperlinkDiscoveryStage(),
      const FontDiscoveryStage(),
      const SdtDiscoveryStage(),
      const NumberingDiscoveryStage(),
    ];
  }

  static List<PipelineStage> get registerElementsInStoreStages {
    return <PipelineStage>[
      const RelationsRegistrationStage(),
      const ImageRegistrationStage(),
      const HyperlinkRegistrationStage(),
      const FontProcessingStage(),
      const ThemeResolutionStage(),
    ];
  }

  static List<PipelineStage> get buildStages {
    return <PipelineStage>[
      const ContentTypeBuildStage(),
      const AppPropsBuildStage(),
      const CorePropsBuildStage(),
      const RelsBuildStage(),
      const DocumentRelsBuildStage(),
      const DocumentBuildStage(),
      const GlossaryBuildStage(),
      const NumberingBuildStage(),
      const StylesBuildStage(),
      const FontTableBuildStage(),
      const FontRelsBuildStage(),
      const SettingsBuildStage(),
      const ThemeBuildStage(),
      const WebSettingsBuildStage(),
    ];
  }

  static List<PipelineStage> get saveInternalFilesAndMediaStages {
    return <PipelineStage>[
      const MediaSaveStage(),
      const EmbeddedFontsSaveStage(),
      const ArchiveFinalizationStage(),
      const EventEmissionStage(),
    ];
  }
}

class DocxElements {
  DocxElements._();

  static final DocxElements instance = DocxElements._();

  final Map<String, dynamic> _metadata = <String, dynamic>{'dpi': _imageDpi};

  static const int _imageDpi = 96;
  static bool _kDebugMode = false;

  static bool get kDebugMode => _kDebugMode;

  bool get kIsDebugMode => _metadata['ensureInitialize'] == true;
  bool get needsPreviousInitialization => _metadata['ensureInitialize'] == true;

  bool get initializeByCompile => _metadata['isCompiling'] == true;

  void debugMode([bool debug = true]) {
    _kDebugMode = debug;
  }

  void ensureInitialized() {
    _metadata['ensureInitialize'] = true;
    DocxRegistry.setDefaultRegistries();
  }

  void initializeCompilation(bool compiling) {
    _metadata['isCompiling'] = compiling;
  }

  int get dpi => _metadata['dpi'].cast();
  set dpi(int dpi) => _metadata['dpi'] = dpi;

  String createId() => nanoid(7);
}
