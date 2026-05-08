import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../shell/presentation/design/neverest_design.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onFinished,
  });

  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = [
      _SlideModel(
        headline: l10n.onboardingHeadline1,
        subtitle: l10n.onboardingSubtitle1,
        cta: l10n.onboardingCta1,
      ),
      _SlideModel(
        headline: l10n.onboardingHeadline2,
        subtitle: l10n.onboardingSubtitle2,
        cta: l10n.onboardingCta2,
      ),
      _SlideModel(
        headline: l10n.onboardingHeadline3,
        subtitle: l10n.onboardingSubtitle3,
        cta: l10n.onboardingCta3,
      ),
    ];

    final current = slides[_step];
    final isLast = _step == slides.length - 1;

    return Scaffold(
      backgroundColor: NeverestPalette.ink,
      body: Stack(
        children: [
          const Positioned.fill(
            child: NeverestTopographicLines(
              color: NeverestPalette.orange,
              density: 18,
              opacity: 0.58,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.72),
                  radius: 0.7,
                  colors: [
                    NeverestPalette.orange.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      const NeverestLogo(compact: true, foreground: Colors.white),
                      const Spacer(),
                      TextButton(
                        onPressed: widget.onFinished,
                        child: Text(
                          l10n.onboardingSkip,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.76),
                              ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          l10n.onboardingStep(_step + 1, slides.length),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: NeverestPalette.orange,
                                letterSpacing: 2,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          current.headline,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 66,
                              ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          current.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.76),
                                height: 1.45,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: List.generate(
                      slides.length,
                      (index) => Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: EdgeInsets.only(
                            right: index == slides.length - 1 ? 0 : 6,
                          ),
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            color: index <= _step
                                ? NeverestPalette.orange
                                : Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (isLast) {
                          widget.onFinished();
                          return;
                        }
                        setState(() => _step += 1);
                      },
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(current.cta),
                    ),
                  ),
                  if (_step == 0) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.onFinished,
                      child: Text(
                        l10n.onboardingAlreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.72),
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideModel {
  const _SlideModel({
    required this.headline,
    required this.subtitle,
    required this.cta,
  });

  final String headline;
  final String subtitle;
  final String cta;
}
