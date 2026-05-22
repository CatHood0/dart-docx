import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../docx.dart';
import '../../core/extensions/cast_ext.dart';
import '../exceptions/docx_compilation_exception.dart';

abstract class Widget extends DocxNode {
  Widget({String? key}) : super(id: key, child: null);

  DocxNode build();
}

abstract class StatelessWidget extends Widget {
  StatelessWidget({super.key});

  @mustCallSuper
  DocxNode get context {
    if (!mounted) {
      throw DocxCompilationException(
        message: 'Try to access to the '
            'context value before insert this '
            'element in the tree as expected',
        cause: 'No assigned child to a parent into the nodes tree',
        node: this,
      );
    }

    return parent!;
  }

  @override
  DocxNode<dynamic> build();

  @mustCallSuper
  @override
  List<XmlNode> buildXml() {
    return build().buildXml();
  }

  @mustCallSuper
  @override
  DocxNode<dynamic> get copy => build().copy;

  @mustCallSuper
  @override
  DocxNode<dynamic> copyWith({
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return build().copyWith(
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @mustCallSuper
  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    final DocxNode<dynamic> el = build();
    return shouldGetElement(el) ? el.toList() : null;
  }

  @mustCallSuper
  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    final DocxNode<dynamic> el = build();
    return shouldGetElement(el) ? el : null;
  }
}

// abstract class StatefulWidget extends Widget {
//   StatefulWidget({required super.key});

//   @override
//   DocxNode<dynamic> build();

//   @mustCallSuper
//   @override
//   List<XmlNode> buildXml() {
//     return build().buildXml();
//   }

//   @mustCallSuper
//   @override
//   DocxNode<dynamic> get copy => build().copy;

//   @mustCallSuper
//   @override
//   DocxNode<dynamic> copyWith({
//     String? id,
//     DocxNode<dynamic>? parent,
//   }) {
//     return build().copyWith(
//       id: id ?? this.id,
//       parent: parent ?? this.parent,
//     );
//   }

//   @mustCallSuper
//   @override
//   List<DocxNode<dynamic>>? visitAllElement(
//     bool Function(DocxNode<dynamic> element) shouldGetElement, {
//     bool visitChildrenIfNeeded = true,
//   }) {
//     if (shouldGetElement(this)) return [this];
//     final DocxNode<dynamic> el = build();
//     return shouldGetElement(el) ? el.toList() : null;
//   }

//   @mustCallSuper
//   @override
//   DocxNode<dynamic>? visitElement(
//     bool Function(DocxNode<dynamic> element) shouldGetElement, {
//     bool visitChildrenIfNeeded = true,
//   }) {
//     if (shouldGetElement(this)) return this;
//     final DocxNode<dynamic> el = build();
//     return shouldGetElement(el) ? el : null;
//   }
// }

// class State<T extends StatefulWidget> {
//   @mustCallSuper
//   @override
//   List<XmlNode> buildXml() {
//     return build().buildXml();
//   }

//   @mustCallSuper
//   @override
//   DocxNode<dynamic> get copy => build().copy;

//   @mustCallSuper
//   @override
//   DocxNode<dynamic> copyWith({
//     String? id,
//     DocxNode<dynamic>? parent,
//   }) {
//     return build().copyWith(
//       id: id ?? this.id,
//       parent: parent ?? this.parent,
//     );
//   }
// }
