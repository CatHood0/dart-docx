import 'dart:io';
import 'package:docx/docx.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Should get Full Delta from a docx file', () async {
    // final File file = File('test_resources/document_docx.docx');
    // final DeltaFromDocxParser parser = DeltaFromDocxParser(
    //   options: DeltaParserOptions(
    //     shouldParserSizeToHeading: null,
    //     ignoreColorWhenNoSupported: true,
    //     onDetectImage: (Uint8List bytes, String name) async {
    //       return 'path/to/my_image_${nanoid(8)}';
    //     },
    //   ),
    // );
    //final Delta? delta = await parser.build(data: await file.readAsBytes());
    //debugPrint('Result: $delta');
  });

  test('Should create a minimal DocxDocument and save it', () async {
    final DocxDocumentSdk parser = DocxDocumentSdk(
      options: DocumentOptions.blank(
        title: 'documento',
        styles: DefaultDocumentStyles.kDefaultDocumentStyleSheet,
      ),
    );
    final File docPathFile = File('test_resources/minimal_document.docx');
    await parser.save(
      supportedFileExtensions: <String>{},
      filePath: docPathFile.path,
      DocxComponentContainer(
        contents: <ComponentContainer<dynamic>>[
          Paragraph(
            data: <TextRunBase<dynamic>>[
              TextRun(
                data: TextPart(text: ' your can use'),
              ),
              HyperlinkRun(
                data: HyperlinkTextPart(
                  hyperlink: 'https://pub.dev/packages/docx_transformer',
                  text: ' so, what is this link?',
                ),
                style: Style.reference(styleId: 'Hyperlink'),
              ),
              TextRun(
                data: TextPart(
                  text: ' your can use',
                  styles: <TextRunAttribution<dynamic>>[
                    BoldAttribute(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  });

  test('Should create a minimal DocxDocument', () async {
    final PlainTextToDocx parser = PlainTextToDocx(
      options: BasicParserOptions(title: 'title'),
    );
    final List<int> bytes = await parser.build(
      data: 'Hello world about\nmy changed world\n\nYeah this is break',
    );
    final File docPathFile = File('test_resources/plain_document.docx');
    await docPathFile.writeAsBytes(bytes);
  });
}
