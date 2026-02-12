import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../screens/main_wrapper_screen.dart';
// If you have an AuthProvider, import it here
// import '../providers/auth_provider.dart';

/// AuthWrapper is a stateless, stable widget that does not use Navigator in build.
/// It only switches between HomeScreen and LoginScreen based on auth state.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with your actual auth provider logic
    // final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    final isLoggedIn = false; // TODO: Replace with real auth state
    return isLoggedIn ? const MainWrapperScreen() : const LoginScreen();
  }
}
