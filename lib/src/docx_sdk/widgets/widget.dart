import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../docx.dart';
import '../../core/extensions/cast_ext.dart';
import '../exceptions/docx_compilation_exception.dart';

abstract class Widget extends DocxNode<DocxNode> {
  Widget({String? key}) : super(id: key, child: EmptyNode());

  DocxNode? _child;

  @override
  DocxNode<dynamic> get child {
    return _child ??= build()..parent = this;
  }

  DocxNode build();

  @mustCallSuper
  @override
  List<XmlNode> buildXml() {
    return child.buildXml();
  }
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
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    final DocxNode<dynamic> el = child;
    if (!visitChildrenIfNeeded && shouldGetElement(el)) {
      return el.toList();
    }
    return el.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }

  @mustCallSuper
  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    final DocxNode<dynamic> el = child;
    if (!visitChildrenIfNeeded && shouldGetElement(el)) {
      return el;
    }
    return el.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }
}

abstract class StatefulWidget extends Widget {
  StatefulWidget({super.key});

  State? _lastState;

  State<StatefulWidget> createElement();

  @override
  void init() {
    super.init();
    _cacheElement();
    _lastState!._owner = this;
    _lastState!.initState();
  }

  @override
  void deactivate() {
    super.init();
    _lastState!.deactivate();
    _lastState = null;
  }

  @override
  DocxNode<dynamic> build() {
    if (_lastState != null && _lastState!._child != null) {
      return _lastState!._child!;
    }
    final DocxNode<dynamic> el = _lastState!.build()..parent = this;

    if (_lastState!._child == null) {
      _lastState!._child = el;
    }

    return _lastState!._child!;
  }

  void _cacheElement() {
    _lastState ??= createElement();
  }

  @mustCallSuper
  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    final DocxNode<dynamic> el = child;
    if (!visitChildrenIfNeeded && shouldGetElement(el)) {
      return el.toList();
    }
    return el.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }

  @mustCallSuper
  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    final DocxNode<dynamic> el = child;
    if (!visitChildrenIfNeeded && shouldGetElement(el)) {
      return el;
    }
    return el.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }
}

abstract class State<T extends StatefulWidget> {
  DocxNode? _child;
  DocxNode? _owner;

  @mustCallSuper
  DocxNode get context {
    if (_owner?.parent == null) {
      throw DocxCompilationException(
        message: 'Try to access to the '
            'context value before insert this '
            'element in the tree as expected',
        cause: 'No assigned child to a parent into the nodes tree',
        node: _owner,
      );
    }

    return _owner!;
  }

  void initState() {}

  @mustCallSuper
  void deactivate() {
    _owner = null;
    _child = null;
  }

  DocxNode build();
}
