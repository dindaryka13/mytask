import 'package:get/get.dart';
import '../../../routes/app_pages.dart' as routes;

class WelcomeController extends GetxController {
  // Observable untuk loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi jika diperlukan
  }

  // Fungsi untuk navigasi ke halaman Sign Up
  void goToSignUp() {
    Get.toNamed(routes.Routes.SIGNUP);
  }

  // Fungsi untuk navigasi ke halaman Login
  void goToLogin() {
    Get.toNamed(routes.Routes.LOGIN);
  }

  // Fungsi untuk membuka Privacy Policy
  void openPrivacyPolicy() {
    // Implementasi untuk membuka privacy policy
    print('Buka Privacy Policy');
  }

  // Fungsi untuk membuka Terms of Service
  void openTermsOfService() {
    // Implementasi untuk membuka terms of service
    print('Buka Terms of Service');
  }

  @override
  void onClose() {
    super.onClose();
  }
}
