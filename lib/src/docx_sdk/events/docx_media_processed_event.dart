part of 'docx_event.dart';
class MediaProcessedEvent extends DocxEvent {
  const MediaProcessedEvent({required this.name, required this.type});
  final String name;
  final String type;
  @override
  String toString() => 'MediaProcessedEvent: Processed $type: $name';
}
