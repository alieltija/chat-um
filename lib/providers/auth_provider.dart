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

      if (user!.emailVerified && user != null && context.mounted) {
        SnackBarServices.instance.showSnackBarSuccess(
          context,
          'Welcome back, ${user?.email}!',
        );

        NavigationServices.instance.navigateToReplacement("home");
      } else if (user != null && context.mounted) {
        SnackBarServices.instance.showSnackBarError(
          context,
          "Email not verified. Please check your inbox for a verification email.",
        );
        await _auth.signOut();
        user = null;
        status = AuthStatus.notAuthenticated;
        notifyListeners();
      }
    } catch (e) {
      status = AuthStatus.error;
      user = null;
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

      if (user != null) {
        await user!.sendEmailVerification();
      }

      status = AuthStatus.authenticated;
      await onSuccess(result.user!.uid);

      if (user != null && context.mounted) {
        SnackBarServices.instance.showSnackBarSuccess(
          context,
          "Registration successful! Please check your email for verification: ${user?.email}",
        );
        NavigationServices.instance.navigateToReplacement("login");
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

  Future<void> logOUT(BuildContext context) async {
    notifyListeners();
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.notAuthenticated;
      if (user == null && context.mounted) {
        await Future.delayed(const Duration(seconds: 1), () {});
        SnackBarServices.instance.showSnackBarSuccess(
          context,
          "Logged out successfully from ${user?.email}",
        );
        NavigationServices.instance.navigateToReplacement("login");
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarServices.instance.showSnackBarError(
          context,
          "Logout failed: ${e.toString()}",
        );
      }
    }
  }
}
