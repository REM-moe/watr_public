import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watr/services/supabase_service.dart';

class AuthController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Observable variables
  final Rx<User?> _user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  // Computed observable for current user
  Rx<User?> get user => _user;

  @override
  void onInit() async {
    super.onInit();
    _user.value = _supabaseService.client.auth.currentUser;
    isLoggedIn.value = _user.value != null;

    ever(_user, (User? user) {
      isLoggedIn.value = user != null;
    });

    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          _user.value = session?.user;
          break;
        case AuthChangeEvent.signedOut:
          _user.value = null;
          break;
        default:
          break;
      }
    });
  }

  Future<void> signUp({
    required String f_name,
    required String l_name,
    required String email,
    required String password,
    String? phone,
    String? profilePic,
  }) async {
    try {
      isLoading.value = true;

      final AuthResponse response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _supabaseService.client.from('users').insert([
          {
            'id': response.user!.id,
            'f_name': f_name,
            'l_name': l_name,
            'email': email,
            'phone_number': phone,
            'pfp_pic': profilePic,
          }
        ]);

        // Flag user as first-time
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('isFirstTime_${response.user!.id}', true);

        _user.value = response.user;
        Get.offAllNamed('/pair'); // Go to onboarding form

        Get.snackbar(
          'Success',
          'Registration successful! Please verify your email.',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        throw Exception('Error signing up user: $response');
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with email and password
  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final AuthResponse response =
          await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _user.value = response.user;

        // Check if the user is logging in for the first time
        final prefs = await SharedPreferences.getInstance();
        bool isFirstTime =
            prefs.getBool('isFirstTime_${_user.value?.id}') ?? true;

        if (isFirstTime) {
          prefs.setBool('isFirstTime_${_user.value?.id}', false);
          Get.offAllNamed('/pair'); // Onboarding form for new users
        } else {
          Get.offAllNamed('/'); // Home for returning users
        }
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _supabaseService.client.auth.signOut();
      _user.value = null;

      Get.snackbar(
        'Success',
        'Successfully logged out!',
        snackPosition: SnackPosition.TOP,
      );
      Get.offAllNamed('/auth'); // Use offAllNamed to clear the navigation stack
      Get.reload();
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _supabaseService.client.auth.resetPasswordForEmail(email);
      Get.snackbar(
        'Success',
        'Password reset email sent!',
        snackPosition: SnackPosition.TOP,
      );
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  var isMenuOpen = false.obs; // Tracks if the menu is open

  void toggleMenu() {
    isMenuOpen.value = !isMenuOpen.value;
  }

  void closeMenu() {
    isMenuOpen.value = false;
  }
}
