import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController();
});

final userNameProvider = StateNotifierProvider<UserNameNotifier, String?>((ref) {
  return UserNameNotifier();
});

class UserNameNotifier extends StateNotifier<String?> {
  UserNameNotifier() : super(null) {
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('user_name');
  }

  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    state = name;
  }
}

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncValue.data(null));

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _auth.signInAnonymously());
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ));
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ));
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _auth.signOut());
  }
}
