import '../../components/inheriteds/inherited_node.dart';
import '../../sdk.dart';

class HyperlinksProvider extends InheritedNode {
  HyperlinksProvider({
    required super.child,
    required this.store,
    super.id,
    super.parent,
  });

  final HyperlinkStore store;

  static HyperlinkStore of(DocxNode node) {
    final HyperlinksProvider? el =
        node.getAncestorOfExactType<HyperlinksProvider>();

    //TODO: improve error
    if (el == null) {
      throw Exception(
        'HyperlinksProvider was not provided in the tree:\n'
        '${node.dumpTree()}',
      );
    }

    return el.store;
  }

  @override
  HyperlinksProvider get copy => HyperlinksProvider(
        id: id,
        child: child,
        store: store,
        parent: parent,
      );

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    HyperlinkStore? store,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return HyperlinksProvider(
      child: child ?? this.child,
      store: store ?? this.store,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
