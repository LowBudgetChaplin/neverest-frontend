import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../shell/presentation/design/neverest_design.dart';
import '../bloc/profile_bloc.dart';

class MyQrScreen extends StatelessWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: NeverestPalette.ink,
      body: Stack(
        children: [
          const Positioned.fill(
            child: NeverestTopographicLines(
              color: NeverestPalette.orange,
              density: 14,
              opacity: 0.55,
            ),
          ),
          SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (!authState.isAuthenticated) {
                  return _StateMessage(
                    title: l10n.qrSignInRequired,
                    subtitle: l10n.qrSignInSubtitle,
                  );
                }

                return BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, profileState) {
                    if (profileState.status == ProfileStatus.loading &&
                        profileState.profile == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (profileState.status == ProfileStatus.failure) {
                      return _StateMessage(
                        title: l10n.profileSyncFailed,
                        subtitle:
                            profileState.errorMessage ?? l10n.qrUnavailableSubtitle,
                        actionLabel: l10n.commonRetry,
                        onActionTap: () => _retryProfileSync(context, authState),
                      );
                    }

                    final profile = profileState.profile;
                    if (profile == null || profile.qrCode.trim().isEmpty) {
                      return _StateMessage(
                        title: l10n.qrNotAvailable,
                        subtitle: l10n.qrUnavailableSubtitle,
                        actionLabel: l10n.profileSync,
                        onActionTap: () => _retryProfileSync(context, authState),
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Row(
                            children: [
                              NeverestGlassIconButton(
                                icon: Icons.close_rounded,
                                foreground: Colors.white,
                                background: Colors.white.withOpacity(0.1),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const Spacer(),
                              // Text(
                              //   l10n.qrMemberId.toUpperCase(),
                              //   style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              //         color: Colors.white.withOpacity(0.65),
                              //         letterSpacing: 1.4,
                              //       ),
                              // ),
                              const Spacer(),
                              const SizedBox(width: 38),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.qrShowAtGate,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontSize: 34,
                                        ),
                                  ),
                                  // const SizedBox(height: 8),
                                  // Text(
                                  //   l10n.qrScanHint,
                                  //   textAlign: TextAlign.center,
                                  //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  //         color: Colors.white.withOpacity(0.74),
                                  //       ),
                                  // ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        QrImageView(
                                          data: profile.qrCode,
                                          version: QrVersions.auto,
                                          size: 230,
                                          backgroundColor: Colors.white,
                                        ),
                                        Container(
                                          width: 58,
                                          height: 58,
                                          decoration: BoxDecoration(
                                            color: NeverestPalette.orange,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 4,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.terrain_rounded,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    profile.displayName,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    profile.qrCode,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.white.withOpacity(0.64),
                                          letterSpacing: 1.2,
                                        ),
                                  ),
                                  const SizedBox(height: 18),
                                  _RefreshCountdown(
                                    onRefresh: () =>
                                        _retryProfileSync(context, authState),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _retryProfileSync(BuildContext context, AuthState authState) {
    context.read<ProfileBloc>().add(
          ProfileLoadRequested(
            suggestedDisplayName: _suggestDisplayName(authState),
            preferMeEndpoints: true,
          ),
        );
  }

  String _suggestDisplayName(AuthState authState) {
    final session = authState.session;
    if (session == null) {
      return 'Neverest User';
    }
    if (session.displayName != null && session.displayName!.trim().isNotEmpty) {
      return session.displayName!.trim();
    }
    if (session.email != null && session.email!.trim().isNotEmpty) {
      return session.email!.trim().split('@').first;
    }
    return 'Neverest User';
  }
}

class _RefreshCountdown extends StatefulWidget {
  const _RefreshCountdown({required this.onRefresh});

  static const int cycleSeconds = 42;

  final VoidCallback onRefresh;

  @override
  State<_RefreshCountdown> createState() => _RefreshCountdownState();
}

class _RefreshCountdownState extends State<_RefreshCountdown> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = _RefreshCountdown.cycleSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    if (!mounted) return;
    if (_remaining <= 1) {
      widget.onRefresh();
      setState(() => _remaining = _RefreshCountdown.cycleSeconds);
    } else {
      setState(() => _remaining -= 1);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 14,
            color: Colors.white70,
          ),
          const SizedBox(width: 6),
          Text(
            l10n.qrRefreshCountdown(_format(_remaining)),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(0.75),
                  letterSpacing: 0.9,
                ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.74),
                    ),
              ),
              if (actionLabel != null && onActionTap != null) ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onActionTap,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
