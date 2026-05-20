import '../../components/inheriteds/inherited_node.dart';
import '../../sdk.dart';

class DrawingCounterProvider extends InheritedNode {
  DrawingCounterProvider({
    required super.child,
    required this.store,
    super.id,
    super.parent,
  });

  final DrawingElementCounterStore store;

  static DrawingElementCounterStore of(DocxNode node) {
    final DrawingCounterProvider? el =
        node.getAncestorOfExactType<DrawingCounterProvider>();

    //TODO: improve error
    if (el == null) {
      throw Exception(
        'InheritedDrawingElementCounterStore was not provided in the tree: \n'
        '${node.dumpTree()}',
      );
    }

    return el.store;
  }

  @override
  DrawingCounterProvider get copy => DrawingCounterProvider(
        id: id,
        child: child,
        store: store,
        parent: parent,
      );

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    DrawingElementCounterStore? store,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return DrawingCounterProvider(
      child: child ?? this.child,
      store: store ?? this.store,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
