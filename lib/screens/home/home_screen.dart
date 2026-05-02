import 'package:chatum/providers/auth_provider.dart';
import 'package:chatum/services/navigation_services.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Welcome back!"),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text("Confirm Logout"),
                      content: Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            NavigationServices.instance.goBack();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            NavigationServices.instance.goBack();
                            AuthProvider.instance.logOUT(context);
                          },
                          child: Text("Logout"),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
