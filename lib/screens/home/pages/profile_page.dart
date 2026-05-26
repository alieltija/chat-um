import 'package:chatum/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/db_services.dart';
import '../../../models/contact_model.dart';

// ignore: must_be_immutable
class ProfilePage extends StatelessWidget {
  ProfilePage({super.key, this.height, this.width});

  late AuthProvider auth = AuthProvider.instance;

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: loginPageUI(),
      ),
    );
  }

  Widget loginPageUI() {
    return Builder(
      builder: (BuildContext context) {
        auth = Provider.of<AuthProvider>(context);
        if (auth.status == AuthStatus.notAuthenticated || auth.user == null) {
          return Center(
            child: SpinKitWanderingCubes(
              color: Colors.blue,
              size: height! * 0.03,
            ),
          );
        }

        return StreamBuilder<Contact>(
          // FIX: Changed from getUserDataFuture to getUserData to give the StreamBuilder a proper Stream
          stream: DbServices.instance.getUserData(auth.user!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            // Checking active connection status safely for streams
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitWanderingCubes(
                  color: Colors.blue,
                  size: height! * 0.03,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text("User document not found in Firestore"),
              );
            }

            var userData = snapshot.data;
            return Align(
              child: SizedBox(
                height: height! * 0.50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _userImageWidget(userData!.photoURL),
                    _userNameWidget(userData.displayName),
                    _userEmailWidget(userData.email),
                    _logOutButton(context),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _userImageWidget(String imageUrl) {
    double imageradius = height! * 0.16;
    return Container(
      height: imageradius,
      width: imageradius,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,

          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Icon(Icons.person, color: Colors.white, size: 50),
            );
          },

          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _userNameWidget(String userName) {
    return Container(
      height: height! * 0.04,
      width: width,
      child: Text(
        userName,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: height! * 0.03,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _userEmailWidget(String email) {
    return Container(
      height: height! * 0.03,
      width: width,
      child: Text(
        email,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white24,
          fontSize: height! * 0.02,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _logOutButton(BuildContext context) {
    return Container(
      height: height! * 0.06,
      width: width! * 0.80,
      color: Colors.red,
      child: IconButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(
                  "Confirm Logout",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                content: Text("Are you sure you want to log out?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      NavigationServices.instance.goBack();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      NavigationServices.instance.goBack();
                      if (context.mounted) {
                        AuthProvider.instance.logOUT(context);
                      }
                    },
                    child: Text("LOGOUT", style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          );
        },
        color: Colors.white,
        icon: Icon(Icons.logout_outlined),
      ),
    );
  }
}
