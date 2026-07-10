import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_colors.dart';

/// Skeleton loading widget with shimmer animation.
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets margin;

  const SkeletonLoader({
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
    this.margin = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.skeletonShimmer,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.skeletonShimmer,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Loading state for screens (list of skeleton rows).
class LoadingState extends StatelessWidget {
  final int itemCount;
  final double? itemHeight;
  final EdgeInsets padding;
  final bool isVertical;

  const LoadingState({
    this.itemCount = 6,
    this.itemHeight = 80,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.isVertical = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: isVertical
            ? Column(
                children: List.generate(
                  itemCount,
                  (index) => Padding(
                    padding:
                        EdgeInsets.only(bottom: index < itemCount - 1 ? 12 : 0),
                    child: SkeletonLoader(height: itemHeight ?? 80),
                  ),
                ),
              )
            : Row(
                children: List.generate(
                  itemCount,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: index < itemCount - 1 ? 12 : 0),
                      child: SkeletonLoader(height: itemHeight ?? 80),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
