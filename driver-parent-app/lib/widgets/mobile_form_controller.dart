import 'package:flutter/material.dart';

class MobileFormController extends ChangeNotifier {
  bool _showing = false;
  Widget? _child;

  bool get showing => _showing;
  Widget? get child => _child;

  /// Show a form (slide up)
  void show(Widget child) {
    _child = child;
    _showing = true;
    notifyListeners();
  }

  /// Hide current form (slide down)
  void hide() {
    _showing = false;
    notifyListeners();
  }

  /// INTERNAL: used by the animated host to swap forms
  void setChildInternal(Widget child) {
    _child = child;
    notifyListeners();
  }
}