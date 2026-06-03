import '../../components/inheriteds/inherited_node.dart';
import '../../sdk.dart';

class FontsProvider extends InheritedNode {
  FontsProvider({
    required super.child,
    required this.store,
    super.id,
    super.parent,
  });

  final FontStore store;

  static FontStore of(DocxNode node) {
    final FontsProvider? el = node.getAncestorOfExactType<FontsProvider>();

    //TODO: improve error
    if (el == null) {
      throw Exception(
        'FontStore was not provided in the tree:\n'
        '${node.dumpTree()}',
      );
    }

    return el.store;
  }

  @override
  FontsProvider get copy => FontsProvider(
        id: id,
        child: child,
        store: store,
        parent: parent,
      );

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    FontStore? store,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return FontsProvider(
      child: child ?? this.child,
      store: store ?? this.store,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
