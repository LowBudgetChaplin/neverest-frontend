import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../dashboard/domain/dashboard_data.dart';
import '../../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../../../resources/widgets/app_illustrated_state.dart';
import 'dashboard_loading_skeleton.dart';

typedef DashboardContentBuilder = Widget Function(
  BuildContext context,
  DashboardData data,
);

class DashboardTabContainer extends StatelessWidget {
  const DashboardTabContainer({
    super.key,
    required this.contentBuilder,
    required this.emptyLabel,
  });

  final DashboardContentBuilder contentBuilder;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        late final Widget body;

        if (state.status == DashboardStatus.loading && state.data == null) {
          body = const DashboardLoadingSkeleton(
            key: ValueKey('dashboard-loading'),
          );
        } else if (state.status == DashboardStatus.failure &&
            state.data == null) {
          body = _DashboardError(
            key: const ValueKey('dashboard-error'),
            message: state.errorMessage ?? 'Unable to connect to backend.',
          );
        } else {
          final data = state.data;
          if (data == null) {
            body = AppIllustratedState(
              key: const ValueKey('dashboard-empty'),
              icon: Icons.landscape_rounded,
              title: emptyLabel,
              subtitle: 'Start by refreshing or signing in to load data.',
              actionLabel: 'Refresh',
              onActionTap: () {
                context
                    .read<DashboardBloc>()
                    .add(const DashboardRefreshRequested());
              },
            );
          } else {
            body = Stack(
              key: const ValueKey('dashboard-content'),
              children: [
                contentBuilder(context, data),
                if (state.status == DashboardStatus.loading)
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            );
          }
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: body,
        );
      },
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppIllustratedState(
      icon: Icons.wifi_off_rounded,
      title: 'Connection issue',
      subtitle: message,
      actionLabel: 'Retry',
      onActionTap: () {
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      },
    );
  }
}
