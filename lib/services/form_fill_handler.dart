// Form Fill Handler - Auto-fills forms via voice commands

import 'package:flutter/material.dart';

class FormFillHandler {
  // Global form controllers storage
  static final Map<String, Map<String, TextEditingController>> _formControllers = {};
  
  // Register form fields for a screen
  static void registerForm(String screenName, Map<String, TextEditingController> controllers) {
    _formControllers[screenName] = controllers;
  }
  
  // Unregister when screen disposed
  static void unregisterForm(String screenName) {
    _formControllers.remove(screenName);
  }
  
  // Fill form fields from voice command
  static bool fillForm(String screenName, Map<String, dynamic> fields) {
    final controllers = _formControllers[screenName];
    if (controllers == null) return false;
    
    fields.forEach((fieldName, value) {
      final controller = controllers[fieldName];
      if (controller != null && value != null) {
        controller.text = value.toString();
      }
    });
    
    return true;
  }
  
  // Get current form values
  static Map<String, String> getFormValues(String screenName) {
    final controllers = _formControllers[screenName];
    if (controllers == null) return {};
    
    final values = <String, String>{};
    controllers.forEach((fieldName, controller) {
      values[fieldName] = controller.text;
    });
    
    return values;
  }
  
  // Clear form
  static void clearForm(String screenName) {
    final controllers = _formControllers[screenName];
    if (controllers == null) return;
    
    controllers.forEach((_, controller) {
      controller.clear();
    });
  }
  
  // Listen to form changes
  static void addFormListener(String screenName, VoidCallback listener) {
    final controllers = _formControllers[screenName];
    if (controllers == null) return;
    
    controllers.forEach((_, controller) {
      controller.addListener(listener);
    });
  }
}

// Mixin for screens with voice-fillable forms
mixin VoiceFormMixin<T extends StatefulWidget> on State<T> {
  String get screenName;
  Map<String, TextEditingController> get formControllers;
  
  @override
  void initState() {
    super.initState();
    FormFillHandler.registerForm(screenName, formControllers);
  }
  
  @override
  void dispose() {
    FormFillHandler.unregisterForm(screenName);
    super.dispose();
  }
}
