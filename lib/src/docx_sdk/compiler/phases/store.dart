import '../../sdk.dart';
import '../../stores/listenable_store.dart';

abstract class BaseStore {
  void storeXml(XmlComponentBase component);
  void storeContent(DocxTreeNode component);
}

class Stores {
  Stores({required this.stores});

  final Map<String, BaseStore> stores;
}
