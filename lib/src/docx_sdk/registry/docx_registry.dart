import '../../../docx.dart';
import '../../core/extensions/cast_ext.dart';

typedef MapCallback<T> = Map<String, dynamic> Function(T);
typedef FromMapCallback<T extends Object> = T Function(
    Map<String, dynamic>, Map<String, dynamic>?);

/// Global registry to get all instances to/from json objects
class DocxRegistry {
  factory DocxRegistry() => instance;

  const DocxRegistry._();

  static const DocxRegistry instance = DocxRegistry._();

  static final Map<String, MapCallback> toJsonRegistry =
      <String, MapCallback>{};

  static final Map<String, FromMapCallback<Object>> fromJsonRegistry =
      <String, FromMapCallback<Object>>{};

  Map<String, dynamic>? toJson(Object object) {
    return toJsonRegistry[object.runtimeType.toString()]?.call(object);
  }

  T? fromJson<T extends Object>(
    Map<String, dynamic> map, {
    Map<String, dynamic>? metadata,
  }) {
    final FromMapCallback<T>? callback =
        fromJsonRegistry[T.runtimeType.toString()]
            ?.castOrNull<FromMapCallback<T>>();
    if (callback == null) return null;
    return callback(map, metadata);
  }

  bool setToJson<T extends Object>(MapCallback<T> callback) {
    final MapCallback? prev =
        toJsonRegistry[T.runtimeType.toString()]?.castOrNull<MapCallback>();
    if (prev != null) return false;
    toJsonRegistry[T.runtimeType.toString()] = callback.cast();
    return true;
  }

  bool setFromJson<T extends Object>(FromMapCallback<T> callback) {
    final FromMapCallback? prev = fromJsonRegistry[T.runtimeType.toString()]
        ?.castOrNull<FromMapCallback>();
    if (prev != null) return false;
    fromJsonRegistry[T.runtimeType.toString()] = callback;
    return true;
  }

  static void setDefaultRegistries() {
    DocxRegistry()
      ..setToJson<TextRun>(
        (TextRun node) {
          return <String, dynamic>{};
        },
      )
      ..setToJson<Paragraph>(
        (Paragraph node) {
          return <String, dynamic>{
            'children': <Map<String, dynamic>>[
              ...node.child.map<Map<String, dynamic>>((
                RunBase<dynamic> e,
              ) =>
                  DocxRegistry().toJson(e)!),
            ],
            'align': node.alignment?.index,
            'textStyle': node.textStyle,
          };
        },
      );
    DocxRegistry().setFromJson<Paragraph>(
      (Map<String, dynamic> body, metadata) {
        return Paragraph(
          children: <RunBase<dynamic>>[
            ...?body['children']?.cast<Iterable<Map<String, dynamic>>>().map((
                  Map<String, dynamic> child,
                ) =>
                    DocxRegistry().fromJson(child)?.cast<RunBase>()),
          ],
          alignment: Alignment.values[body['align']],
          textStyle: body['textStyle'],
        );
      },
    );
  }
}
