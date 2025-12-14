part of 'docx_event.dart';

class EndEvent extends DocxEvent {
  const EndEvent({this.result, this.error});
  final List<int>? result;
  final Object? error;

  @override
  String toString() => error != null
      ? 'EndEvent: Failed with error: $error'
      : 'EndEvent: Document creation finished.';
}
