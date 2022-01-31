import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:auto_route/auto_route.dart';
import 'package:auto_route_example/router/router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> isAuthenticated() async {
  try {
    final _session = await Amplify.Auth.fetchAuthSession();
    return _session.isSignedIn;
  } catch (e) {
    return false;
  }
}

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final _isAuthenticated = await isAuthenticated();
    if (!_isAuthenticated) {
      // ignore: unawaited_futures
      router.push(
        LoginRoute(onLoginResult: (_) {
          // we can't pop the bottom page in the navigator's stack
          // so we just remove it from our local stack
          resolver.next();
          router.removeLast();
        }),
      );
    } else {
      resolver.next(true);
    }
  }
}

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }
}
