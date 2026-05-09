import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/navigation/app_page_route.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/screens/auth_menu_screen.dart';
import '../../design/neverest_design.dart';

class AuthSessionCard extends StatelessWidget {
  const AuthSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state.status == AuthStatus.authenticated;
        final session = state.session;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
            ),
          ),
          child: isAuthenticated && session != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined),
                        const SizedBox(width: 8),
                        Text(
                          l10n.authSessionActive,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.authSignedAs(session.email ?? session.uid ?? '-'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: () => _openAuthMenu(
                            context,
                            initialMode: AuthMenuMode.login,
                          ),
                          child: Text(l10n.authManageSession),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthSignOutRequested());
                          },
                          child: Text(l10n.authSignOut),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.authCardTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.authCardSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: () => _openAuthMenu(
                            context,
                            initialMode: AuthMenuMode.login,
                          ),
                          child: Text(l10n.authTabLogin),
                        ),
                        OutlinedButton(
                          onPressed: () => _openAuthMenu(
                            context,
                            initialMode: AuthMenuMode.register,
                          ),
                          child: Text(l10n.authTabRegister),
                        ),
                      ],
                    ),
                    if (state.message != null &&
                        state.message!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.message!.trim(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }

  void _openAuthMenu(
    BuildContext context, {
    required AuthMenuMode initialMode,
  }) {
    Navigator.of(context).push(
      AppPageRoute.fadeSlide(
        AuthMenuScreen(initialMode: initialMode),
      ),
    );
  }
}
