import '../../components/inheriteds/inherited_node.dart';
import '../../sdk.dart';

class NumberingStoreProvider extends InheritedNode {
  NumberingStoreProvider({
    required super.child,
    required this.store,
    super.id,
    super.parent,
  });

  final NumberingStore store;

  static NumberingStore of(DocxNode node) {
    final NumberingStoreProvider? el = node.getAncestorOfExactType<NumberingStoreProvider>();

    //TODO: improve error
    if (el == null) {
      throw Exception('NumberingStoreProvider was not provided in the tree');
    }

    return el.store;
  }

  @override
  NumberingStoreProvider get copy => NumberingStoreProvider(
        id: id,
        child: child,
        store: store,
        parent: parent,
      );

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    NumberingStore? store,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return NumberingStoreProvider(
      child: child ?? this.child,
      store: store ?? this.store,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
