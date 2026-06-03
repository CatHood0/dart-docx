
import '../../components/inheriteds/inherited_node.dart';
import '../../sdk.dart';

class MediaProvider extends InheritedNode {
  MediaProvider({
    required super.child,
    required this.store,
    super.id,
    super.parent,
  });

  final MediaStore store;

  static MediaStore of(DocxNode node) {
    final MediaProvider? el = node.getAncestorOfExactType<MediaProvider>();

    //TODO: improve error
    if (el == null) {
      throw Exception('MediaProvider was not provided in the tree');
    }

    return el.store;
  }

  @override
  MediaProvider get copy => MediaProvider(
        id: id,
        child: child,
        store: store,
        parent: parent,
      );

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    MediaStore? store,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return MediaProvider(
      child: child ?? this.child,
      store: store ?? this.store,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
