import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_manager/screens/onboding/onboding_screen.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

void main() {
  // Force Skia rendering
  if (const bool.fromEnvironment('dart.vm.product')) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Optimize texture handling
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'The Flutter Way',
          theme: ThemeData(
            scaffoldBackgroundColor: themeProvider.isDarkMode
                ? const Color(0xFF17203A)
                : Colors.white,
            brightness:
                themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            primarySwatch: Colors.blue,
            fontFamily: "Intel",
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              errorStyle: TextStyle(height: 0),
              border: defaultInputBorder,
              enabledBorder: defaultInputBorder,
              focusedBorder: defaultInputBorder,
              errorBorder: defaultInputBorder,
            ),
          ),
          home: const OnbodingScreen(),
        );
      },
    );
  }
}

const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(
    color: Color(0xFFDEE3F2),
    width: 1,
  ),
);
