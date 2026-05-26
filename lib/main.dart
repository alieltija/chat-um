import 'package:chatum/firebase_options.dart';
import 'package:chatum/providers/auth_provider.dart';
import 'package:chatum/screens/auth/login_screen.dart';
import 'package:chatum/screens/auth/registration_screen.dart';
import 'package:chatum/screens/home/home_screen.dart';
import 'package:chatum/services/navigation_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: AuthProvider.instance,
      child: MaterialApp(
        title: "chat'em",
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationServices.instance.navigatorKey,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color.fromRGBO(42, 117, 88, 1),
          scaffoldBackgroundColor: Color.fromRGBO(28, 27, 27, 1),
        ),
        initialRoute: "login",
        routes: {
          "login": (context) => LoginScreen(),
          "register": (context) => RegistrationScreen(),
          "home": (context) => HomeScreen(),
        },
      ),
    );
  }
}
