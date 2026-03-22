import 'package:flutter/widgets.dart';

class ReelsPageScrollPhysics extends PageScrollPhysics {
  const ReelsPageScrollPhysics({super.parent});

  @override
  ReelsPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ReelsPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingDistance => 24;

  @override
  double get minFlingVelocity => 420;

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 0.9, stiffness: 220, damping: 28);
}
