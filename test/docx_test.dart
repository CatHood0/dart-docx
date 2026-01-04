import 'dart:io';
import 'package:docx/docx.dart';
import 'package:test/test.dart';

void main() {
  test('Should create a minimal DocxDocument and save it', () async {
    final DocxMetadataPacker parser = DocxMetadataPacker();
    final File docPathFile = File('test_resources/minimal_document.docx');
    parser
        .dynamicFontSearch(true)
        .bytes(
          applyCustomTheme: true,
          DocxDocument(
            options: DocumentOptions.blank(
              title: 'document',
              styles: DocumentStylesSheet.base().withNewStyles(
                <Style>[
                  StyleBuilder.character('code')
                      .name('Inline Code')
                      .fontFamily('Courier New')
                      .highlight('D3D3D3')
                      .build(),
                ],
              ),
            ),
            root: DocumentRoot(
              sections: <DocxTreeNode<dynamic>>[
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
                  data: <DocxTreeNode<dynamic>>[
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
                LazyFloatingImage(
                  data: ImageData(
                    buffer: File('test_resources/logo.jpg'),
                    extension: 'jpg',
                  ),
                ),
              ],
            ),
          ),
        )
        .then((bytes) {
      assert(bytes != null, 'bytes should not be null');
      docPathFile.writeAsBytes(bytes!);
    });
  });
}
