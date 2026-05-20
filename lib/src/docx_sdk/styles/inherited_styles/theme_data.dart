import '../../components/inheriteds/inherited_node.dart';
import '../../sdk.dart';

class ThemeData extends InheritedNode {
  ThemeData({
    required super.child,
    required this.styles,
    super.id,
    super.parent,
  });

  final DocumentStyles styles;

  static DocumentStyles of(BuildNodeContext context) {
    final ThemeData? el = context.getAncestorOfExactType<ThemeData>();

    //TODO: improve error
    if (el == null) {
      throw Exception('InheritedStyles was not provided in the tree');
    }

    return el.styles;
  }

  @override
  ThemeData get copy => ThemeData(
        id: id,
        child: child,
        styles: styles,
        parent: parent,
      );

  @override
  InheritedNode copyWith({
    DocxNode<dynamic>? child,
    DocumentStyles? styles,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return ThemeData(
      child: child ?? this.child,
      styles: styles ?? this.styles,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
