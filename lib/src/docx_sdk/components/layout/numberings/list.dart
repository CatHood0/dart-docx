import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';

//TODO: we should have a way to define a stuff like the DocumentStyles but for Numberings
// to allow reusing constants to avoid magic strings
/// Represent a more easy version that manages all stuff related with the references and ids
//TODO: i think that numbering store does not know about NumberingList and requires a
// fix to allow making more simple get the NumberingOption configured
//TODO: yeah, the store does not know about NumberingList
class NumberingList extends DocxNode<List<DocxNode>> {
  NumberingList({
    required this.refKey,
    required List<DocxNode> children,
    super.id,
    super.parent,
  })  : inheritFromParent = false,
        assert(refKey.isNotEmpty, 'listKey must not be empty'),
        assert(
            children.every((DocxNode<dynamic> e) =>
                e is Text ||
                e is Paragraph ||
                e is NumberingList ||
                e is Builder<NumberingList> ||
                e is RunBase && e is! Run),
            'all the '
            'children for NumberingList must '
            'be Paragraph or Text objects'),
        super(child: List.from(children)) {
    int index = 0;
    for (final DocxNode<dynamic> c in child) {
      length += c.length;
      c
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  NumberingList.one({
    required this.refKey,
    required DocxNode child,
    super.id,
    super.parent,
  })  : inheritFromParent = false,
        assert(refKey.isNotEmpty, 'listKey must not be empty'),
        assert(
            child is Text ||
                child is Paragraph ||
                child is NumberingList ||
                child is RunBase && child is! Run,
            'all the '
            'children for NumberingList must '
            'be Paragraph or Text objects'),
        super(child: List.from(<DocxNode>[child])) {
    int index = 0;
    for (final DocxNode<dynamic> c in this.child) {
      length += c.length;
      c
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  NumberingList.inheritOne({
    required DocxNode child,
    super.id,
    super.parent,
  })  : refKey = '',
        inheritFromParent = true,
        assert(
            child is Text ||
                child is Paragraph ||
                child is NumberingList ||
                child is RunBase && child is! Run,
            'all the '
            'children for NumberingList must '
            'be Paragraph or Text objects'),
        super(child: List.from(<DocxNode>[child])) {
    int index = 0;
    for (final DocxNode<dynamic> c in this.child) {
      length += c.length;
      c
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  @internal
  NumberingList.raw({
    required this.refKey,
    required this.inheritFromParent,
    required List<DocxNode> children,
    super.id,
    super.parent,
  })  : assert(inheritFromParent || !inheritFromParent && refKey.isNotEmpty,
            'listKey must not be empty'),
        assert(
            children.every((DocxNode<dynamic> e) =>
                e is Text ||
                e is Paragraph ||
                e is NumberingList ||
                e is RunBase && e is! Run),
            'all the '
            'children for NumberingList must '
            'be Paragraph or Text objects'),
        super(child: List.from(children)) {
    int index = 0;
    for (final DocxNode<dynamic> c in child) {
      length += c.length;
      c
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  NumberingList.inherit({
    required List<DocxNode> children,
    super.id,
    super.parent,
  })  : refKey = '',
        inheritFromParent = true,
        assert(
            children.every((DocxNode<dynamic> e) =>
                e is Text ||
                e is Paragraph ||
                e is NumberingList ||
                e is RunBase && e is! Run),
            'all the '
            'children for NumberingList must '
            'be Paragraph or Text objects'),
        super(child: List.from(children)) {
    int index = 0;
    for (final DocxNode<dynamic> c in child) {
      length += c.length;
      c
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  /// The id of the NumberingOption that we are referencing
  final String refKey;
  final bool inheritFromParent;

  static final Map<String, int> _lastNumberingIds = <String, int>{};
  static final Style listStyleRef = Style.ref('ListParagraph');

  static void clearReferences() {
    _lastNumberingIds.clear();
  }

  final List<DocxNode> _temp = <DocxNode<dynamic>>[];

  int getRefId() {
    // perfom was not executed
    if (_temp.isEmpty || inheritFromParent || refKey.isEmpty) return -1;
    // lastNumberingIds = { "unordered": 1, "ordered": 3, "bullet": 10 }
    return _lastNumberingIds[refKey]!;
  }

  @override
  void perform() {
    String key = refKey;

    int level = 0;
    int refId = 0;

    CompilerLogger.root.debug('Start perfom initialization');
    NumberingList? ownerList = getAncestorOfExactType<NumberingList>();
    NumberingList? lastOwner = ownerList;

    while (ownerList != null) {
      CompilerLogger.root.debug(
        'Increasing '
        'level ($level -> ${level + 1}) of '
        'depth for list "$id"',
      );
      level++;
      lastOwner = ownerList;
      ownerList = ownerList.getAncestorOfExactType<NumberingList>();
    }

    if (lastOwner == null && inheritFromParent) {
      throw Exception(
        'Not found parent $runtimeType for '
        '$runtimeType:$id at $depth when '
        'was specified that will inherited key from parent. '
        'Please, ensure that you only use $runtimeType.inherit() '
        'when you know that your element is wrapped into another $runtimeType',
      );
    }

    key = inheritFromParent ? lastOwner!.refKey : refKey;
    CompilerLogger.root.info(
        'Decided Key: $key${lastOwner != null ? ' (Nested)' : ''} => Numbering Map: $_lastNumberingIds');

    // nested lists uses the same refId
    _lastNumberingIds[key] = lastOwner != null
        ? _lastNumberingIds[key] ?? (refId + 1)
        : (_lastNumberingIds[key] ?? refId) + 1;
    // Since every refId is start in a different point when the
    // key is different, then we use this to allow sharing correctly
    // the count
    //
    // Example:
    //
    // lastNumberingIds = { "unordered": 1, "ordered": 3, "bullet": 10 }
    refId = _lastNumberingIds[key]!;

    if (mounted && isChildOf<NumberingStoreProvider>()) {
      NumberingStoreProvider.of(this).registerConcreteInstance(
        key,
        refId,
        nodeId: id,
      );
    } else {
      CompilerLogger.root.debug(
        '$runtimeType:$id => Not found '
        'NumberingStoreProvider to register concrete instance '
        'of this list element',
      );
    }

    CompilerLogger.root.info('Numbering Map: $_lastNumberingIds');

    //TODO: ensure that DocumentStyles has this style
    for (DocxNode<dynamic> element in child) {
      CompilerLogger.root.debug(
        'Setting numbering for element ${element.runtimeType}:${element.id}',
      );
      if (element is Paragraph) {
        assert(
          element.numbering == null,
          'numbering should be NULL for $element:$id at ${element.depth} when it\'s in a $runtimeType',
        );
        _temp.add(
          element.copyWith(
            parent: this,
            styles: <Style>[...element.styles, listStyleRef],
            numbering: Numbering(
              level: level,
              refId: refId,
              reference: key,
            ),
          ),
        );
      } else if (element is RunBase) {
        _temp.add(
          element.paragraph(
            parent: this,
            styles: <Style>[listStyleRef],
            numbering: Numbering(
              level: level,
              refId: refId,
              reference: key,
            ),
          ),
        );
      } else if (element is Text) {
        final Paragraph pr = element.toParagraph();
        _temp.add(
          pr.copyWith(
            parent: this,
            styles: <Style>[listStyleRef],
            numbering: Numbering(
              level: level,
              refId: refId,
              reference: key,
            ),
          ),
        );
      } else if (element is Builder<NumberingList>) {
        _temp.add(element.build().copyWith(parent: this));
      } else {
        _temp.add(element.copyWith(parent: this));
      }
    }
  }

  @override
  List<XmlNode> buildXml() {
    List<XmlNode> nodes = <XmlNode>[];
    for (DocxNode<dynamic> e in _temp) {
      if (!e.mounted) {
        e;
      }
      if (e is Builder) {
        nodes.addAll(e.build().buildXml());
        continue;
      }
      nodes.addAll(e.buildXml());
    }
    return nodes;
  }

  @override
  NumberingList get copy => NumberingList(
        id: id,
        parent: parent,
        children: child,
        refKey: refKey,
      );

  @override
  NumberingList copyWith({
    List<DocxNode<dynamic>>? child,
    String? id,
    DocxNode<dynamic>? parent,
    String? refKey,
    bool? inheritFromParent,
  }) {
    return NumberingList.raw(
      id: id ?? this.id,
      parent: parent ?? this.parent,
      children: child ?? this.child,
      refKey: refKey ?? this.refKey,
      inheritFromParent: inheritFromParent ?? this.inheritFromParent,
    );
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final DocxNode<dynamic> element in child) {
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxNode? foundedEl = element.visitElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          return foundedEl;
        }
      }
    }
    return null;
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (child.isEmpty) return <DocxNode>[];
    final List<DocxNode> elements = <DocxNode>[];
    for (final DocxNode element in child) {
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxNode>? foundedEl = element.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          elements.addAll(foundedEl);
        }
      }
    }
    return elements;
  }
}
