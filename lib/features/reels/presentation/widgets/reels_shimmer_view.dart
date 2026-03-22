import 'package:flutter/material.dart';
import 'package:reels_assignment/presentation/theme/app_colors_extension.dart';
import 'package:shimmer/shimmer.dart';

class ReelsShimmerView extends StatelessWidget {
  const ReelsShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.reelsBackground,
      child: Shimmer.fromColors(
        baseColor: context.colors.reelsShimmerBase,
        highlightColor: context.colors.reelsShimmerHighlight,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          _ShimmerBox(width: 140, height: 14),
                          SizedBox(height: 12),
                          _ShimmerBox(width: double.infinity, height: 10),
                          SizedBox(height: 8),
                          _ShimmerBox(width: 220, height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ShimmerCircle(size: 46),
                        SizedBox(height: 10),
                        _ShimmerBox(width: 30, height: 10),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.reelsForeground,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colors.reelsForeground,
        shape: BoxShape.circle,
      ),
    );
  }
}
