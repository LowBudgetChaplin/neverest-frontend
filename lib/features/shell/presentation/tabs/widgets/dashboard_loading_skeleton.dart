import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surfaceContainerHigh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SkeletonBlock(height: 120),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SkeletonBlock(height: 90)),
              SizedBox(width: 10),
              Expanded(child: _SkeletonBlock(height: 90)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SkeletonBlock(height: 90)),
              SizedBox(width: 10),
              Expanded(child: _SkeletonBlock(height: 90)),
            ],
          ),
          SizedBox(height: 16),
          _SkeletonBlock(height: 210),
          SizedBox(height: 16),
          _SkeletonBlock(height: 160),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
