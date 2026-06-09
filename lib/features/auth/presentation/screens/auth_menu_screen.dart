import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../shell/presentation/design/neverest_design.dart';
import '../bloc/auth_bloc.dart';

enum AuthMenuMode {
  login,
  register,
}

class AuthMenuScreen extends StatefulWidget {
  const AuthMenuScreen({
    super.key,
    this.initialMode = AuthMenuMode.login,
  });

  final AuthMenuMode initialMode;

  @override
  State<AuthMenuScreen> createState() => _AuthMenuScreenState();
}

class _AuthMenuScreenState extends State<AuthMenuScreen> {
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPhoneController = TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerConfirmController =
      TextEditingController();

  late AuthMenuMode _mode;
  bool _hideLoginPassword = true;
  bool _hideRegisterPassword = true;
  bool _hideRegisterConfirm = true;
  bool _awaitingRegisterResult = false;
  String? _registerAvatarB64;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.message != current.message,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          if (messenger == null) {
            return;
          }

          if (_awaitingRegisterResult && state.status != AuthStatus.loading) {
            _awaitingRegisterResult = false;
            if (state.status == AuthStatus.unauthenticated) {
              _registerPasswordController.clear();
              _registerConfirmController.clear();
              _loginEmailController.text = _registerEmailController.text.trim();
              _loginPasswordController.clear();
              if (_mode != AuthMenuMode.login && mounted) {
                setState(() => _mode = AuthMenuMode.login);
              }
            }
          } else if (state.status == AuthStatus.unauthenticated &&
              _mode != AuthMenuMode.login &&
              mounted) {
            setState(() => _mode = AuthMenuMode.login);
          }

          if (state.message != null && state.message!.trim().isNotEmpty) {
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message!.trim())));
          }

          if (state.status == AuthStatus.authenticated) {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop(true);
            }
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;
          final isAuthenticated = state.status == AuthStatus.authenticated;
          final session = state.session;

          return ListView(
            padding: EdgeInsets.only(
              left: 0,
              right: 0,
              top: MediaQuery.paddingOf(context).top,
              bottom: 24,
            ),
            children: [
              SizedBox(
                height: 250,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(color: NeverestPalette.ink),
                    ),
                    const NeverestTopographicLines(
                      color: NeverestPalette.orange,
                      density: 16,
                      opacity: 0.62,
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Text(
                        (_mode == AuthMenuMode.login
                                ? l10n.authTabLogin
                                : l10n.authTabRegister)
                            .toUpperCase(),
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 36,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? NeverestPalette.inkRaised
                        : NeverestPalette.paperRaised,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? NeverestPalette.inkLine
                          : NeverestPalette.paperLine,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AuthSegmentedTabs(
                        isLogin: _mode == AuthMenuMode.login,
                        loginLabel: l10n.authTabLogin,
                        registerLabel: l10n.authTabRegister,
                        onLogin: () =>
                            setState(() => _mode = AuthMenuMode.login),
                        onRegister: () =>
                            setState(() => _mode = AuthMenuMode.register),
                      ),
                      const SizedBox(height: 14),
                      if (isAuthenticated && session != null) ...[
                        Text(
                          l10n.authSessionActive,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.authSignedAs(session.email ?? session.uid ?? '-'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton(
                              onPressed: () => Navigator.of(context).maybePop(true),
                              child: Text(l10n.authContinue),
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
                      ] else if (_mode == AuthMenuMode.login) ...[
                        _buildLoginForm(context, isLoading),
                      ] else ...[
                        _buildRegisterForm(context, isLoading),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isLoading) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: l10n.authEmailLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _loginPasswordController,
          obscureText: _hideLoginPassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: l10n.authPasswordLabel,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _hideLoginPassword = !_hideLoginPassword;
                });
              },
              icon: Icon(
                _hideLoginPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isLoading ? null : _submitLogin,
            child: Text(l10n.authLoginButton),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => setState(() => _mode = AuthMenuMode.register),
            child: Text(l10n.authSwitchToRegister),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 6),
          const LinearProgressIndicator(minHeight: 2),
        ],
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context, bool isLoading) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional profile photo
        Center(
          child: GestureDetector(
            onTap: isLoading ? null : _pickRegisterAvatar,
            child: Stack(
              children: [
                NeverestAvatar(
                  name: _registerNameController.text.isEmpty
                      ? '?'
                      : _registerNameController.text,
                  size: 84,
                  imageB64: _registerAvatarB64,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: NeverestPalette.orange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? NeverestPalette.inkRaised
                            : NeverestPalette.paperRaised,
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            l10n.authPhotoOptional,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _registerNameController,
          enabled: !isLoading,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.authDisplayNameLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _registerEmailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: l10n.authEmailLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _registerPhoneController,
          keyboardType: TextInputType.phone,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: l10n.profilePhone,
            hintText: '+40 7xx xxx xxx',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _registerPasswordController,
          obscureText: _hideRegisterPassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: l10n.authPasswordLabel,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _hideRegisterPassword = !_hideRegisterPassword;
                });
              },
              icon: Icon(
                _hideRegisterPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _registerConfirmController,
          obscureText: _hideRegisterConfirm,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: l10n.authConfirmPasswordLabel,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _hideRegisterConfirm = !_hideRegisterConfirm;
                });
              },
              icon: Icon(
                _hideRegisterConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isLoading ? null : _submitRegister,
            child: Text(l10n.authRegisterButton),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed:
                isLoading ? null : () => setState(() => _mode = AuthMenuMode.login),
            child: Text(l10n.authSwitchToLogin),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 6),
          const LinearProgressIndicator(minHeight: 2),
        ],
      ],
    );
  }

  void _submitLogin() {
    final l10n = AppLocalizations.of(context)!;
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authCredentialsRequired)),
      );
      return;
    }
    context.read<AuthBloc>().add(
          AuthEmailPasswordSignInRequested(
            email: email,
            password: password,
          ),
        );
  }

  Future<void> _pickRegisterAvatar() async {
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
    if (!mounted) return;
    setState(() {
      _registerAvatarB64 = 'data:image/jpeg;base64,${base64Encode(compressed)}';
    });
  }

  void _submitRegister() {
    final l10n = AppLocalizations.of(context)!;
    final email = _registerEmailController.text.trim();
    final phone = _registerPhoneController.text.trim();
    final password = _registerPasswordController.text;
    final confirm = _registerConfirmController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authCredentialsRequired)),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authPhoneRequired)),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authPasswordMinLength)),
      );
      return;
    }
    if (confirm != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authPasswordsMismatch)),
      );
      return;
    }
    _awaitingRegisterResult = true;
    context.read<AuthBloc>().add(
          AuthEmailPasswordRegisterRequested(
            email: email,
            password: password,
            displayName: _registerNameController.text.trim(),
            phoneNumber: phone,
            avatarB64: _registerAvatarB64,
          ),
        );
  }
}

/// Segmented Login / Register selector styled in the app theme.
/// Selected segment = orange pill with white text; unselected = transparent
/// with muted text. Clear contrast on dark or light backgrounds.
class _AuthSegmentedTabs extends StatelessWidget {
  const _AuthSegmentedTabs({
    required this.isLogin,
    required this.loginLabel,
    required this.registerLabel,
    required this.onLogin,
    required this.onRegister,
  });

  final bool isLogin;
  final String loginLabel;
  final String registerLabel;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? NeverestPalette.ink : NeverestPalette.paper,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment(context, loginLabel, isLogin, onLogin),
          ),
          Expanded(
            child: _segment(context, registerLabel, !isLogin, onRegister),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? NeverestPalette.inkMuted : NeverestPalette.paperMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? NeverestPalette.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : mutedColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
        ),
      ),
    );
  }
}
