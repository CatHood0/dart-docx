mixin LocalizableComponentMixin {
  List<int> path();
  int get depth;

  ComponentRange range();
}

class ComponentRange {
  ComponentRange({
    required this.start,
    required this.end,
  });

  final int start;
  final int end;
}
