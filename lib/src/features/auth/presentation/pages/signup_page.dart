import 'package:flutter/material.dart';
import 'auth_page.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPage(isSignUp: true);
  }
}
