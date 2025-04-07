import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  late SupabaseClient client;

  Future<SupabaseService> init() async {
    try {
      // Initialize Supabase with the provided URL and anonKey
      await Supabase.initialize(
        url: '',
        anonKey: '',
      );

      // After initializing, you can access the Supabase client
      client = Supabase.instance.client;

      return this;
    } catch (e) {
      rethrow;
    }
  }
}
