import '../../../docx.dart';

class DrawingElementCounterStore extends Store {
  late MediaStore mediaStore;
  int _lastId = 1;

  /// The elements wrapped by a Drawing component.
  final Map<String, int> elements = <String, int>{};

  int getNextId(String nodeId) {
    if (elements[nodeId] != null) {
      return elements[nodeId]!;
    }
    while (elements.values.contains(_lastId)) {
      _lastId++;
    }
    elements[nodeId] = _lastId;
    return _lastId;
  }

  int? getIdFromRef({required String ref}) => elements[ref];

  @override
  String get storeName => 'Drawing Graphics Element Counter Store';

  @override
  void reset() {
    _lastId = 1;
    elements.clear();
  }

  @override
  void initialize(PipelineContext context) {
    mediaStore = context.getStoreOfExactType<MediaStore>()!;
  }
}
