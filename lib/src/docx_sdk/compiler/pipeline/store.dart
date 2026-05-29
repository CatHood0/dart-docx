import 'package:meta/meta.dart';

import '../../../../docx.dart';

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

  List<int>? _path;
  String? _id;

  @mustCallSuper
  List<DocxNode>? resolveRoot(DocxNode node) {
    final List<DocxNode> sections = <DocxNode<dynamic>>[];

    /// Uses cache to avoid re-computing too many times a root element
    /// that wont be moved during execution of stores
    if (_path != null) {
      final DocxNode<dynamic>? root = node.queryPath(_path!);
      if (root != null && root.id == _id) {
        return root.child.cast();
      } else {
        _path = null;
        _id = null;
      }
    }

    final RootBody? root = node.visitElement(
      (e) => e is RootBody,
      visitChildrenIfNeeded: true,
    ) as RootBody?;
    if (root == null) {
      CompilerLogger.root.warning(
        'Not found RootBody in any point of the tree. '
        'We will visit any element that contains a child of '
        'type List<DocxNode>',
      );
      final DocxNode<List<DocxNode>>? element = node.visitElement(
        (DocxNode<dynamic> e) => e.child is List<DocxNode>,
        visitChildrenIfNeeded: true,
      ) as DocxNode<List<DocxNode>>?;

      if (element != null) {
        sections.addAll(element.child);
        _path = element.path;
        _id = element.id;
      } else {
        CompilerLogger.root.warning(
          'Skipping discovery of '
          '$runtimeType instance. Couldn\'t be founded '
          'any RootBody or DocxNode<List<DocxNode>> '
          'in the tree',
        );
        return null;
      }
    } else {
      sections.addAll(root.child);
      _path = root.path;
      _id = root.id;
    }
    return sections;
  }
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
