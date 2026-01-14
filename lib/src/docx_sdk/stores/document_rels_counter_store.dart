
import '../../../docx.dart';
import 'listenable_store.dart';

class DocumentRelsCounterStore extends ListenableStore {
  late MediaStore mediaStore;
  int _lastId = 1;

  /// Count all the elements wrapped by a Drawing component.
  ///
  /// Commonly used to maintain a count of the internal graphics
  final Set<int> count = <int>{};

  /// The elements wrapped by a Drawing component.
  final Map<String, int> elements = <String, int>{};

  int getNextId([String? ref]) {
    while (count.contains(_lastId)) {
      _lastId++;
    }
    count.add(_lastId);
    if (ref != null) {
      elements[ref] = _lastId;
    }
    return _lastId++;
  }

  int? getIdFromRef({required String ref}) => elements[ref];

  void reset() {
    _lastId = 1;
    count.clear();
    elements.clear();
  }
}
