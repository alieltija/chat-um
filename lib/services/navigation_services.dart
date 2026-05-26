import 'package:flutter/material.dart';

class NavigationServices {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigationServices instance = NavigationServices();

  Future<dynamic> navigateTo(String routeName, {required arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  Future<dynamic> navigateToReplacement(String routeName) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute route) {
    return navigatorKey.currentState!.push(route);
  }

  Future<bool> goBack() {
    navigatorKey.currentState!.pop();
    return Future.value(true);
  }
}
