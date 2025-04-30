import 'package:flutter/material.dart';
import 'package:nutriscan/utils/utils.dart';

class BottomClipper extends StatelessWidget {
  final double height;
  final Widget? child;

  const BottomClipper({super.key, required this.height, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.clipper,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(60),
        ),
      ),
      child: child,
    );
  }
}

class TopClipper extends StatelessWidget {
  final double height;

  const TopClipper({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.clipper,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
      ),
    );
  }
}
