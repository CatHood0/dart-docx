import '../../../docx.dart';

/// Manages SDT (Structured Document Tag) identifiers for a Docx document.
///
/// This store ensures that all SDT elements have unique IDs by:
/// - Generating sequential IDs when no preferred ID is provided
/// - Using provided IDs when specified
/// - Tracking used IDs to prevent conflicts
///
/// Similar to [NumberingStore], this store is reset at the start of
/// each document compilation to ensure fresh ID allocation.
///
/// ## Example usage:
/// ```dart
/// // In DocxCompiler.compile():
/// sdtStore.reset();
///
/// // In SdtPlainText.buildXml():
/// final int sdtId = context.sdtStore.getNextId(preferredId: sdtId);
/// ```
//TODO: we should allow computing ids and assigning node id
// to avoid re-using existing ones for incremental changes
class SdtStore extends Store {
  SdtStore();

  /// Tracks all registered SDT IDs to ensure uniqueness.
  final Map<String, int> _registeredIds = <String, int>{};

  /// The next auto-generated ID to use when no preferred ID is provided.
  int _nextAutoId = 1;

  @override
  String get storeName => 'SDT Counter Store';

  /// Registers an ID as already used.
  ///
  /// This is called internally by [getNextId] when a preferred ID is provided.
  /// Use this method to pre-register IDs that may be used by the document.
  void registerId(String nodeId, int id) {
    _registeredIds[nodeId] = id;
  }

  /// Gets the next available SDT ID.
  ///
  /// If [preferredId] is provided and not already registered, it will be used.
  /// Otherwise, a new auto-generated ID is returned and registered.
  ///
  /// Returns: A unique SDT ID to use in the XML.
  int getNextId({required String nodeId, int? preferredId}) {
    if (_registeredIds[nodeId] != null) {
      return _registeredIds[nodeId]!;
    }
    if (preferredId != null && !_registeredIds.containsKey(nodeId)) {
      _registeredIds[nodeId] = preferredId;
      // Update _nextAutoId to be after the preferred ID if needed
      if (preferredId >= _nextAutoId) {
        _nextAutoId = preferredId + 1;
      }
      return preferredId;
    }

    // Find the next available auto-generated ID
    while (_registeredIds.containsValue(_nextAutoId)) {
      _nextAutoId++;
    }

    final int id = _nextAutoId;
    _registeredIds[nodeId] = id;
    _nextAutoId++;
    return id;
  }

  /// Resets the store to its initial state.
  ///
  /// This should be called at the start of each document compilation.
  @override
  void reset() {
    _registeredIds.clear();
    _nextAutoId = 1;
  }

  @override
  void initialize(PipelineContext context) {}

  /// Returns the count of registered IDs.
  int get registeredCount => _registeredIds.length;

  /// Returns all registered IDs (for debugging purposes).
  Map<String, int> get registeredIds => Map.from(_registeredIds);
}
