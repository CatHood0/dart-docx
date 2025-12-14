import '../../core/extensions/string_ext.dart';
import '../sdk.dart';

const String noColor = '000000';
const String noVal = 'none';
const String kDefaultBorderColor = 'bf4f15';
const int commonBorderSize = 4;
const int commonBorderSpace = 6;

/// These are the default supported image file extensions in Word
///
/// _Some of the extensions are not fully supported on older versions of Word editor_
final List<String> kDefaultAcceptedFileExtensions = List.unmodifiable([
  ...<String>['jpg', 'jpeg'],
  ...<String>['tiff', 'tif'],
  'png',
  'bmp',
  'gif',
  'svg',
  'emf',
  'wmf',
]);

/// This is a links pattern that helps us to validate if the input
/// has a hyperlink correct
///
/// ## Supports links like:
///
/// * http://www.google.com
/// * https://www.google.com
/// * www.google.com
/// * google.com
/// * http://localhost:8080
/// * https://sub.page.com/route/page.html
/// * https://page.com/search?q=regex
///
/// ## No valid links:
///
/// * google
/// * http://
/// * www.google
/// * ftp://dominio.com
final RegExp linkDetectorMatcher = RegExp(
  r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
  multiLine: false,
);

/// This is the twip value used by word to calculate some values
///
/// By default, to get the real value from word we need to make a operation like:
///
/// 345600 / 1440 => 240
///
/// and, when we will parse a value to word
/// we need to multiply it to pass the format that we expect
///
/// 240 * 1440 => 345600
const int kDefaultTwipsValue = 1440;

num computeTwip(
  num value, {
  bool toWord = true,
  int defaultTwipsValue = kDefaultTwipsValue,
}) {
  return toWord ? value * defaultTwipsValue : value / defaultTwipsValue;
}

const String defaultFont = 'Times New Roman';
const int defaultFontSize = 22;
const String defaultLang = 'en-US';

const String defaultOrderedListStyleType = 'decimal';

const Orientation defaultOrientation = Orientation.portrait;

/// Every `0.5` spacing, is equals to 120
/// it means, that `1.0` is equals to 240,
/// `1.5` is equals to 360, and etc
///
/// to get correct spacing to a value that we can understand
/// we can use a `formula` like:
///
/// _Note: "n" represents the value that we found in `w:line` attribute_
///
///```
/// lineSpacing = n / 240
///```
const double kDefaultSpacing1 = 240;
//const double kDefaultSpacing15 = 360;
//const double kDefaultSpacing2 = 400;
const DocumentMargins landscapeMargins = DocumentMargins(
  top: 1800,
  right: 1440,
  bottom: 1800,
  left: 1440,
  header: 720,
  footer: 720,
  gutter: 0,
);

const DocumentMargins portraitMargins = DocumentMargins(
  top: 1440,
  right: 1800,
  bottom: 1440,
  left: 1800,
  header: 720,
  footer: 720,
  gutter: 0,
);

DocumentOptions defaultDocumentProperties({
  required String title,
  String owner = '',
  String subject = '',
  String description = '',
  String lastModifiedBy = '',
  List<String> keywords = const <String>[],
  DocumentStylesSheet? styles,
  int revisions = 1,
}) =>
    DocumentOptions(
      title: title,
      owner: owner,
      subject: subject,
      description: description,
      lastModifiedBy: lastModifiedBy,
      modifiedAt: DateTime.now(),
      createdAt: DateTime.now(),
      keywords: keywords,
      styles: styles ?? DefaultDocumentStyles.kDefaultDocumentStyleSheet,
      revisions: 1,
      orientation: defaultOrientation,
      editorSettings: EditorOptions.standard(
        size: PageSettings.a4,
      ),
    );

EditorMetadata defaultEditorMetadata({
  required String content,
}) =>
    EditorMetadata(
      paragraphs: content.countParagraphs,
      lines: content.isEmpty ? 0 : content.countLines,
      characters: content.charsLength,
      charactersWithSpaces: content.charsWithoutSpaces,
      words: content.countWords,
      pages: 0,
    );
