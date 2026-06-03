import '../../../../../docx.dart';

/// Options for configuring a document theme (theme.xml).
class ThemeOptions {
  const ThemeOptions({
    required this.themeElements,
    this.name = 'Office Theme',
  });
  factory ThemeOptions.officeTheme({String font = defaultFont}) {
    // Default system colors
    const SysColorOptions windowText = SysColorOptions(
      val: SysColorValue.windowText,
      lastClr: '000000',
    );
    const SysColorOptions window = SysColorOptions(
      val: SysColorValue.window,
      lastClr: 'FFFFFF',
    );

    // Default sRGB colors
    const SrgbColorOptions dk2Srgb = SrgbColorOptions(val: '44546A');
    const SrgbColorOptions lt2Srgb = SrgbColorOptions(val: 'E7E6E6');
    const SrgbColorOptions accent1Srgb = SrgbColorOptions(val: '4472C4');
    const SrgbColorOptions accent2Srgb = SrgbColorOptions(val: 'ED7D31');
    const SrgbColorOptions accent3Srgb = SrgbColorOptions(val: 'A5A5A5');
    const SrgbColorOptions accent4Srgb = SrgbColorOptions(val: 'FFC000');
    const SrgbColorOptions accent5Srgb = SrgbColorOptions(val: '5B9BD5');
    const SrgbColorOptions accent6Srgb = SrgbColorOptions(val: '70AD47');
    const SrgbColorOptions hlinkSrgb = SrgbColorOptions(val: '0563C1');
    const SrgbColorOptions folHlinkSrgb = SrgbColorOptions(val: '954F72');

    // Color Scheme
    const ColorSchemeOptions clrScheme = ColorSchemeOptions(
      name: 'Office',
      dk1: ThemeColorOptions(xmlKey: 'a:dk1', sysClr: windowText),
      lt1: ThemeColorOptions(xmlKey: 'a:lt1', sysClr: window),
      dk2: ThemeColorOptions(xmlKey: 'a:dk2', srgbClr: dk2Srgb),
      lt2: ThemeColorOptions(xmlKey: 'a:lt2', srgbClr: lt2Srgb),
      accent1: ThemeColorOptions(xmlKey: 'a:accent1', srgbClr: accent1Srgb),
      accent2: ThemeColorOptions(xmlKey: 'a:accent2', srgbClr: accent2Srgb),
      accent3: ThemeColorOptions(xmlKey: 'a:accent3', srgbClr: accent3Srgb),
      accent4: ThemeColorOptions(xmlKey: 'a:accent4', srgbClr: accent4Srgb),
      accent5: ThemeColorOptions(xmlKey: 'a:accent5', srgbClr: accent5Srgb),
      accent6: ThemeColorOptions(xmlKey: 'a:accent6', srgbClr: accent6Srgb),
      hlink: ThemeColorOptions(xmlKey: 'a:hlink', srgbClr: hlinkSrgb),
      folHlink: ThemeColorOptions(xmlKey: 'a:folHlink', srgbClr: folHlinkSrgb),
    );

    // Font Scheme
    final TypefaceOptions typefaceOptions = TypefaceOptions(
      latin: font,
      eastAsia: font,
      complexScript: '',
    );
    final MajorMinorFontOptions majorMinorFontOptions =
        MajorMinorFontOptions(typeface: typefaceOptions);
    final FontSchemeOptions fontScheme = FontSchemeOptions(
      name: 'Office',
      majorFont: majorMinorFontOptions,
      minorFont: majorMinorFontOptions,
    );

    // Format Scheme - Fill Style List
    const SolidFillOptions phClrSolidFill =
        SolidFillOptions(schemeClrVal: SchemeColorType.phClr);
    const GradientStopOptions gs0 = GradientStopOptions(
      pos: '0',
      schemeClrVal: SchemeColorType.phClr,
      mods: SchemeColorModOptions(
          lumMod: '110000', satMod: '105000', tint: '67000'),
    );
    const GradientStopOptions gs50000 = GradientStopOptions(
      pos: '50000',
      schemeClrVal: SchemeColorType.phClr,
      mods: SchemeColorModOptions(
          lumMod: '105000', satMod: '103000', tint: '73000'),
    );
    const GradientStopOptions gs100000 = GradientStopOptions(
      pos: '100000',
      schemeClrVal: SchemeColorType.phClr,
      mods: SchemeColorModOptions(
          lumMod: '105000', satMod: '109000', tint: '81000'),
    );
    const GradientStopListOptions gsLst1 =
        GradientStopListOptions(stops: [gs0, gs50000, gs100000]);
    const LinearGradientFillOptions lin1 =
        LinearGradientFillOptions(ang: '5400000', scaled: '0');
    const GradientFillOptions gradFill1 = GradientFillOptions(
        rotWithShape: RotWithShapeType.first, gsLst: gsLst1, lin: lin1);

    const GradientStopOptions gs0_2 = GradientStopOptions(
      pos: '0',
      schemeClrVal: SchemeColorType.phClr,
      mods: SchemeColorModOptions(
        satMod: '103000',
        lumMod: '102000',
        tint: '94000',
      ),
    );
    const GradientStopOptions gs50000_2 = GradientStopOptions(
      pos: '50000',
      schemeClrVal: SchemeColorType.phClr,
      mods: SchemeColorModOptions(
        satMod: '110000',
        lumMod: '100000',
        shade: '100000',
      ),
    );
    const GradientStopOptions gs100000_2 = GradientStopOptions(
      pos: '100000',
      schemeClrVal: SchemeColorType.phClr,
      mods: SchemeColorModOptions(
        lumMod: '99000',
        satMod: '120000',
        shade: '78000',
      ),
    );
    const GradientStopListOptions gsLst2 = GradientStopListOptions(
      stops: <GradientStopOptions>[
        gs0_2,
        gs50000_2,
        gs100000_2,
      ],
    );
    const LinearGradientFillOptions lin2 =
        LinearGradientFillOptions(ang: '5400000', scaled: '0');
    const GradientFillOptions gradFill2 = GradientFillOptions(
      rotWithShape: RotWithShapeType.first,
      gsLst: gsLst2,
      lin: lin2,
    );

    const FillStyleListOptions fillStyleLst = FillStyleListOptions(
      solidFill: phClrSolidFill,
      gradFill1: gradFill1,
      gradFill2: gradFill2,
    );

    // Format Scheme - Line Style List
    const SolidFillOptions lnSolidFill = SolidFillOptions(
      schemeClrVal: SchemeColorType.phClr,
    );
    const LineStyleOptions ln1 = LineStyleOptions(
      width: 1,
      cap: LineCapType.flat,
      cmpd: CompoundLineType.sng,
      algn: LineAlignmentType.ctr,
      solidFill: lnSolidFill,
      prstDash: DashType.solid,
      miter: '800000',
    );
    const LineStyleOptions ln2 = LineStyleOptions(
      width: 2,
      cap: LineCapType.flat,
      cmpd: CompoundLineType.sng,
      algn: LineAlignmentType.ctr,
      solidFill: lnSolidFill,
      prstDash: DashType.solid,
      miter: '800000',
    );
    const LineStyleOptions ln3 = LineStyleOptions(
      width: 3,
      cap: LineCapType.flat,
      cmpd: CompoundLineType.sng,
      algn: LineAlignmentType.ctr,
      solidFill: lnSolidFill,
      prstDash: DashType.solid,
      miter: '800000',
    );
    const LineStyleListOptions lnStyleLst = LineStyleListOptions(
      ln1: ln1,
      ln2: ln2,
      ln3: ln3,
    );

    // Format Scheme - Effect Style List
    const EffectStyleOptions effectStyle1 = EffectStyleOptions();
    const EffectStyleOptions effectStyle2 = EffectStyleOptions();
    const OuterShadowOptions outerShdw = OuterShadowOptions(
      blurRad: '57150',
      dist: '19050',
      dir: '5400000',
      algn: 'ctr',
      rotWithShape: RotWithShapeType.zero,
      srgbClrVal: '000000',
      alphaVal: '63000',
    );
    const EffectStyleOptions effectStyle3 =
        EffectStyleOptions(outerShadow: outerShdw);
    const EffectStyleListOptions effectStyleLst = EffectStyleListOptions(
      effectStyle1: effectStyle1,
      effectStyle2: effectStyle2,
      effectStyle3: effectStyle3,
    );

    // Format Scheme - Background Fill Style List
    const SolidFillOptions bgSolidFill1 = SolidFillOptions(
      schemeClrVal: SchemeColorType.phClr,
    );
    const SolidFillOptions bgSolidFill2 = SolidFillOptions(
      schemeClrVal: SchemeColorType.phClr,
      mods: SchemeColorModOptions(
        tint: '95000',
        satMod: '170000',
      ),
    );
    const GradientStopOptions bgGs0 = GradientStopOptions(
      pos: '0',
      schemeClrVal: SchemeColorType.phClr,
      mods: SchemeColorModOptions(
        tint: '93000',
        satMod: '150000',
        shade: '98000',
        lumMod: '102000',
      ),
    );
    const GradientStopOptions bgGs50000 = GradientStopOptions(
      pos: '50000',
      schemeClrVal: SchemeColorType.phClr,
      mods: SchemeColorModOptions(
        tint: '98000',
        satMod: '130000',
        shade: '90000',
        lumMod: '103000',
      ),
    );
    const GradientStopOptions bgGs100000 = GradientStopOptions(
      pos: '100000',
      schemeClrVal: SchemeColorType.phClr,
      mods: SchemeColorModOptions(
        shade: '63000',
        satMod: '120000',
      ),
    );
    const GradientStopListOptions bgGsLst = GradientStopListOptions(
      stops: <GradientStopOptions>[
        bgGs0,
        bgGs50000,
        bgGs100000,
      ],
    );
    const LinearGradientFillOptions bgLin = LinearGradientFillOptions(
      ang: '5400000',
      scaled: '0',
    );
    const GradientFillOptions bgGradFill = GradientFillOptions(
      rotWithShape: RotWithShapeType.first,
      gsLst: bgGsLst,
      lin: bgLin,
    );
    const BgFillStyleListOptions bgFillStyleLst = BgFillStyleListOptions(
      solidFill1: bgSolidFill1,
      solidFill2: bgSolidFill2,
      gradFill: bgGradFill,
    );

    const FormatSchemeOptions fmtScheme = FormatSchemeOptions(
      name: 'Office',
      fillStyleLst: fillStyleLst,
      lnStyleLst: lnStyleLst,
      effectStyleLst: effectStyleLst,
      bgFillStyleLst: bgFillStyleLst,
    );

    final ThemeElementsOptions themeElements = ThemeElementsOptions(
      clrScheme: clrScheme,
      fontScheme: fontScheme,
      fmtScheme: fmtScheme,
    );

    return ThemeOptions(
      name: 'Office Theme',
      themeElements: themeElements,
    );
  }

  /// The name of the theme.
  final String name;

  /// The core elements of the theme (colors, fonts, formatting).
  final ThemeElementsOptions themeElements;
}
