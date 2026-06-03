class LanguageCodes {
  const LanguageCodes._();
  //
  static const String spanishES = 'es-ES';
  static const String spanishMX = 'es-MX';
  static const String englishUS = 'en-US';
  static const String englishGB = 'en-GB';
  static const String frenchFR = 'fr-FR';
  static const String germanDE = 'de-DE';
  static const String portuguesePT = 'pt-PT';
  static const String italianIT = 'it-IT';

  // Asian
  static const String chineseCN = 'zh-CN'; // Simplified
  static const String chineseTW = 'zh-TW'; // Traditional
  static const String japaneseJP = 'ja-JP';
  static const String koreanKR = 'ko-KR';

  // Arabic
  static const String arabicSA = 'ar-SA';
  static const String hebrewIL = 'he-IL';
  static const String persianIR = 'fa-IR';

  static List<String> get languages => [
        englishGB,
        englishUS,
        spanishES,
        spanishMX,
        frenchFR,
        germanDE,
        italianIT,
        chineseCN,
        chineseTW,
        japaneseJP,
        koreanKR,
        portuguesePT,
        arabicSA,
        hebrewIL,
        persianIR,
      ];

  static bool isValid(String code) {
    return RegExp(r'^[a-z]{2}-[A-Z]{2}$').hasMatch(code);
  }
}
