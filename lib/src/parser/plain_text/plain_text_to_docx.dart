import 'dart:convert';

import '../../../docx.dart';
import '../parser_events.dart';

class PlainTextToDocx extends Parser<String, List<int>?, BasicParserOptions> {
  PlainTextToDocx({
    required super.options,
  })  : assert(options.properties != null, 'DocumentOptions cannot be null'),
        _sdk = DocxDocumentSdk(options: options.properties!);

  final DocxDocumentSdk _sdk;

  @override
  Future<List<int>> build({required String data}) async {
    emitEvent(StartEvent());
    final bytes = await _sdk.createDocument(
      DocxComponentContainer(
        contents: _documentContentBuilder(data: data).cast(),
      ),
      supportedFileExtensions: {},
    );
    emitEvent(CompleteEvent(bytes));
    return bytes!;
  }

  List<DocxContent> _documentContentBuilder({required String data}) {
    final List<String> lines = const LineSplitter().convert(data);
    final List<DocxContent> buffer = <DocxContent>[];
    for (final String text in lines) {
      buffer.add(
        Paragraph(
          data: [
            TextRun(data: TextPart(text: text)),
          ],
        ),
      );
    }
    return buffer;
  }
}
