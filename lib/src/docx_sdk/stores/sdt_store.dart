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
class SdtStore {
  SdtStore();

  /// Tracks all registered SDT IDs to ensure uniqueness.
  final Set<int> _registeredIds = <int>{};

  /// The next auto-generated ID to use when no preferred ID is provided.
  int _nextAutoId = 1;

  /// Registers an ID as already used.
  ///
  /// This is called internally by [getNextId] when a preferred ID is provided.
  /// Use this method to pre-register IDs that may be used by the document.
  void registerId(int id) {
    _registeredIds.add(id);
  }

  /// Gets the next available SDT ID.
  ///
  /// If [preferredId] is provided and not already registered, it will be used.
  /// Otherwise, a new auto-generated ID is returned and registered.
  ///
  /// Parameters:
  /// - [preferredId]: An optional ID to use if available. If null or already
  ///   registered, a new ID will be generated.
  ///
  /// Returns: A unique SDT ID to use in the XML.
  int getNextId({int? preferredId}) {
    if (preferredId != null && !_registeredIds.contains(preferredId)) {
      _registeredIds.add(preferredId);
      // Update _nextAutoId to be after the preferred ID if needed
      if (preferredId >= _nextAutoId) {
        _nextAutoId = preferredId + 1;
      }
      return preferredId;
    }

    // Find the next available auto-generated ID
    while (_registeredIds.contains(_nextAutoId)) {
      _nextAutoId++;
    }

    final int id = _nextAutoId;
    _registeredIds.add(id);
    _nextAutoId++;
    return id;
  }

  /// Resets the store to its initial state.
  ///
  /// This should be called at the start of each document compilation.
  void reset() {
    _registeredIds.clear();
    _nextAutoId = 1;
  }

  /// Returns the count of registered IDs.
  int get registeredCount => _registeredIds.length;

  /// Returns all registered IDs (for debugging purposes).
  Set<int> get registeredIds => Set.from(_registeredIds);
}
