import 'package:uuid/v4.dart';

import '../../core/extensions/string_ext.dart';
import '../sdk.dart';

const UuidV4 uuidV4 = UuidV4();

final Color noColor = Colors.black;
const String kDefaultFontFamily = 'Times new roman';
const String noVal = 'none';
const String kDefaultBorderColor = 'bf4f15';
const int commonBorderSize = 4;
const int commonBorderSpace = 6;

const int maxLineWidth = 20116800;

const int maxGeometryPathSize = 1000000;

// ============ BASE CONVERSION CONSTANTS ============
const double mmPerCm = 10.0;
const double cmPerMm = 0.1;
const double mmPerInch = 25.4;
const double cmPerInch = 2.54;

// Points (1 point = 1/72 inch)
const double mmPerPt = 25.4 / 72; // = 0.3527777777777778 mm
const double cmPerPt = 2.54 / 72; // = 0.03527777777777778 cm

// Twips (1 twip = 1/1440 inch)
const double mmPerTwip = 25.4 / 1440; // = 0.01763888888888889 mm ✅ CORREGIDO
const double cmPerTwip = 2.54 / 1440; // = 0.001763888888888889 cm ✅ CORREGIDO

// EMU (English Metric Unit)
const int lineWidthEmuPerPoint = 6350;
const int lineSpacingPerInch = 240;
const int maxAlphaEmu = 100000;
const int degressTh = 60000;
const int emuPerInch = 914400; // 1 inch = 914400 EMUs
const int emuPerCm = 360000;    // 1 cm = 360000 EMUs
const int emuPerMm = 36000;     // 1 mm = 36000 EMUs
const int emuPerPt = 12700;     // 1 point = 12700 EMUs
const int emuPerTwip = 635;     // 1 TWIP = 635 EMUs

// EMU inverse constants
const double mmPerEmu = 1 / emuPerMm;     // = 0.00002777777777777778 mm
const double cmPerEmu = 1 / emuPerCm;     // = 0.000002777777777777778 cm
const double inchPerEmu = 1 / emuPerInch; // = 0.0000010936132983377078 inches
const double ptPerEmu = 1 / emuPerPt;     // = 0.00007874015748031496 points
const double twipPerEmu = 1 / emuPerTwip; // = 0.0015748031496062992 twips

// Twips constants
const int twipsPerInch = 1440;
final int twipsPerCm = (1440 / 2.54).round(); // = 567 (rounded from 566.929)
final int twipsPerMm = (1440 / 25.4).round(); // = 57 (rounded from 56.693) ✅ CORREGIDO
const int twipsPerPt = 20; // 1 point = 20 twips

// DXA constants (1 DXA = 1/1440 inch, same as twip)
const int dxaPerInch = 1440;
const double dxaPerCm = 1440 / 2.54; // = 566.9291338582677 ✅ MORE PRECISE
const double dxaPerMm = dxaPerCm / 10; // = 56.69291338582677 ✅ MORE PRECISE
const int dxaPerPt = 20; // 1 point = 20 DXA

// Points constants
const int ptPerInch = 72;
const double ptPerCm = 72 / 2.54; // = 28.346456692913385 ✅ MORE PRECISE
const double ptPerMm = 72 / 25.4; // = 2.8346456692913386 ✅ MORE PRECISE

// Pixels constants (at 96 DPI)
const int pixelsPerInch = 96;
const double pixelsPerCm = 96 / 2.54; // = 37.79527559055118 ✅ MORE PRECISE
const double pixelsPerMm = 96 / 25.4; // = 3.779527559055118 ✅ MORE PRECISE
const double ptPerPixel = 72 / 96; // = 0.75 ✅ EXACT
const double pixelsPerPt = 96 / 72; // = 1.3333333333333333 ✅ EXACT

// Image DPI (can be modified by users)
// int imageDpi = 96;

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

const String defaultFont = 'Times New Roman';
const UnitValue defaultFontSize = Point(11);
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
const UnitValue kDefaultSpacing1 = Twip(240);
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
