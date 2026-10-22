import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants.dart';

class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const SkeletonBox({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: C.surfaceHi,
      highlightColor: C.surfaceHi2.withValues(alpha: .9),
      period: const Duration(milliseconds: 1400),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: C.surfaceHi,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.surface.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: C.border.withValues(alpha: .5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(height: 36, width: 36, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(height: 12, width: 120),
                          const SizedBox(height: 8),
                          SkeletonBox(height: 10, width: 80),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SkeletonBox(height: 8, radius: 4),
                const SizedBox(height: 10),
                SkeletonBox(height: 8, radius: 4),
                const SizedBox(height: 10),
                SkeletonBox(height: 8, width: 180, radius: 4),
              ],
            ),
          ),
        );
      }),
    );
  }
}
