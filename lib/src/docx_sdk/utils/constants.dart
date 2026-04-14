import 'package:uuid/v4.dart';

import '../../core/extensions/string_ext.dart';
import '../sdk.dart';

const UuidV4 uuidV4 = UuidV4();

const String noColor = '000000';
const String noVal = 'none';
const String kDefaultBorderColor = 'bf4f15';
const int commonBorderSize = 4;
const int commonBorderSpace = 6;

const int maxLineWidth = 20116800;

const int maxGeometryPathSize = 1000000;

/// 1 point = 6350 EMU
const int lineWidthEmuPerPoint = 6350;
const int lineSpacingPerInch = 240;
const int maxAlphaEmu = 100000;
const int degressTh = 60000;
const int emu = 9525; // 1 inch = 914400 EMUs
const int emuPerInch = 914400; // 1 inch = 914400 EMUs
const int emuPerCm = 360000; // 1 cm = 360000 EMUs
const int emuPerMm = 36000; // 1 mm = 36000 EMUs
const int emuPerPt = 12700; // 1 point = 12700 EMUs
const int emuPerTwip = 635; // 1 TWIP = 635 EMUs
// Constants for Twips (1/20th of a point, or 1/1440th of an inch)
const int twipsPerInch = 1440;
const int twipsPerCm = 567; // 2.54 cm per inch
const int twipsPerMm = 56; // 25.4 mm per inch
const int twipsPerPt = 20; // 1 point = 20 twips

/// Conversion factor: 1 cm = 567 dxa (should be)
// 1 inch = 72 points * 20 dxa/point
const int dxaPerInch = 1440;

/// example: 1 cm = 28.3465 pt = 28.3465 * 20 dxa = 566.93 dxa
const double dxaPerCm = 567;
const double dxaPerMm = dxaPerCm / 10;
const int ptPerInch = 72;
const double ptPerCm = 28.3465;
const double ptPerMm = 2.83465;
// 1 pixel (96 DPI) = 0.75 points
const double ptPerPixel = 0.75;

const int pixelsPerInch = 96;
const double pixelsPerCm = 37.7953;
const double pixelsPerMm = 3.77953;
// 1 point = 1.33333 pixels (96 DPI)
const double pixelsPerPt = 1.33333;
// (72 points/inch / 2.54 cm/inch) * 20 dxa/point
const int dxaPerPt = 20;
// users can change the dpi as they want
// so, they are responsible for their own
// errors
//NOTE: probably we can just put this as a constant
// and pass to DocumentOptions a dpi property to
// allow customization
int imageDpi = 96;

/// These are the default supported image file extensions in Word
///
/// _Some of the extensions are not fully supported on older versions of Word editor_
final Set<String> kDefaultAcceptedFileExtensions = Set.unmodifiable([
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

typedef UniqueNumericIdCreator = int Function();

//TODO: change these global vars to be part
// of the store pattern
int _uniqueNumId = 0;
int _abstractUniqueNumId = 0;
int _concreteUniqueNumId = 0;

void reloadIds() {
  _uniqueNumId = 0;
  _abstractUniqueNumId = 0;
  _concreteUniqueNumId = 0;
}

int abstractNumUniqueNumericIdGen() => ++_abstractUniqueNumId;

int concreteNumUniqueNumericIdGen() => ++_concreteUniqueNumId;

int docPropertiesUniqueNumericIdGen() => ++_uniqueNumId;

const String defaultFont = 'Times New Roman';
const int defaultFontSize = 22;
const String defaultLang = LanguageCodes.englishUS;

final String defaultOrderedListStyleType = LevelFormat.decimal.name;

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
const DocumentMargins kDefaultLandscapeMargins = DocumentMargins(
  top: 1800,
  right: 1440,
  bottom: 1800,
  left: 1440,
  header: 720,
  footer: 720,
  gutter: 0,
);

const DocumentMargins kDefaultPortraitMargins = DocumentMargins(
  top: 1440,
  right: 1800,
  bottom: 1440,
  left: 1800,
  header: 720,
  footer: 720,
  gutter: 0,
);

EditorMetadata defaultEditorMetadata({
  required String content,
}) =>
    EditorMetadata(
      docSecurity: 0,
      hyperlinksChanged: false,
      linksUpToDate: false,
      wordVersion: '16.0000',
      paragraphs: content.countParagraphs,
      lines: content.isEmpty ? 1 : content.countLines,
      characters: content.charsLength,
      charactersWithSpaces: content.charsWithoutSpaces,
      words: content.countWords,
      pages: 1,
    );
