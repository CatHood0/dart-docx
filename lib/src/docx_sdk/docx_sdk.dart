import 'dart:typed_data';

import '../../../docx.dart';
import 'docx_compiler.dart';
import 'events/docx_event.dart';

//TODO: add insert, delete, and replacement capabilities
class DocxSdk {
  DocxSdk({DocxDocument? object}) : lastDocumentObject = object;
  DocxDocument? lastDocumentObject;

  static final DocxCompiler compiler = DocxCompiler.instance;

  // to allow modifying certain parts of the docx result
  // we can implement these methods
  void insert(
    int start,
    Object data,
  ) {}
  void replace(
    int start,
    int end,
    Object data,
  ) {}
  void delete(
    int start,
    int end,
  ) {}

  Future<Uint8List?> toBytes(
    DocxDocument document, {
    required Set<String> supportedFileExtensions,
  }) async =>
      compiler.toBytes(
        document,
        supportedFileExtensions: supportedFileExtensions,
      );

  Stream<DocxEvent> toBytesWithEventStream(
    DocxDocument document, {
    required Set<String> supportedFileExtensions,
  }) =>
      compiler.toBytesWithEventStream(
        document,
        supportedFileExtensions: supportedFileExtensions,
      );

  Future<void> writeInFile(
    DocxDocument document, {
    required String filePath,
    required Set<String> supportedFileExtensions,
  }) =>
      compiler.writeToFile(
        document,
        filePath: filePath,
        supportedFileExtensions: supportedFileExtensions,
      );
}
