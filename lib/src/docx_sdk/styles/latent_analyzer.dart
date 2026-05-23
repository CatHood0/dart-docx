import '../../../docx.dart' show Style, StyleBuilder;
import '../../core/extensions/cast_ext.dart';
import '../utils/language_codes.dart';
import 'latent_styles.dart';
import 'styles.dart';

//TODO: look at this and understand again what is this
// I really forgot it
class LatentAnalyzer {
  const LatentAnalyzer._();

  /// Analyze all the styles and return the updated versions applying
  /// default metadata where required, and making the count expected
  static (List<Style>, LatentStyles) analyze(
    Map<String, Style> styles,
    LatentStyles latent, {
    String language = LanguageCodes.englishUS,
  }) {
    final List<Style> temp = <Style>[...styles.values];
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

    return (
      temp,
      latent.copyWith(
        count: count,
        exceptions: <LatentException>[
          ...exceptions,
        ],
      ),
    );
  }
}
