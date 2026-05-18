import 'pipeline_context.dart';

/// Base interface for all compiler stores.
///
/// Stores can be replaced by custom implementations
/// via [DocxPipeline.configureStores].
///
/// ## Store Lifecycle
///
/// 1. **CREATE**: Created with its dependencies (can be via constructor)
/// 2. **CONFIGURE** (optional): `configure()` is called if the store is configurable
/// 3. **INITIALIZE**: `initialize(context)` is called to set up cross-references
/// 5. **BUILD**: Stages use the store to build XML components
/// 7. **RESET**: `reset()` is called to clear state between compilations
///
/// To create a custom store:
/// ```dart
/// class CustomMediaStore implements Store {
///   @override
///   String get storeName => 'CustomMediaStore';
///
///   @override
///   void reset() {
///     // Clear state
///   }
///
///   @override
///   void initialize(PipelineContext context) {
///     // Configure with context
///   }
/// }
/// ```
abstract class Store {
  /// Store name for logging and debugging.
  ///
  /// Must be unique among all stores.
  String get storeName;

  /// Resets the store to its initial state.
  ///
  /// Called at the beginning of each compilation to ensure
  /// a clean state. Must clear all internal data.
  void reset();

  /// Initializes the store with the pipeline context.
  ///
  /// Cross-dependencies between stores are configured here.
  /// Called after [reset] and before executing any
  /// stage that uses the store.
  void initialize(PipelineContext context);
}

/// Mixin for stores that can be configured before initialize.
///
/// Stores using this mixin can receive custom configuration
/// via [configure()] before [initialize()] is called.
mixin ConfigurableStore<S> on Store {
  S? _config;
  S? get config => _config;

  /// Configures the store with custom options.
  ///
  /// Must be called before [initialize()].
  void configure(S config) {
    _config = config;
  }
}
