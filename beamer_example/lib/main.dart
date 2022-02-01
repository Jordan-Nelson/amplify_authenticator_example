import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:beamer_example/amplifyconfiguration.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:beamer/beamer.dart';

// DATA
class Book {
  const Book(this.id, this.title, this.author);

  final int id;
  final String title;
  final String author;
}

const List<Book> books = [
  Book(1, 'Stranger in a Strange Land', 'Robert A. Heinlein'),
  Book(2, 'Foundation', 'Isaac Asimov'),
  Book(3, 'Fahrenheit 451', 'Ray Bradbury'),
];

// SCREENS
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.beamToNamed('/books'),
              child: const Text('See books'),
            ),
            ElevatedButton(
              onPressed: () => context.beamToNamed('/profile'),
              child: const Text('Go to profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class BooksScreen extends StatelessWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: ListView(
        children: books
            .map(
              (book) => ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                onTap: () => context.beamToNamed('/books/${book.id}'),
              ),
            )
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

  final Book? book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book?.title ?? 'Not Found'),
      ),
      body: book != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Author: ${book!.author}'),
            )
          : const SizedBox.shrink(),
    );
  }
}

// LOCATIONS
class BooksLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/books/:bookId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = [
      const BeamPage(
        key: ValueKey('home'),
        title: 'Home',
        child: HomeScreen(),
      ),
      if (state.uri.pathSegments.contains('books'))
        const BeamPage(
          key: ValueKey('books'),
          title: 'Books',
          child: BooksScreen(),
        ),
    ];
    final String? bookIdParameter = state.pathParameters['bookId'];
    if (bookIdParameter != null) {
      final bookId = int.tryParse(bookIdParameter);
      final book = books.firstWhereOrNull((book) => book.id == bookId);
      pages.add(
        BeamPage(
          key: ValueKey('book-detail-$bookIdParameter'),
          title: 'Book #$bookIdParameter',
          child: BookDetailsScreen(book: book),
        ),
      );
    }
    return pages;
  }
}

class ProfileLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/profile'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = [
      const BeamPage(
        key: ValueKey('home'),
        title: 'Home',
        child: HomeScreen(),
      ),
      const BeamPage(
        key: ValueKey('profile'),
        title: 'Profile',
        child: ProfileScreen(),
      ),
    ];
    return pages;
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(child: SignOutButton()),
    );
  }
}

class LoginLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/login'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = [
      if (state.uri.pathSegments.contains('profile'))
        const BeamPage(
          key: ValueKey('profile'),
          title: 'Profile',
          child: ProfileScreen(),
        ),
      BeamPage(
        key: const ValueKey('login'),
        title: 'Login',
        child: AuthenticatedView(
          child: Container(),
        ),
      ),
    ];
    return pages;
  }
}

// APP
class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

Future<bool> isAuthenticated() async {
  try {
    final _session = await Amplify.Auth.fetchAuthSession();
    return _session.isSignedIn;
  } catch (e) {
    return false;
  }
}

class _MyAppState extends State<MyApp> {
  bool _authenticated = false;
  late final routerDelegate = BeamerDelegate(
    // guards: [
    //   BeamGuard(
    //     // on which path patterns (from incoming routes) to perform the check
    //     pathPatterns: ['/profile'],
    //     // perform the check on all patterns that **don't** have a match in pathPatterns
    //     guardNonMatching: false,
    //     // return false to redirect
    //     check: (context, location) {
    //       return _authenticated;
    //     },
    //     // where to redirect on a false check
    //     beamToNamed: (origin, target) => '/login/',
    //   )
    // ],
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        BooksLocation(),
        ProfileLocation(),
        LoginLocation(),
      ],
    ),
    notFoundRedirectNamed: '/books',
  );

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  void _listenForAuthChanges() async {
    final authenticated = await isAuthenticated();

    setState(() {
      _authenticated = authenticated;
    });

    Amplify.Hub.listen([HubChannel.Auth], (event) {
      if (event.eventName == "SIGNED_IN") {
        setState(() {
          _authenticated = true;
        });
      }
      if (event.eventName == "SIGNED_OUT") {
        setState(() {
          _authenticated = false;
        });
      }
    });
  }

  Future<void> _configureAmplify() async {
    try {
      // Add the following line to add Auth plugin to your app.
      await Amplify.addPlugin(AmplifyAuthCognito());

      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(amplifyconfig);
      _listenForAuthChanges();
    } on Exception catch (e) {
      print('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp.router(
        routerDelegate: routerDelegate,
        routeInformationParser: BeamerParser(),
        backButtonDispatcher: BeamerBackButtonDispatcher(
          delegate: routerDelegate,
        ),
        builder: Authenticator.builder(),
      ),
    );
  }
}

void main() => runApp(MyApp());
