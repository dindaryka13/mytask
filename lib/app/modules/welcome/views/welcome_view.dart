import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../controllers/welcome_controller.dart';
import '../widgets/animated_shapes.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background shapes animasi
            const AnimatedShapes(),
            
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Robot Mascot Image
                  _buildMascot(),
                  
                  const SizedBox(height: 40),
                  
                  // Welcome Text
                  _buildWelcomeText(),
                  
                  const Spacer(flex: 3),
                  
                  // Buttons
                  _buildButtons(),
                  
                  const SizedBox(height: 24),
                  
                  // Privacy Policy & Terms
                  _buildPrivacyTerms(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMascot() {
    return Hero(
      tag: 'robot_maskot',
      child: Image.asset(
        'assets/maskot-biru.png',
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        // Jika belum ada asset, akan error. Gunakan placeholder:
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF7AB5BD).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 100,
              color: Color(0xFF7AB5BD),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'MyTask',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7AB5BD),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
  
  Widget _buildButtons() {
    return Column(
      children: [
        // Sign Up Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: controller.goToSignUp,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(0xFF7AB5BD),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7AB5BD),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Log In Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.goToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7AB5BD),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Log In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPrivacyTerms() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'By continuing you accept our '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              color: Color(0xFF7AB5BD),
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = controller.openPrivacyPolicy,
          ),
          const TextSpan(text: '\nand '),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
              color: Color(0xFF7AB5BD),
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = controller.openTermsOfService,
          ),
        ],
      ),
    );
  }
}