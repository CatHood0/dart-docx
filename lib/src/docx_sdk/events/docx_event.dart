part 'docx_start_event.dart';
part 'docx_searching_event.dart';
part 'docx_media_processed_event.dart';
part 'docx_progress_event.dart';
part 'docx_end_event.dart';
part 'docx_unknown_progress.dart';

sealed class DocxEvent {
  const DocxEvent();

  factory DocxEvent.start() = StartEvent;

  factory DocxEvent.searching({
    required String subject,
  }) = SearchingEvent;

  factory DocxEvent.mediaProcessed({
    required String name,
    required String type,
  }) = MediaProcessedEvent;

  factory DocxEvent.unknownProgress({
    required String subject,
  }) = UnknownProgress;

  factory DocxEvent.progress({
    required String subject,
    required int current,
    required int total,
  }) = ProgressEvent;

  factory DocxEvent.end({
    Object? result,
    Object? error,
  }) = EndEvent;
}
