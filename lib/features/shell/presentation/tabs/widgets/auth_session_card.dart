import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/bloc/auth_bloc.dart';

class AuthSessionCard extends StatefulWidget {
  const AuthSessionCard({super.key});

  @override
  State<AuthSessionCard> createState() => _AuthSessionCardState();
}

class _AuthSessionCardState extends State<AuthSessionCard> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _manualTokenController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _manualTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        final isAuthenticated = state.status == AuthStatus.authenticated;

        if (isAuthenticated) {
          final session = state.session!;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined),
                      const SizedBox(width: 8),
                      Text(
                        'Session',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          session.isManualToken ? 'Manual token' : 'Firebase',
                        ),
                      ),
                      if (session.isAnonymous)
                        const Chip(label: Text('Anonymous')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('UID: ${session.uid ?? "-"}'),
                  Text('Email: ${session.email ?? "-"}'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthSignOutRequested());
                        },
                        child: const Text('Sign out'),
                      ),
                      if (session.isManualToken)
                        OutlinedButton(
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(const AuthManualTokenCleared());
                          },
                          child: const Text('Clear token'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_outline),
                    const SizedBox(width: 8),
                    Text(
                      'Authentication',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in with Firebase or paste an ID token for backend testing.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (state.message != null && state.message!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      state.message!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: isLoading ? null : _submitEmailPassword,
                      child: const Text('Email sign in'),
                    ),
                    OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthAnonymousSignInRequested());
                            },
                      child: const Text('Anonymous sign in'),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                TextField(
                  controller: _manualTokenController,
                  minLines: 1,
                  maxLines: 2,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Manual Firebase ID token (fallback)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: isLoading ? null : _submitManualToken,
                  child: const Text('Use manual token'),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(minHeight: 2),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitEmailPassword() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required.')),
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

  void _submitManualToken() {
    final token = _manualTokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token is required.')),
      );
      return;
    }

    context.read<AuthBloc>().add(AuthManualTokenSubmitted(token));
  }
}
