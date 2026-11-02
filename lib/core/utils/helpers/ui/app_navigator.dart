import 'package:flutter/material.dart';

class AppNavigator {
  AppNavigator._();

  static final key = GlobalKey<NavigatorState>();

  static NavigatorState? get currentState => key.currentState;

  static BuildContext? get context => key.currentContext;
}
