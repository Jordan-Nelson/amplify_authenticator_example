import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final void Function(bool isLoggedIn)? onLoginResult;
  final bool showBackButton;
  const LoginPage({Key? key, this.onLoginResult, this.showBackButton = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // child is required. Since this is only used as a guard, it will never be seen.
      body: AuthenticatedView(child: Container()),
    );
  }
}
