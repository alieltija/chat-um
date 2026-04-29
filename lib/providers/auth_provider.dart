// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// enum AuthStatus {
//   notAuthenticated,
//   authenticating,
//   authenticated,
//   userNotFound,
//   error,
// }

// class AuthProvider extends ChangeNotifier {
//   User? user;
//   AuthStatus status = AuthStatus.notAuthenticated;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   static AuthProvider instance = AuthProvider();

//   AuthProvider() {
//     // Optional: Listen to auth changes automatically when the app starts
//     _auth.authStateChanges().listen((User? newUser) {
//       user = newUser;
//       status = newUser != null
//           ? AuthStatus.authenticated
//           : AuthStatus.notAuthenticated;
//       notifyListeners();
//     });
//   }

//   Future<void> logInWithEmailAndPassword(String email, String password) async {
//     status = AuthStatus.authenticating;
//     notifyListeners();
//     try {
//       UserCredential result = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       user = result.user;
//       status = AuthStatus.authenticated;
//       // Navigate to HomePage
//     } catch (e) {
//       status = AuthStatus.error;
//       print("Login error: $e");
//     }
//     notifyListeners();
//   }
// }
import 'package:chatum/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/snackbar_services.dart';

enum AuthStatus { notAuthenticated, authenticating, authenticated, error }

class AuthProvider extends ChangeNotifier {
  User? user;
  AuthStatus status = AuthStatus.notAuthenticated;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth.authStateChanges().listen((User? newUser) {
      user = newUser;
      status = newUser != null
          ? AuthStatus.authenticated
          : AuthStatus.notAuthenticated;
      notifyListeners();
    });
  }

  Future<void> logInWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
  ) async {
    status = AuthStatus.authenticating;
    notifyListeners();
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = result.user;
      status = AuthStatus.authenticated;

      if (context.mounted) {
        SnackBarServices.instance.showSnackBarSuccess(
          context,
          'Welcome back, ${user?.email}!',
        );
      }
    } catch (e) {
      status = AuthStatus.error;
      if (context.mounted) {
        SnackBarServices.instance.showSnackBarError(context, e.toString());
      }
    }
    notifyListeners();
  }

  Future<void> registerWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
    Future<void> Function(String uid) onSuccess,
  ) async {
    status = AuthStatus.authenticating;
    notifyListeners();

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = result.user;
      status = AuthStatus.authenticated;
      await onSuccess(user!.uid);
      NavigationServices.instance.navigateTo("login");
      if (context.mounted) {
        SnackBarServices.instance.showSnackBarSuccess(
          context,
          "Registration successful! Please log in via ${user?.email}",
        );
      }
    } catch (e) {
      status = AuthStatus.error;
      user = null;
      if (context.mounted) {
        SnackBarServices.instance.showSnackBarError(
          context,
          "Registration failed: ${e.toString()}",
        );
      }
      notifyListeners();
    }
  }
}
