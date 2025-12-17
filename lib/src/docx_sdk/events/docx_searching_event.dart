part of 'docx_event.dart';

class SearchingEvent extends DocxEvent {
  const SearchingEvent({required this.subject});
  final String subject;
  @override
  String toString() => 'SearchingEvent: $subject';
}
