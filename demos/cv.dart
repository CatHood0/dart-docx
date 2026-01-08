import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

/// Simple demo that generates a minimal CV as a .docx file.
Future<void> main() async {
  final File outFile = File('test_resources/cv.docx');

  final PageSettings pageSize = PageSettings.a4;
  const DocumentMargins margins = kDefaultPortraitMargins;
  final num widthHorizontal =
      pageSize.width.toEmuFromDxa() - (margins.left + margins.right);
  final num heightHorizontal = 200.toEmuFromPoints();
  final num widthVertical = 200.toEmuFromPoints();
  final num heightVertical =
      pageSize.height.toEmuFromDxa() - (margins.bottom + margins.top);
  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'Curriculum - Jane Doe',
      pageSize: pageSize,
      margins: margins,
      styles: DocumentStylesSheet.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('Name')
              .fontFamily('Times New Roman')
              .fontSize(24)
              .bold()
              .alignment(Alignment.center)
              .build(),
          StyleBuilder.paragraph('SectionHeading')
              .fontSize(14)
              .bold()
              .spacing(after: 200)
              .build(),
        ],
      ),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Paragraph(
          data: <RunBase<dynamic>>[
            Run(
              wrapInRunMark: true,
              component: DrawingML(
                data: Anchor(
                  widthEmu: widthVertical,
                  heightEmu: heightVertical,
                  name: 'vertical rectangle',
                  config: AnchorConfig.square(
                    side: WrapSide.right,
                    locked: false
                  ).copyWith(
                    zOrder: 0,
                    horizontalAnchor: HorizontalAnchorPosition.page,
                    verticalAnchor: VerticalAnchorPosition.page,
                    horizontalPosition: AnchorPosition.center,
                    verticalPosition: AnchorPosition.center,
                  ),
                  component: Graphic(
                    data: GraphicData(
                      uri: namespaces['pic']!,
                      data: WordprocessingShape(
                        name: 'vertical rectangle',
                        shapeProperties: ShapeProperties(
                          transform2D: Transform2D(
                            offset: Offset.zero(),
                            extents: AnnotationExtents(
                              cx: widthVertical,
                              cy: heightVertical,
                            ),
                          ),
                          geometryComponent: PresetGeometry(
                            preset: PresetShapeType.rectangle,
                          ),
                          fill: SolidFill(
                            data: Color.rgb(
                              0xFF0066,
                              0.10.toAlphaUnit(),
                            ),
                          ),
                        ),
                        textBox: ShapeTextBox(
                          data: ShapeTextBoxData(
                            content: <DocxTreeNode<dynamic>>[
                              Paragraph(
                                data: <RunBase<dynamic>>[
                                  Run(
                                    component: DrawingML(
                                      data: FloatingImage(
                                        data: ImageData(
                                          buffer:
                                              await File('assets/cv_person.png')
                                                  .readAsBytes(),
                                          extension: 'png',
                                          anchorConfig: AnchorConfig(
                                            wrapType: WrapType.noWrap,
                                            wrapSide: null,
                                            anchorOffsetX:
                                                0.5.toEmuFromInches(),
                                            anchorOffsetY: 0,
                                            horizontalAnchor:
                                                HorizontalAnchorPosition
                                                    .paragraph,
                                            verticalAnchor:
                                                VerticalAnchorPosition
                                                    .paragraph,
                                            horizontalPosition:
                                                AnchorPosition.left,
                                            verticalPosition:
                                                AnchorPosition.top,
                                          ),
                                          width: 1.toEmuFromInches(),
                                          height: 1.toEmuFromInches(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Paragraph(
                                data: <RunBase<dynamic>>[
                                  TextRun(
                                    data: TextPart(
                                      text: 'Jane Doe',
                                      styles: <Object>[
                                        Style.reference('Name'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Paragraph(
                                data: <RunBase<dynamic>>[
                                  TextRun(
                                    data: TextPart(
                                        text: 'Email: jane.doe@example.com '
                                            '• Phone: +1 234 567 890'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ColumnBreak(),
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text: 'Experience',
                styles: <Object>[
                  Style.reference(
                    'SectionHeading',
                  ),
                ],
              ),
            ),
          ],
        ),
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text: '• Senior Engineer at Acme '
                    'Corp (2018 - Present)',
              ),
            ),
            Run(component: Break.lineBreak(), wrapInRunMark: true),
            TextRun(
              data: TextPart(
                  text: '• Software Developer at '
                      'Example Inc. (2015 - 2018)'),
            ),
          ],
        ),
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text: 'Education',
                styles: <Object>[
                  Style.reference('SectionHeading'),
                ],
              ),
            ),
          ],
        ),
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text: 'M.Sc. Computer Science — '
                    'University of Examples (2013 - 2015)',
              ),
            ),
            Run(component: Break.lineBreak(), wrapInRunMark: true),
            TextRun(
              data: TextPart(
                text: 'B.Sc. Computer Science — '
                    'College of Samples (2009 - 2013)',
              ),
            ),
          ],
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxMetadataPacker()
      .dynamicFontSearch(true)
      .bytes(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate CV .docx');
  }
}
