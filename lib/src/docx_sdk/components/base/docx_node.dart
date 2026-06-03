import 'package:meta/meta.dart'
    show experimental, visibleForOverriding, mustCallSuper;
import 'package:xml/xml.dart' show XmlNode;

import '../../../core/extensions/cast_ext.dart';
import '../../registry/docx_registry.dart';
import '../../sdk.dart';
import '../inheriteds/inherited_node.dart';

//TODO: set auto assign this element as parent
// to remove unncessary behavior in ALL components
abstract class DocxNode<T> {
  DocxNode({
    required this.child,
    DocxNode? parent,
    String? id,
  })  : id = id ?? nanoid(7),
        _parent = parent;

  bool isEmptyNode() => this is EmptyNode;

  int length = 0;

  @visibleForOverriding
  void insertText(
    String text, {
    int? offset,
    int? path,
    List<Object>? styles,
    bool mergeStyles = true,
  }) {}

  @visibleForOverriding
  void deleteText({
    required int start,
    required int length,
    int? path,
  }) {}

  /// Remove all the elements with the [id] specified
  ///
  /// If [path] is provided, will access directly to the element
  /// and will apply the remove action there, so, ensure that
  /// the path aims to the parent that already contains the
  /// element that needs to be remove
  @visibleForOverriding
  void removeById(String id, {List<int> path = const <int>[]}) {}

  @visibleForOverriding
  void remove(DocxNode element, {List<int> path = const <int>[]}) {}

  /// Adds all the elements
  ///
  /// The way them are added depends on the class
  /// implementation
  @visibleForOverriding
  void addAll(List<DocxNode> components) {}

  /// Update element
  ///
  /// The way them are updated depends on the class
  /// implementation
  ///
  /// [strict] tells to the method that we cannot updated an element
  /// that has a different [id] value, and a different type from the
  /// expected one
  void updateElement(
    DocxNode component, {
    int? index,
    bool strict = true,
  }) {}

  T child;

  int index = -1;
  int get depth => path.length;

  @Deprecated(
    'setting depth value is deprecated. '
    'It is not a cached value already',
  )
  set depth(int depth) {}

  /// The xml relations id of this component
  ///
  /// Tipically is modified only when this content
  /// has a relation with .rels file
  //TODO: this should be deprecated and removed
  // since we have an store exactly for this
  String? rId;

  // Not used yet
  bool dirty = true;

  /// The internal random id of this component
  final String id;
  DocxNode? _parent;

  DocxNode? get parent => _parent;

  @mustCallSuper
  set parent(DocxNode? parent) {
    _parent = parent;
    // When set to null, is more probably than this element is removed from tree
    if (DocxElements.instance.initializeByCompile && parent?.mounted == true) {
      init();
    }
  }

  DocxNode<T> get copy => this;

  DocxNode<T> copyWith({String? id, DocxNode<T>? parent}) => this;

  DocxNode? queryPath(List<int> path) {
    if ((child == null || child is! DocxNode) && path.isNotEmpty) return null;
    if (path.isEmpty) return this;
    if (child is DocxNode && path.first == 0) {
      return child!.cast<DocxNode>().queryPath(path.sublist(1));
    }
    if (child is DocxNode && path.first != 0) {
      return null;
    }

    final List<int> tempPath = <int>[...path];
    final List<DocxNode<dynamic>> cList = child!.cast<List<DocxNode>>();
    if (tempPath.first > cList.length) return null;
    DocxNode? cur = cList[tempPath.removeAt(0)];
    while (cur != null) {
      if (tempPath.isEmpty) break;

      if ((cur.child == null || cur.child is! DocxNode) && path.isNotEmpty) {
        return null;
      }
      if (cur.child is DocxNode && tempPath.first == 0) {
        tempPath.removeAt(0);
        cur = cur.child!.cast<DocxNode>().queryPath(tempPath);
        continue;
      }
      if (cur.child is DocxNode && tempPath.first != 0) {
        return null;
      }

      final List<DocxNode> t = cur.child.cast<List<DocxNode>>();
      if (tempPath.first > t.length) return null;
      cur = t[tempPath.removeAt(0)];
    }
    return cur;
  }

  List<int> get path {
    if (!mounted || parent == null) {
      return <int>[];
    }
    final List<int> indexes = [index];

    DocxNode? owner = parent;
    while (owner != null) {
      indexes.add(owner.index);
      owner = owner.parent;
    }

    return indexes;
  }

  @experimental
  dynamic query(String xpath) {}

  /// Notifies when a node changes its internal properties
  void didChangeConfigurations(
    DocxNode<T> prev,
    DocxNode<T> current,
  ) {}

  /// Whether this element is mounted in the tree.
  ///
  /// * During runtime works just checking if the parent is not null
  /// * During compilation time works checking if this elements is
  ///   mounted with its `DocxRoot` as its root point
  @mustCallSuper
  bool get mounted => parent != null;

  void markAsDirty() {
    CompilerLogger.root.config('[$runtimeType:$id]: marked as dirty');
    dirty = true;
  }

  //TODO: we should implement a way to add properties to avoid
  // using unnecessary string concatenation every time for every node
  dynamic debugProperties() {}

  @mustCallSuper
  void init() {
    if (!dirty) {
      CompilerLogger.root.debug(
        '$runtimeType:$id hit already initialized element',
      );
      return;
    }
    dirty = false;
    if (this is Widget || this is Builder) return;

    if (child is DocxNode && child!.cast<DocxNode>().parent != this) {
      child!.cast<DocxNode>().parent = this;
      CompilerLogger.root.debug(
        'Assigning '
        'parent for ${child!.cast<DocxNode>().runtimeType}:${child!.cast<DocxNode>().id} '
        '(${child!.cast<DocxNode>().depth})',
      );
    }
    if (child is List<DocxNode>) {
      int index = 0;
      final List<DocxNode<dynamic>> list = child!.cast<List<DocxNode>>();
      for (final DocxNode<dynamic> el in list) {
        if (el.parent == parent) {
          CompilerLogger.root.debug(
            'Skipping assign of'
            'parent for ${el.runtimeType}:${el.id} '
            '(${el.depth})',
          );
          index++;
          continue;
        }
        el
          ..parent = this
          ..index = index;
        index++;
        CompilerLogger.root.debug(
          'Assigning '
          'parent for ${el.runtimeType}:${el.id} '
          '(${el.depth})',
        );
      }
    }
  }

  void deactivate() {
    CompilerLogger.root.config(
      '[$runtimeType:$id:${path.length}]: deactivated and '
      'removed of the tree',
    );
    //TODO: ensure parent remove this element
    // parent = null;
    dirty = true;
  }

  /// Performs all the required stuff that need to be ready
  /// before the `build` pahase
  @experimental
  void perform() {
    CompilerLogger.root.config(
      '[$runtimeType:$id:${path.length}]: '
      'executing perform',
    );
  }

  List<XmlNode> buildXml();
  List<XmlNode> buildXmlStyle() => <XmlNode>[];

  List<DocxNode<T>> repeat(
    int times, {
    DocxNode<T>? Function(int index, DocxNode<T> element)? overrideCopy,
  }) {
    return List<DocxNode<T>>.generate(
      times,
      (int index) =>
          overrideCopy?.call(
            index,
            this,
          ) ??
          copy,
      growable: true,
    );
  }

  bool isChildOf<R extends DocxNode>() => getAncestorOfExactType<R>() != null;

  R? getAncestorOfExactType<R extends DocxNode<dynamic>>(
      [bool Function(R)? predicate]) {
    DocxNode? current = parent;

    if (current == null) {
      return null;
    }

    final indent = ' ' * (depth / 2).round();
    CompilerLogger.root.debug('$runtimeType:$id:$depth will try to ');
    CompilerLogger.root.debug(
      '$indent | search ancestor '
      'of type $R',
    );

    if (current is R && (predicate?.call(current) ?? true)) {
      CompilerLogger.root.debug(
        '$indent${this is InheritedNode ? '' : ' ' * depth} |_ $R found at ${current.depth}',
      );

      return current;
    }

    int countTries = 0;
    String lastId = current.id;
    int loopTraverse = 0;
    while (current != null) {
      if (current is R && (predicate?.call(current) ?? true)) {
        CompilerLogger.root.debug(
          '$indent |_ $R found at ${current.depth}',
        );
        return current;
      }

      if (loopTraverse > 0 && lastId == current.id) {
        CompilerLogger.root.debug(
          '$indent | Hit element id again. Count: $countTries -> ${countTries + 1}',
        );
        countTries++;
      } else {
        lastId = current.id;
      }

      // Since at some points we could
      // have an infinite loop
      // we made these conditions to allow
      // hitting always in nodes that are being
      // repeated every time
      if (countTries > 3) {
        CompilerLogger.root.debug(
          '$indent |_ Hit element ${current.runtimeType} '
          'with id $id too many times. '
          'Breaking loop...',
        );
        return null;
      }
      loopTraverse++;
      current = current.parent;
    }
    CompilerLogger.root.debug('$indent |_ $R was not found');
    return null;
  }

  @mustCallSuper
  Map<String, dynamic>? toJson() {
    return DocxRegistry().toJson(this);
  }

  static DocxNode? fromJson(
    Map<String, dynamic> map, {
    Map<String, dynamic>? metadata,
  }) {
    return DocxRegistry().fromJson(
      map,
      metadata: metadata,
    );
  }

  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });

  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });

  String dumpTree({String? suffix}) {
    if (parent == null) {
      return '$runtimeType:$id';
    }

    final StringBuffer buffer = StringBuffer();
    final DocxNode<T> node = this;
    final List<DocxNode> ancestors = [];

    DocxNode? current = node;
    while (current != null) {
      ancestors.add(current);
      current = current.parent;
    }

    ancestors.reversed.toList().asMap().forEach((index, ancestor) {
      final isLast = index == ancestors.length - 1;
      final prefix = index == 0 ? '' : (isLast ? '└─ ' : '├─ ');
      buffer.write('$prefix${ancestor.runtimeType}:${ancestor.id}');
      if (ancestor.id == id && suffix != null) {
        buffer.write(' $suffix');
      }
      if (index < ancestors.length - 1) {
        buffer
          ..write('\n')
          ..write(' ' * (index + 1));
      }
    });

    return buffer.toString();
  }

  //TODO: we need to implement correctly this for all components
  @override
  bool operator ==(Object other) {
    if (other is! DocxNode) return false;
    return runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => Object.hashAll(
        [
          id,
          child.hashCode,
          index,
          length,
        ],
      );
}
