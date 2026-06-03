/// Defines the numbering format for list levels in Word documents.
///
/// Each format determines how the number appears (e.g., "1", "I", "a", "First").
/// The actual appearance may vary slightly depending on the language version of Word.
enum LevelFormat {
  /// Standard decimal numbers: 1, 2, 3, ..., 10, 11, 12
  ///
  /// Example: 1. First item
  ///         2. Second item
  decimal,

  /// Uppercase Roman numerals: I, II, III, IV, V
  ///
  /// Example: I. First item
  ///         II. Second item
  ///         III. Third item
  upperRoman,

  /// Lowercase Roman numerals: i, ii, iii, iv, v
  ///
  /// Example: i. First item
  ///         ii. Second item
  ///         iii. Third item
  lowerRoman,

  /// Uppercase letters: A, B, C, ..., Z, AA, AB
  ///
  /// Example: A. First item
  ///         B. Second item
  ///         C. Third item
  upperLetter,

  /// Lowercase letters: a, b, c, ..., z, aa, ab
  ///
  /// Example: a. First item
  ///         b. Second item
  ///         c. Third item
  lowerLetter,

  /// Ordinal numbers: 1st, 2nd, 3rd, 4th, 5th
  ///
  /// Example: 1st First item
  ///         2nd Second item
  ///         3rd Third item
  ordinal,

  /// Cardinal text numbers: One, Two, Three, Four, Five
  ///
  /// Example: One. First item
  ///         Two. Second item
  ///         Three. Third item
  cardinalText,

  /// Ordinal text numbers: First, Second, Third, Fourth, Fifth
  ///
  /// Example: First. First item
  ///         Second. Second item
  ///         Third. Third item
  ordinalText,

  /// Hexadecimal numbers: 1, 2, 3, ..., A, B, C, ..., 10, 11
  ///
  /// Example: 1. First item
  ///         2. Second item
  ///         A. Tenth item
  hex,

  /// Chicago Manual of Style formatting: 1, 2, 3, ...
  ///
  /// Example: 1. First item
  ///         2. Second item
  chicago,

  // Most of these options require Word having support for CJK, 
  // Chinese and Korean

  /// Ideograph digital (dbnum1): 一, 二, 三, 四, 五
  ///
  /// Used for Chinese/Japanese documents. Characters represent numbers.
  /// Example: 一. First item
  ///         二. Second item
  ideographDigital,

  /// Japanese counting (dbnum2): 1, 2, 3 with Japanese style
  ///
  /// Example: 1. First item
  ///         2. Second item
  japaneseCounting,

  /// Japanese AIUEO order (aiueo): あ, い, う, え, お
  ///
  /// Uses Japanese phonetic katakana characters in "aiueo" order.
  /// Example: あ. First item
  ///         い. Second item
  ///         う. Third item
  aeiou,

  /// Japanese IROHA order (iroha): い, ろ, は, に, ほ
  ///
  /// Uses Japanese phonetic katakana characters in traditional "iroha" order.
  /// Example: い. First item
  ///         ろ. Second item
  ///         は. Third item
  iroha,

  /// Full-width decimal numbers: １, ２, ３, ４, ５
  ///
  /// Uses double-byte (full-width) digit characters.
  /// Example: １. First item
  ///         ２. Second item
  decimalFullWidth,

  /// Half-width decimal numbers: 1, 2, 3, 4, 5
  ///
  /// Standard ASCII digits, distinct from full-width variants.
  /// Example: 1. First item
  ///         2. Second item
  decimalHalfWidth,

  /// Japanese legal numbering (dbnum3): 壱, 弐, 参, 肆, 伍
  ///
  /// Uses formal/legal Kanji characters (prevents alteration).
  /// Example: 壱. First item
  ///         弐. Second item
  japaneseLegal,

  /// Japanese digital ten-thousand (dbnum4): 一, 二, 三, 四, 五
  ///
  /// Alternative Kanji numbering style.
  japaneseDigitalTenThousand,

  /// Circled decimal numbers: ①, ②, ③, ④, ⑤
  ///
  /// Digits enclosed in circles. Commonly used in East Asian documents.
  /// Example: ①. First item
  ///         ②. Second item
  decimalEnclosedCircle,

  /// Full-width decimal variant 2
  decimalFullWidth2,

  /// Full-width AIUEO order: あ, い, う, え, お (double-byte)
  ///
  /// Like aeiou but with full-width characters.
  aiueoFullWidth,

  /// Full-width IROHA order: い, ろ, は, に, ほ (double-byte)
  ///
  /// Like iroha but with full-width characters.
  irohaFullWidth,

  /// Decimal numbers with leading zero: 01, 02, 03, ..., 10, 11
  ///
  /// Example: 01. First item
  ///         02. Second item
  decimalZero,

  /// Bullet character (•) - no sequential number
  ///
  /// Example: • First item
  ///         • Second item
  bullet,

  /// Korean Ganada order: 가, 나, 다, 라, 마
  ///
  /// Uses Korean Hangul characters in Ganada sequence order.
  /// Example: 가. First item
  ///         나. Second item
  ganada,

  /// Korean Chosung order: ㄱ, ㄴ, ㄷ, ㄹ, ㅁ
  ///
  /// Uses Korean Hangul initial consonants (Jamo) order.
  /// Example: ㄱ. First item
  ///         ㄴ. Second item
  chosung,

  /// Decimal number followed by full stop: 1., 2., 3.
  ///
  /// Example: 1. First item
  ///         2. Second item
  decimalEnclosedFullstop,

  /// Decimal number enclosed in parentheses: (1), (2), (3)
  ///
  /// Example: (1) First item
  ///         (2) Second item
  decimalEnclosedParen,

  /// Circled Chinese numbers: ①, ②, ③ (Chinese style)
  ///
  /// Similar to decimalEnclosedCircle but with Chinese typography.
  decimalEnclosedCircleChinese,

  /// Circled ideographs: 一, 二, 三 inside circles
  ///
  /// Example: ① (representing 一)
  ideographEnclosedCircle,

  /// Traditional Chinese ideographs: 壹, 貳, 參, 肆, 伍
  ///
  /// Formal/legal style Chinese numbers.
  ideographTraditional,

  /// Chinese Zodiac ideographs: 子, 丑, 寅, 卯, 辰
  ///
  /// Uses Earthly Branches (zodiac) characters.
  ideographZodiac,

  /// Traditional Chinese Zodiac ideographs (formal style)
  ideographZodiacTraditional,

  /// Taiwanese counting: 甲, 乙, 丙, 丁, 戊
  ///
  /// Uses Heavenly Stems (Tien-Kan) characters.
  /// Example: 甲. First item
  ///         乙. Second item
  taiwaneseCounting,

  /// Traditional Chinese legal ideographs: 壹, 貳, 參, 肆
  ///
  /// Formal numbers used in legal/financial documents.
  ideographLegalTraditional,

  /// Taiwanese counting thousand: 萬, 億, 兆, 京
  taiwaneseCountingThousand,

  /// Taiwanese digital format
  taiwaneseDigital,

  /// Simplified Chinese counting: 一, 二, 三, 四, 五
  ///
  /// Standard Simplified Chinese numbers.
  chineseCounting,

  /// Simplified Chinese legal format: 壹, 贰, 叁, 肆, 伍
  ///
  /// Simplified Chinese characters for legal documents.
  chineseLegalSimplified,

  /// Chinese counting thousand: 万, 亿, 兆, 京
  chineseCountingThousand,

  /// Korean digital: 1, 2, 3 (Korean-specific styling)
  koreanDigital,

  /// Korean counting: 일, 이, 삼, 사, 오
  ///
  /// Korean Hangul number names.
  /// Example: 일. First item
  ///         이. Second item
  koreanCounting,

  /// Korean legal format (formal document style)
  koreanLegal,

  /// Korean digital variant 2
  koreanDigital2,

  /// Vietnamese counting: Một, Hai, Ba, Bốn, Năm
  ///
  /// Vietnamese language cardinal numbers.
  vietnameseCounting,

  /// Lowercase Russian alphabet: а, б, в, г, д
  ///
  /// Example: а. First item
  ///         б. Second item
  russianLower,

  /// Uppercase Russian alphabet: А, Б, В, Г, Д
  ///
  /// Example: А. First item
  ///         Б. Second item
  russianUpper,

  /// No number or bullet - empty prefix
  ///
  /// Useful when you want no visible numbering but need list structure.
  none,

  /// Number with dashes: -1-, -2-, -3-
  ///
  /// Example: -1- First item
  ///         -2- Second item
  numberInDash,

  /// Hebrew numbering (non-standard decimal)
  hebrew1,

  /// Hebrew Biblical standard: א, ב, ג, ד, ה
  ///
  /// Uses Hebrew letters as numbers (Aleph, Bet, Gimel, etc.).
  /// Example: א. First item
  ///         ב. Second item
  hebrew2,

  /// Arabic Alif Ba Tah order: أ, ب, ت, ث, ج
  ///
  /// Uses Arabic letters in Alif-Ba-Ta order.
  arabicAlpha,

  /// Arabic Abjad style: ا, ب, ج, د, ه
  ///
  /// Traditional Abjad ordering of Arabic letters.
  arabicAbjad,

  /// Hindi vowels: अ, आ, इ, ई, उ
  ///
  /// Devanagari vowel characters.
  hindiVowels,

  /// Hindi consonants: क, ख, ग, घ, ङ
  ///
  /// Devanagari consonant characters.
  hindiConsonants,

  /// Hindi numbers: १, २, ३, ४, ५
  ///
  /// Devanagari digit characters.
  hindiNumbers,

  /// Hindi descriptive cardinals: एक, दो, तीन, चार
  ///
  /// Hindi language number names.
  hindiCounting,

  /// Thai letters: ก, ข, ค, ง, จ
  ///
  /// Thai alphabet characters in order.
  thaiLetters,

  /// Thai numbers: ๑, ๒, ๓, ๔, ๕
  ///
  /// Thai digit characters.
  thaiNumbers,

  /// Thai descriptive cardinals: หนึ่ง, สอง, สาม, สี่
  thaiCounting,

  /// Thai Baht text: บาท
  ///
  /// Currency format for Thai Baht.
  bahtText,

  /// US Dollar text: $
  ///
  /// Currency format for US Dollars.
  dollarText,

  /// User-defined custom format
  ///
  /// When using this, you must provide your own numbering definition.
  /// The exact format depends on the custom numbering implementation.
  custom,
}
