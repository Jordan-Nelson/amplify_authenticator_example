import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_authenticator_example/amplifyconfiguration.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import 'data/db.dart';
import 'package:amplify_authenticator_example/auto_route_example/router/auth_guard.dart';
import 'package:amplify_authenticator_example/auto_route_example/router/router.gr.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      // Add the following line to add Auth plugin to your app.
      await Amplify.addPlugin(AmplifyAuthCognito());

      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      print('An error occurred configuring Amplify: $e');
    }
  }

  final authService = AuthService();

  final _rootRouter = RootRouter(authGuard: AuthGuard());

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: BooksDBProvider(
        child: MaterialApp.router(
          theme: ThemeData.dark(),
          routerDelegate: _rootRouter.delegate(),
          routeInformationProvider: _rootRouter.routeInfoProvider(),
          routeInformationParser: _rootRouter.defaultRouteParser(),
          builder: Authenticator.builder(),
        ),
      ),
    );
  }
}
