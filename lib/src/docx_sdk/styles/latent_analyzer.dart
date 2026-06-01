import '../../../docx.dart' show Style, StyleBuilder;
import '../../core/extensions/cast_ext.dart';
import '../utils/language_codes.dart';
import 'latent_styles.dart';
import 'styles.dart';

// Part 1, §17.7.4.5 – Latent Styles.
// Defines default properties for built-in styles that are not explicitly defined in the document.
// The `count` attribute indicates how many of these built-in styles the application should consider.
// `w:lsdException` elements allow you to override these default values for a specific built-in style.
//
// We should never modify styles already defined in the document
// (i.e., `<w:style>` elements) based on the values in `w:latentStyles`.
class LatentAnalyzer {
  const LatentAnalyzer._();

  /// Analyze all the styles and return the updated versions applying
  /// default metadata where required, and making the count expected
  static LatentStyles analyze(
    List<Style> styles,
    LatentStyles latent, {
    String language = LanguageCodes.englishUS,
  }) {
    final List<Style> temp = <Style>[...styles];
    int count = 0;
    final List<LatentException> exceptions = <LatentException>[];

    for (final Style style in temp) {
      count++;
      final StyleConfigurator? qFormat = style.qFormat;
      final StyleConfigurator? semiHidden = style.semiHidden;
      final StyleConfigurator? unhide = style.unhideWhenUsed;
      final StyleConfigurator? uiPriority = style.uiPriority;

      if (qFormat == null &&
          semiHidden == null &&
          unhide == null &&
          uiPriority == null) {
        style.addAll(
          StyleBuilder.uc()
              .semiHidden(latent.defSemiHidden)
              .unhideWhenUsed(latent.defUnhideWhenUsed)
              .uiPriority(latent.defUIPriority)
              .qFormat(latent.defQFormat)
              .build()
              .configurators,
        );
        continue;
      }
      //TODO: apply granular modifications to style
      final Map<String, Object> metadata = <String, Object>{};

      if (qFormat != null && !latent.defQFormat) {
        metadata['w:qFormat'] = true;
      } else if (qFormat == null && latent.defQFormat) {
        style.addAll(
          StyleBuilder.uc()
              .qFormat(
                true,
              )
              .build()
              .configurators,
        );
      }

      if (semiHidden != null && !latent.defSemiHidden) {
        metadata['w:semiHidden'] = true;
      } else if (semiHidden == null && latent.defSemiHidden) {
        style.addAll(
          StyleBuilder.uc().semiHidden(true).build().configurators,
        );
      }

      if (unhide != null && !latent.defUnhideWhenUsed) {
        metadata['w:unhideWhenUsed'] = true;
      } else if (unhide == null && latent.defUnhideWhenUsed) {
        style.addAll(
          StyleBuilder.uc().unhideWhenUsed(true).build().configurators,
        );
      }

      if (uiPriority != null &&
          int.parse(uiPriority.value!.cast<String>()) != latent.defUIPriority) {
        metadata['w:uiPriority'] = uiPriority.value!.cast<String>();
      } else if (uiPriority == null) {
        style.addAll(
          StyleBuilder.priority(
            null,
            latent.defUIPriority,
            Style.characterType,
          ).build().configurators,
        );
      }

      exceptions.add(
        LatentException(
          styleName: style
                  .styleName(language: language)
                  ?.value
                  ?.castOrNull<String>() ??
              // since we cannot get the name using the
              // specified language, we will require get any name
              style.styleNames().last.value!.cast<String>(),
          metadata: metadata,
        ),
      );
    }

    return latent.copyWith(
      count: count,
      exceptions: <LatentException>[
        ...exceptions,
      ],
    );
  }
}
