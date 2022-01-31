import 'package:auto_route/auto_route.dart';
import 'package:amplify_authenticator_example/auto_route_example/screens/books/book_details_page.dart';
import 'package:amplify_authenticator_example/auto_route_example/screens/books/book_list_page.dart';

import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../screens/profile/routes.dart';
import '../screens/settings.dart';
import '../screens/user-data/routes.dart';
import 'auth_guard.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page|Dialog,Route',
  routes: <AutoRoute>[
    // app stack
    AutoRoute<String>(
      path: '/',
      page: HomePage,
      // guards: [AuthGuard],
      children: [
        AutoRoute(
          path: 'books',
          page: EmptyRouterPage,
          name: 'BooksTab',
          children: [
            AutoRoute(
              path: '',
              page: BookListPage,
              guards: [AuthGuard],
            ),
            AutoRoute(
              path: ':id',
              page: BookDetailsPage,
              meta: {'hideBottomNav': true},
            ),
          ],
        ),
        profileTab,
        AutoRoute(
          path: 'settings/:tab',
          page: SettingsPage,
          initial: true,
          name: 'SettingsTab',
        ),
      ],
    ),
    userDataRoutes,
    // auth
    AutoRoute(page: LoginPage, path: '/login'),
    RedirectRoute(path: '*', redirectTo: '/'),
  ],
)
class $RootRouter {}
