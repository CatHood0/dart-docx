import '../../../docx_transformer.dart';
import 'style_builder.dart';

class EasyStyles {
  static Style get normal => StyleBuilder.paragraph('Normal')
      .name('Normal')
      .fontFamily('Times New Roman')
      .fontSize(12)
      .alignment(Alignment.left)
      .spacing(before: 0, after: 160)
      .lineSpacing(240)
      .lang('en-US')
      .qFormat(true)
      .build();

  static Style get listParagraph => StyleBuilder.paragraph('ListParagraph')
      .name('List  Paragraph')
      .basedOn('Normal')
      .indent(left: 720, hanging: 360)
      .build();

  static Style get defaultParagraphFont =>
      StyleBuilder.character('DefaultParagraphFont')
          .name('Default Paragraph Font')
          .defaultValue(true)
          .build();

  static Style get hyperlink => StyleBuilder.character('Hyperlink')
      .name('Hyperlink')
      .color('0563C1')
      .underline()
      .build();

  static Style get heading1 => StyleBuilder.paragraph('Heading1')
      .name('Heading 1')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(24)
      .bold()
      .spacing(before: 480)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(0)
      .uiPriority(9)
      .qFormat(true)
      .build();

  static Style get heading2 => StyleBuilder.paragraph('Heading2')
      .name('Heading 2')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(18)
      .bold()
      .spacing(before: 360, after: 80)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(1)
      .uiPriority(9)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading3 => StyleBuilder.paragraph('Heading3')
      .name('Heading 3')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(14)
      .bold()
      .spacing(before: 280, after: 80)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(2)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading4 => StyleBuilder.paragraph('Heading4')
      .name('Heading 4')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(12)
      .bold()
      .spacing(before: 240, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(3)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading5 => StyleBuilder.paragraph('Heading5')
      .name('Heading 5')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(12)
      .bold()
      .spacing(before: 220, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(4)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading6 => StyleBuilder.paragraph('Heading6')
      .name('Heading 6')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(10)
      .bold()
      .spacing(before: 200, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(5)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static List<Style> get standardDocumentStyles => <Style>[
        normal,
        listParagraph,
        defaultParagraphFont,
        hyperlink,
        heading1,
        heading2,
        heading3,
        heading4,
        heading5,
        heading6,
      ];
}
