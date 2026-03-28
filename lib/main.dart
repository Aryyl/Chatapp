import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: ChatApp()));
}

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    // Light Theme Colors
    const lightPrimary = Color(0xFF1D1D1F);
    const lightBackground = Color(0xFFFDFBF7);
    const lightSurface = Color(0xFFFFFFFF);
    const lightAccent = Color(0xFFA28F79);

    // Dark Theme Colors
    const darkPrimary = Color(0xFFE5E5E5);
    const darkBackground = Color(0xFF121212);
    const darkSurface = Color(0xFF1E1E1E);
    const darkAccent = Color(0xFFD4C5B2);

    return MaterialApp(
      title: 'Murmur',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: const ColorScheme.light(
          primary: lightPrimary,
          surface: lightBackground,
          onSurface: lightPrimary,
          secondary: lightAccent,
        ),
        textTheme: GoogleFonts.newsreaderTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: lightPrimary, displayColor: lightPrimary),
        appBarTheme: AppBarTheme(
          backgroundColor: lightBackground,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: lightPrimary),
          titleTextStyle: GoogleFonts.newsreader(
            color: lightPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: lightSurface,
          selectedItemColor: lightPrimary,
          unselectedItemColor: Color(0xFF9E9E9E),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: darkPrimary,
          surface: darkBackground,
          onSurface: darkPrimary,
          secondary: darkAccent,
        ),
        textTheme: GoogleFonts.newsreaderTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: darkPrimary, displayColor: darkPrimary),
        appBarTheme: AppBarTheme(
          backgroundColor: darkBackground,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: darkPrimary),
          titleTextStyle: GoogleFonts.newsreader(
            color: darkPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkSurface,
          selectedItemColor: darkPrimary,
          unselectedItemColor: Color(0xFF757575),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While checking auth state, show a blank loading screen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If user is logged in, show HomeScreen, else LoginScreen
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
