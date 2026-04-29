import 'package:flutter/material.dart';

class SnackBarServices {
  static SnackBarServices instance = SnackBarServices();

  void showSnackBarError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSnackBarSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
