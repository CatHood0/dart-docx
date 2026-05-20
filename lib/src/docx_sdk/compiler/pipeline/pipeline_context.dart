import 'package:archive/archive.dart';

import '../../../../docx.dart';
import '../../sdk.dart';

class PipelineContext {
  PipelineContext({
    required this.tree,
    required this.document,
    required Map<Type, Store> stores,
    DocumentOptions? options,
    PipelineConfig? config,
    ExecutionFlags? flags,
    LoggablePhaseConfig? logConfig,
    List<RelationShip> defaultDocRelations = const [],
  })  : options = document.options,
        logConfig = logConfig ?? LoggablePhaseConfig(enabled: false),
        flags = flags ?? ExecutionFlags(),
        config = config ?? PipelineConfig(),
        defaultDocRelations = [...defaultDocRelations],
        _stores = Map.from(stores);

  final DocxDocument document;

  DocxNode tree;

  final Map<Type, Store> _stores;

  final DocumentOptions options;

  LoggablePhaseConfig logConfig;

  ExecutionFlags flags;

  final Map<String, dynamic> metadata = {};

  Archive archive = Archive();

  // TODO: add support to partial compilation
  bool get isTemplateCompilation => metadata.containsKey('zipBytes');

  String? get extractedTemplatePath => metadata['extractedTemplatePath'] as String?;

  List<RelationShip> defaultDocRelations;

  List<RelationShip> imageRelationships = [];

  List<RelationShip> hyperlinkRelationships = [];

  T? getStoreOfExactType<T extends Store>() {
    return _stores[T] as T?;
  }

  bool existStore<T extends Store>() {
    return _stores[T] != null;
  }

  List<Store> getStores() => _stores.values.toList();

  bool isCompiled = false;

  Object? _lastError;
  Object? get lastError => _lastError;

  bool _hasFatalError = false;
  bool get hasFatalError => _hasFatalError;

  PipelineConfig config;

  void registerError(
    Object error, [
    StackTrace? stackTrace,
    bool isFatal = true, // NUEVO: indica si el error detiene la compilación
  ]) {
    _lastError = error;
    if (isFatal) {
      _hasFatalError = true; // NUEVO: flag para errores fatales
    }
    CompilerLogger.root.error(
      'Pipeline error${isFatal ? " (fatal)" : ""}: $error',
      error,
      stackTrace ?? StackTrace.current,
    );
  }

  bool get hasNumberingUsage {
    return document.root.visitElement(
          visitChildrenIfNeeded: true,
          (DocxNode<dynamic> el) {
            return el is Paragraph && el.numbering != null || el is NumberingList;
          },
        ) !=
        null;
  }

  void emit(DocxEvent event) {}

  void resetEventController() {}
}
