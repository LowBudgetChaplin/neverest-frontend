import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../resources/widgets/app_illustrated_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

class MyQrScreen extends StatelessWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My QR')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (!authState.isAuthenticated) {
            return const AppIllustratedState(
              icon: Icons.lock_outline,
              title: 'Sign in required',
              subtitle: 'Sign in first to load your QR code.',
            );
          }

          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              if (profileState.status == ProfileStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (profileState.status == ProfileStatus.failure) {
                return _ProfileFailure(
                  errorMessage: profileState.errorMessage,
                  onRetry: () => _retryProfileSync(context, authState),
                );
              }

              final profile = profileState.profile;
              if (profile == null || profile.qrCode.trim().isEmpty) {
                return _ProfileUnavailable(
                  onRetry: () => _retryProfileSync(context, authState),
                );
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          QrImageView(
                            data: profile.qrCode,
                            version: QrVersions.auto,
                            size: 260,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.displayName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile.qrCode,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
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
      final username = session.email!.trim().split('@').first;
      if (username.isNotEmpty) {
        return username;
      }
    }
    return 'Neverest User';
  }
}

class _ProfileUnavailable extends StatelessWidget {
  const _ProfileUnavailable({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppIllustratedState(
      icon: Icons.qr_code_2_outlined,
      title: 'QR not available',
      subtitle: 'Profile QR is not available yet.',
      actionLabel: 'Sync profile',
      onActionTap: onRetry,
    );
  }
}

class _ProfileFailure extends StatelessWidget {
  const _ProfileFailure({
    required this.errorMessage,
    required this.onRetry,
  });

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppIllustratedState(
      icon: Icons.error_outline,
      title: 'Profile sync failed',
      subtitle: errorMessage ?? 'Could not load profile QR.',
      actionLabel: 'Retry',
      onActionTap: onRetry,
    );
  }
}
