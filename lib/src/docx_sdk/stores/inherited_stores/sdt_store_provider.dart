import '../../components/inheriteds/inherited_node.dart';
import '../../sdk.dart';

class SdtStoreProvider extends InheritedNode {
  SdtStoreProvider({
    required super.child,
    required this.store,
    super.id,
    super.parent,
  });

  final SdtStore store;

  static SdtStore of(DocxNode node) {
    final SdtStoreProvider? el =
        node.getAncestorOfExactType<SdtStoreProvider>();

    //TODO: improve error
    if (el == null) {
      throw Exception(
        'SdtStoreProvider was not provided in the tree:\n'
        '${node.dumpTree()}',
      );
    }

    return el.store;
  }

  @override
  SdtStoreProvider get copy => SdtStoreProvider(
        id: id,
        child: child,
        store: store,
        parent: parent,
      );

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    SdtStore? store,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return SdtStoreProvider(
      child: child ?? this.child,
      store: store ?? this.store,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
