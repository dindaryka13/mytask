import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../widgets/blob_painter.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background putih
          Container(color: Colors.white),

          // Animasi blob biru
          Center(
            child: AnimatedBuilder(
              animation: controller.scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: controller.scaleAnimation.value,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: BlobPainter(),
                  ),
                );
              },
            ),
          ),

          // Logo maskot di tengah
          Center(
            child: _buildLogo(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/logo-putih-maskot.png',
      width: 180,
      fit: BoxFit.contain,
    );
  }
}
