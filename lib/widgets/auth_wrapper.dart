import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
// If you have an AuthProvider, import it here
// import '../providers/auth_provider.dart';

/// AuthWrapper is a stateless, stable widget that does not use Navigator in build.
/// It only switches between HomeScreen and LoginScreen based on auth state.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, skip auth and go directly to main app
    // TODO: Implement proper auth provider logic
    // final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    // return isLoggedIn ? const MainWrapperScreen() : const LoginScreen();
    return const LoginScreen();
  }
}
