import 'package:flutter/material.dart';
import '../../utils/utils.dart';

class OnboardingScreen5 extends StatelessWidget {
  const OnboardingScreen5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background3,
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  "assets/landing/landing_asset_5.png",
                  height: ScreenUtils.imageHeight(context),
                ),
              ],
            ),
          ),

          BottomClipper(
            height: ScreenUtils.halfScreenHeight(context),
            child: Container(
              width: ScreenUtils.screenWidth(context),  // Ensure full width
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Healthy shopping tips",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 90,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () => AppNavigator.push(context, OnboardingScreen6()),
                    child: Text(
                      "Let's Start",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}