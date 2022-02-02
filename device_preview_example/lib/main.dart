import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:device_preview/device_preview.dart';
import 'package:device_preview_example/stubs/amplify_auth_cognito_stub.dart';
import 'package:device_preview_example/stubs/amplify_class_stub.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'amplifyconfiguration.dart';

void main() {
  runApp(const DevicePreviewApp());
}

class DevicePreviewApp extends StatefulWidget {
  const DevicePreviewApp({
    Key? key,
  }) : super(key: key);

  @override
  State<DevicePreviewApp> createState() => _DevicePreviewAppState();
}

class _DevicePreviewAppState extends State<DevicePreviewApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceThemeProvider()),
      ],
      child: DevicePreview(
        devices: [
          ...Devices.ios.all,
          ...Devices.android.all,
        ],
        tools: const [
          ThemeSection(),

          // SystemSection(locale: false),
          DeviceSection(
            frameVisibility: false,
            orientation: false,
          ),
          SettingsSection(),
        ],
        builder: (context) => const MyApp(),
      ),
    );
  }
}

class ThemeSection extends StatelessWidget {
  const ThemeSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select(
      (DevicePreviewStore store) => store.data.isDarkMode,
    );
    final deviceTheme = context.select(
      (DeviceThemeProvider store) => store.deviceTheme,
    );
    final isMaterial = deviceTheme == DeviceTheme.material;
    return ToolPanelSection(
      title: 'Theme',
      children: [
        ListTile(
          key: const Key('theme'),
          title: const Text('Theme'),
          subtitle: Text(isDarkMode ? 'Dark' : 'Light'),
          trailing: Icon(
            isDarkMode ? Icons.brightness_3 : Icons.brightness_high,
          ),
          onTap: () {
            final state = context.read<DevicePreviewStore>();
            state.toggleDarkMode();
          },
        ),
        ListTile(
          title: const Text('Theme'),
          subtitle: Text(isMaterial ? 'Default Material' : 'Custom Color'),
          trailing: Icon(
            isMaterial ? Icons.circle : Icons.color_lens,
          ),
          onTap: () {
            context.read<DeviceThemeProvider>().toggle();
          },
        ),
      ],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      // stub Amplify
      AmplifyClass.instance = AmplifyClassStub();
      // add the auth plugin stub
      await Amplify.addPlugin(AmplifyAuthCognitoStub());
      // configure amplify
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      print('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceTheme = context.select(
      (DeviceThemeProvider store) => store.deviceTheme,
    );
    final isMaterial = deviceTheme == DeviceTheme.material;

    return Authenticator(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        title: 'Authenticator Demo',
        builder: Authenticator.builder(),
        theme: isMaterial
            ? ThemeData.light()
            : ThemeData.from(
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.deepPurple,
                  backgroundColor: Colors.white,
                  brightness: Brightness.light,
                ),
              ),
        darkTheme: isMaterial
            ? ThemeData.dark()
            : ThemeData.from(
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.deepPurple,
                  backgroundColor: Colors.black,
                  brightness: Brightness.dark,
                ),
              ),
        themeMode: ThemeMode.system,
        home: Scaffold(
          appBar: AppBar(),
          body: Column(
            children: const [
              Text('You are logged in!'),
              SignOutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

enum DeviceTheme { material, custom }

class DeviceThemeProvider with ChangeNotifier {
  DeviceTheme _deviceTheme = DeviceTheme.material;

  DeviceTheme get deviceTheme => _deviceTheme;

  void toggle() {
    if (_deviceTheme == DeviceTheme.material) {
      _deviceTheme = DeviceTheme.custom;
    } else {
      _deviceTheme = DeviceTheme.material;
    }
    notifyListeners();
  }
}
