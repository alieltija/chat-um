import 'package:chatum/services/db_services.dart';
import 'package:chatum/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/snackbar_services.dart';

enum AuthStatus { notAuthenticated, authenticating, authenticated, error }

// A quick local data holder class structure for the user's details.
// If you already have a user model class file, import that instead!
class AppUserModel {
  final String name;
  final String image;
  AppUserModel({required this.name, required this.image});
}

class AuthProvider extends ChangeNotifier {
  User? user;
  AuthStatus status = AuthStatus.notAuthenticated;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Added property to hold the active custom Firestore details
  AppUserModel? currentUserModel;

  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth.authStateChanges().listen((User? newUser) async {
      user = newUser;
      if (newUser != null) {
        status = AuthStatus.authenticated;
        // Fetch profile details whenever Firebase auth state triggers true
        await fetchCurrentUserModel();
      } else {
        status = AuthStatus.notAuthenticated;
        currentUserModel = null;
      }
      notifyListeners();
      checkCurrentUserIsAuthenticated();
    });
  }

  // Helper method to fetch and structure your profile data from your DbService
  Future<void> fetchCurrentUserModel() async {
    if (user != null) {
      try {
        // FIX: Call the new Future method instead of the Stream
        var userDoc = await DbServices.instance.getUserDataFuture(user!.uid);

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;

          currentUserModel = AppUserModel(
            // FIX: explicitly using 'displayName' and 'photoURL' to match storeUserData
            name: data['displayName'] ?? 'User',
            image: data['photoURL'] ?? '',
          );
          notifyListeners();
        }
      } catch (e) {
        print("Error compiling currentUserModel profiles: $e");
      }
    }
  }

  void _autoLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null &&
          user!.emailVerified &&
          NavigationServices.instance.navigatorKey.currentState != null) {
        DbServices.instance.updateLastSeen(user!.uid);
        NavigationServices.instance.navigateToReplacement("home");
      }
    });
  }

  void checkCurrentUserIsAuthenticated() {
    user = _auth.currentUser;
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
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
        // Fetch data immediately upon manual sign-in success
        await fetchCurrentUserModel();

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
        currentUserModel = null;
        status = AuthStatus.notAuthenticated;
        notifyListeners();
      }
    } catch (e) {
      status = AuthStatus.error;
      user = null;
      currentUserModel = null;
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
          "Registration successful! Please check your email for verification",
        );
        NavigationServices.instance.navigateToReplacement("login");
      }
    } catch (e) {
      status = AuthStatus.error;
      user = null;
      currentUserModel = null;
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
    try {
      String currentUserId = _auth.currentUser!.uid;
      await DbServices.instance.updateLastSeen(currentUserId);
      await _auth.signOut();
      user = null;
      currentUserModel = null; // Clean out memory scope data on exit
      status = AuthStatus.notAuthenticated;
      notifyListeners();

      if (context.mounted) {
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
