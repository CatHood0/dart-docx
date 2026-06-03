part of 'docx_event.dart';

class ProgressEvent extends DocxEvent {
  const ProgressEvent({
    required this.subject,
    required this.current,
    required this.total,
  });
  final String subject;
  final int current;
  final int total;
  @override
  String toString() => 'ProgressEvent: $subject - $current of $total';
}
