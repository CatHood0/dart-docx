import '../../../docx.dart';
import '../styles_builder/easy_styles.dart';

class DefaultDocumentStyles {
  const DefaultDocumentStyles._();
  static DocumentStylesSheet get kDefaultDocumentStyleSheet =>
      //TODO: probably we will need to make a copy
      // of every style
      DocumentStylesSheet(
        styles: <Style>[...EasyStyles.standardDocumentStyles],
      );
}
