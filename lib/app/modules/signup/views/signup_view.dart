import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.33,
            decoration: const BoxDecoration(
              color: Color(0xFFB5E5E8),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/signup.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('Username'),
                        _buildTextField(
                          controller: controller.usernameController,
                          hintText: 'Adinda Ryka',
                          validator: controller.validateUsername,
                        ),

                        const SizedBox(height: 12),
                        _buildLabel('Email'),
                        _buildTextField(
                          controller: controller.emailController,
                          hintText: 'adinda.ryka@gmail.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: controller.validateEmail,
                        ),

                        const SizedBox(height: 12),
                        _buildLabel('Password'),
                        Obx(() => _buildTextField(
                              controller: controller.passwordController,
                              hintText: '••••••••',
                              obscureText:
                                  controller.isPasswordHidden.value,
                              validator: controller.validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed:
                                    controller.togglePasswordVisibility,
                              ),
                            )),

                        const SizedBox(height: 12),
                        _buildLabel('Confirm Password'),
                        Obx(() => _buildTextField(
                              controller:
                                  controller.confirmPasswordController,
                              hintText: '••••••••',
                              obscureText: controller
                                  .isConfirmPasswordHidden.value,
                              validator:
                                  controller.validateConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isConfirmPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: controller
                                    .toggleConfirmPasswordVisibility,
                              ),
                            )),

                        const SizedBox(height: 20),

                        Obx(() => SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF4DB8C1),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                ),
                                child: controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Sign up',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                              ),
                            )),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            const Text("  or  "),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: controller.signUpWithGoogle,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/google.png', height: 24),
                                const SizedBox(width: 12),
                                const Text('Continue with Google'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            GestureDetector(
                              onTap: controller.navigateToLogin,
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Color(0xFF4DB8C1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
