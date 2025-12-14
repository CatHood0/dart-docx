sealed class ParserEvent<T> {
  const ParserEvent();
}

class StartEvent<T> extends ParserEvent<T> {
  StartEvent();
}

class ProgressEvent<T> extends ParserEvent<T> {
  ProgressEvent(
    this.progress,
    this.total,
  );
  final double progress;
  final int total;
}

class CompleteEvent<T> extends ParserEvent<T> {
  CompleteEvent(this.result);
  final T result;
}

class ErrorEvent<T> extends ParserEvent<T> {
  const ErrorEvent(
    this.errorMessage,
    this.exception,
  );

  final String errorMessage;
  final Object exception;
}
