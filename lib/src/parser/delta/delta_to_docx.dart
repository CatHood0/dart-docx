import 'dart:typed_data';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import '../../../docx.dart';
import '../../docx_sdk/components/root/document_root.dart';

class DeltaToDocx extends Parser<Delta, Uint8List?, DocxParserOptions> {
  DeltaToDocx({
    required super.options,
  });

  // we will transform all to a encoded file and returned as bytes to be
  // writted by the developer
  @override
  Future<Uint8List?> build({required Delta data}) async {
    // parse delta to a format that we can use easily
    // final Document? document = DocumentParser().parseDelta(delta: data);
    // final DocumentStylesSheet docStyles = options.documentProperties.docStyles;
    // if (document == null) {
    //   throw StateError(
    //       'The Delta passed is invalid to be transformed to a Word Document');
    // }
    return null;
  }

  DocxDocument deltaToComponents(Delta delta) {
    return DocxDocument(
      root: DocumentRoot(sections: <ComponentContainer<dynamic>>[]),
      options: options.documentProperties,
    );
  }
}
