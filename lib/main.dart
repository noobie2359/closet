import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personalcloset/firebase_options.dart';
import 'package:personalcloset/models/model_auth.dart';
import 'screens/screen_index.dart';
import 'screens/screen_login.dart';
import 'screens/screen_splash.dart';
import 'screens/screen_register.dart';
import 'screens/screen_intro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
      ],
      child: MaterialApp(
        title: 'Personal Closet App',
        routes: {
          "/": (context) => IntroScreen(),
          '/index': (context) => IndexScreen(),
          '/login': (context) => LoginScreen(),
          '/splash': (context) => SplashScreen(),
          '/register': (context) => RegisterScreen(),
        },
        // 첫 화면 지정
        initialRoute: "/",
      ),
    );
  }
}
