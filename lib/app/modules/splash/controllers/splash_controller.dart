import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  @override
  void onInit() {
    super.onInit();
    _initAnimation();
    _startSplash();
  }

  void _initAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    scaleAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startSplash() {
    // Mulai animasi
    animationController.forward();

    // Navigasi ke halaman berikutnya setelah animasi selesai
    Future.delayed(const Duration(milliseconds: 2000), () {
      _navigateToNext();
    });
  }

  void _navigateToNext() {
    Get.offAllNamed(Routes.WELCOME);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
