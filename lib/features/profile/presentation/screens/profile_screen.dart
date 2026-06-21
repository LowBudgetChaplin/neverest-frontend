import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../admin/presentation/screens/admin_center_screen.dart';
import '../../../partner/presentation/screens/partner_center_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../shell/presentation/design/neverest_design.dart';
import '../../../strava/presentation/cubit/strava_cubit.dart';
import '../../../theme/presentation/app_locale_cubit.dart';
import '../../../theme/presentation/theme_mode_cubit.dart';
import '../bloc/profile_bloc.dart';
import 'my_qr_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = context.watch<ProfileBloc>().state;
    final authState = context.watch<AuthBloc>().state;
    final accessState = context.watch<AccessCubit>().state;
    final themeMode = context.watch<ThemeModeCubit>().state;
    final localeCode = context.watch<AppLocaleCubit>().currentCode;

    final dashboardState = context.watch<DashboardBloc>().state;
    final profile = profileState.profile;
    final displayName = profile?.displayName ?? _suggestDisplayName(authState);
    final points = profile?.totalPoints ?? 0;
    final rank = _computeRank(dashboardState.data?.leaderboard, profile?.id, displayName);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          left: 0,
          right: 0,
          top: MediaQuery.paddingOf(context).top + 8,
          bottom: 28,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                NeverestGlassIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.profileTitle.toUpperCase(),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 34,
                      ),
                ),
                const Spacer(),
                NeverestGlassIconButton(
                  icon: Icons.qr_code_2_rounded,
                  onPressed: () {
                    Navigator.of(context).push(
                      AppPageRoute.fadeSlide(const MyQrScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ProfileIdentityCard(
              displayName: displayName,
              phoneNumber: profile?.phoneNumber,
              avatarB64: profile?.avatarB64,
              points: points,
              rank: rank,
              onEditTap: () => _showEditProfileSheet(context, profile?.displayName ?? displayName, profile?.phoneNumber),
              onAvatarTap: () => _pickAndUploadAvatar(context),
            ),
          ),
          const SizedBox(height: 20),
          NeverestSectionHeader(title: l10n.profileConnections),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _StravaConnectionRow(onConnect: () => _connectStrava(context)),
          ),
          const SizedBox(height: 20),
          NeverestSectionHeader(title: l10n.profileSettings),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SettingsCard(
              isDarkMode: themeMode == ThemeMode.dark,
              localeCode: localeCode,
              onThemeChanged: (enabled) => context
                  .read<ThemeModeCubit>()
                  .setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light),
              onLocaleChanged: (code) =>
                  context.read<AppLocaleCubit>().setLocaleCode(code),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        AppPageRoute.fadeSlide(const MyQrScreen()),
                      );
                    },
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: Text(l10n.profileShowMyQr),
                  ),
                ),
                if (accessState.canOpenAdminCenter) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          AppPageRoute.fadeSlide(const AdminCenterScreen()),
                        );
                      },
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: Text(l10n.profileAdminCenter),
                    ),
                  ),
                ],
                if (accessState.canOpenPartnerCenter) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          AppPageRoute.fadeSlide(const PartnerCenterScreen()),
                        );
                      },
                      icon: const Icon(Icons.storefront_outlined),
                      label: const Text('Partner Center'),
                    ),
                  ),
                ],
                if (profileState.status == ProfileStatus.failure) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _retryProfileSync(context, authState),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.commonRetry),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.4)),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst);
                      context
                          .read<AuthBloc>()
                          .add(const AuthSignOutRequested());
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(l10n.authSignOut),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connectStrava(BuildContext context) async {
    try {
      final url = await context.read<StravaCubit>().getConnectUrl();
      if (url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare Strava: $e')),
        );
      }
    }
  }

  void _showEditProfileSheet(
      BuildContext context, String currentName, String? currentPhone) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _EditProfileSheet(
        initialName: currentName,
        initialPhone: currentPhone ?? '',
        onSave: (name, phone) {
          context.read<ProfileBloc>().add(
                ProfileUpdateRequested(
                  displayName: name.trim().isEmpty ? null : name.trim(),
                  phoneNumber: phone.trim(),
                ),
              );
        },
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();

    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 200,
      minHeight: 200,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    final b64 = 'data:image/jpeg;base64,${base64Encode(compressed)}';

    if (context.mounted) {
      context.read<ProfileBloc>().add(ProfileUpdateRequested(avatarB64: b64));
    }
  }

  void _retryProfileSync(BuildContext context, AuthState authState) {
    context.read<ProfileBloc>().add(
          ProfileLoadRequested(
            suggestedDisplayName: _suggestDisplayName(authState),
            preferMeEndpoints: true,
          ),
        );
  }

  int _computeRank(List<LeaderboardEntrySummary>? leaderboard, String? userId,
      String displayName) {
    if (leaderboard == null || leaderboard.isEmpty) return 0;
    final sorted = [...leaderboard]
      ..sort((a, b) => b.points.compareTo(a.points));
    for (int i = 0; i < sorted.length; i++) {
      final entry = sorted[i];
      if ((userId != null && entry.userId == userId) ||
          entry.displayName.toLowerCase() == displayName.toLowerCase()) {
        return i + 1;
      }
    }
    return 0;
  }

  String _suggestDisplayName(AuthState authState) {
    final session = authState.session;
    if (session == null) return 'Neverest User';
    if (session.displayName != null && session.displayName!.trim().isNotEmpty) {
      return session.displayName!.trim();
    }
    if (session.email != null && session.email!.trim().isNotEmpty) {
      return session.email!.trim().split('@').first;
    }
    return 'Neverest User';
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.initialName,
    required this.initialPhone,
    required this.onSave,
  });

  final String initialName;
  final String initialPhone;
  final void Function(String name, String phone) onSave;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.commonEdit.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.authDisplayNameLabel,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: l10n.profilePhone,
              prefixIcon: const Icon(Icons.phone_outlined),
              hintText: '+40 7xx xxx xxx',
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onSave(
                        _nameController.text, _phoneController.text);
                  },
                  child: Text(l10n.commonConfirm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({
    required this.displayName,
    required this.points,
    required this.rank,
    required this.onEditTap,
    required this.onAvatarTap,
    this.phoneNumber,
    this.avatarB64,
  });

  final String displayName;
  final int points;
  final int rank;
  final VoidCallback onEditTap;
  final VoidCallback onAvatarTap;
  final String? phoneNumber;
  final String? avatarB64;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -10,
            width: 160,
            height: 160,
            child: IgnorePointer(
              child: NeverestTopographicRings(
                color: NeverestPalette.orange.withOpacity(0.5),
                count: 9,
                opacity: 0.85,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: Stack(
                        children: [
                          NeverestAvatar(
                            name: displayName,
                            size: 64,
                            imageB64: avatarB64,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: NeverestPalette.orange,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: isDark
                                        ? NeverestPalette.inkRaised
                                        : NeverestPalette.paperRaised,
                                    width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                          if (phoneNumber != null && phoneNumber!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                phoneNumber!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? NeverestPalette.inkMuted
                                          : NeverestPalette.paperMuted,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onEditTap,
                      child: Text(l10n.commonEdit),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileMetric(
                        label: l10n.profileTotalPoints,
                        value: points.toString(),
                        accent: true,
                      ),
                    ),
                    Expanded(
                      child: _ProfileMetric(
                        label: l10n.profileGlobalRank,
                        value: rank > 0 ? '#$rank' : '-',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 30,
                color: accent ? NeverestPalette.orange : null,
              ),
        ),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1,
              ),
        ),
      ],
    );
  }
}

class _StravaConnectionRow extends StatefulWidget {
  const _StravaConnectionRow({required this.onConnect});
  final VoidCallback onConnect;

  @override
  State<_StravaConnectionRow> createState() => _StravaConnectionRowState();
}

class _StravaConnectionRowState extends State<_StravaConnectionRow>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StravaCubit>().loadStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<StravaCubit>().loadStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stravaState = context.watch<StravaCubit>().state;
    final status = stravaState.status;
    final linked = status?.connected == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_run_rounded, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Strava',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  linked
                      ? (status!.athleteName ?? 'Conectat')
                      : l10n.profileConnectionStrava,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (linked)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '● ${l10n.profileLinked}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: NeverestPalette.success,
                      ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.read<StravaCubit>().disconnect(),
                  child: Icon(Icons.link_off_rounded,
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            )
          else
            OutlinedButton(
              onPressed: widget.onConnect,
              child: Text(l10n.profileConnect),
            ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.isDarkMode,
    required this.localeCode,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  final bool isDarkMode;
  final String localeCode;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<String> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileDarkTheme,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    // Text(
                    //   l10n.profileDarkThemeSubtitle,
                    //   style: Theme.of(context).textTheme.bodySmall,
                    // ),
                  ],
                ),
              ),
              Switch(value: isDarkMode, onChanged: onThemeChanged),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileLanguage,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _LangChip(
                label: l10n.profileSystemLanguage,
                selected: localeCode == AppLocaleCubit.systemCode,
                onTap: () => onLocaleChanged(AppLocaleCubit.systemCode),
              ),
              _LangChip(
                label: 'Română',
                selected: localeCode == AppLocaleCubit.roCode,
                onTap: () => onLocaleChanged(AppLocaleCubit.roCode),
              ),
              _LangChip(
                label: 'English',
                selected: localeCode == AppLocaleCubit.enCode,
                onTap: () => onLocaleChanged(AppLocaleCubit.enCode),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// High-contrast language selector chip: filled orange when selected,
class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? NeverestPalette.inkMuted : NeverestPalette.paperMuted;
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? NeverestPalette.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected
                ? NeverestPalette.orange
                : (isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine),
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : muted,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
