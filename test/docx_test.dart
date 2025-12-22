import 'dart:io';
import 'package:docx/docx.dart';
import 'package:docx/src/docx_sdk/packer/docx_metadata_packer.dart';
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
    final DocxMetadataPacker parser = DocxMetadataPacker();
    final File docPathFile = File('test_resources/minimal_document.docx');
    parser
        .bytes(
      DocxDocument(
        options: DocumentOptions.blank(
          title: 'document',
          orientation: Orientation.landscape,
          styles: DocumentStylesSheet.kDefaultDocumentStyleSheet.withNewStyles(
            <Style>[
              StyleBuilder.character('code')
                  .name('Inline Code')
                  .fontFamily('Courier New')
                  .highlight('D3D3D3')
                  .build(),
            ],
          ),
        ),
        sections: <DocxContent<dynamic>>[
          Paragraph(
            data: <RunBase<dynamic>>[
              TextRun(
                data: TextPart(text: ' your can use'),
              ),
              HyperlinkRun(
                data: HyperlinkTextPart(
                  hyperlink: 'https://pub.dev/packages/docx_transformer',
                  text: ' so, what is this link?',
                  styles: <Object>[
                    Style.reference('Hyperlink'),
                  ],
                ),
              ),
              TextRun(
                data: TextPart(
                  text: ' your can use',
                  styles: <Object>[
                    Style.reference('code'),
                    BoldAttribute(),
                  ],
                ),
              ),
            ],
            styles: <Style>[],
            pageBreak: ParagraphPagebreak.after,
            numbering: Numbering(
              reference: 'unordered',
              level: 0,
            ),
          ),
          ColumnBreak(),
          Paragraph(
            data: <RunBase<dynamic>>[
              TextRun(
                data: TextPart(text: 'Yeah, we are in a 2nd page'),
              ),
              HyperlinkRun(
                data: HyperlinkTextPart(
                  hyperlink: 'https://pub.dev/packages/docx_transformer',
                  text: ' and now, can we do about?',
                  styles: [
                    Style.reference('Hyperlink'),
                  ],
                ),
              ),
            ],
          ),
          TextFrame(
            data: <DocxContent<dynamic>>[
              TextRun(
                data: TextPart(
                  text: '',
                ),
              ),
            ],
            border: StyleBuilder.singularP()
                .borders(
                  leftColor: '#0000FF',
                  rightColor: '#FFFF00',
                  left: BorderStyle.dashDotStroked,
                  right: BorderStyle.dashDotStroked,
                )
                .build(),
            width: 500,
            height: 500,
            xAlign: FrameHorizontalAlignment.left,
            // general text will be wrapped around this frame
            wrap: FrameWrap.square,
            // pinned horizontally
            hAnchor: FrameAnchor.page,
            // pinned vertically
            vAnchor: FrameAnchor.page,
            // put to top
            yAlign: FrameVerticalAlignment.top,
          ),
          LazyImage(
            data: ImageData(
              buffer: File('test_resources/logo.jpg'),
              extension: 'jpg',
            ),
          ),
        ],
      ),
    )
        .then((bytes) {
      assert(bytes != null, 'bytes should not be null');
      docPathFile.writeAsBytes(bytes!);
    });
  });

  test('Should create a minimal DocxDocument', () async {
    final PlainTextToDocx parser = PlainTextToDocx(
      options: BasicParserOptions(
        documentOptions: DocumentOptions.blank(
          title: 'title',
        ),
      ),
    );
    final List<int> bytes = await parser.build(
      data: 'Hello world about\nmy changed world\n\nYeah this is break',
    );
    final File docPathFile = File('test_resources/plain_document.docx');
    await docPathFile.writeAsBytes(bytes);
  });
}
