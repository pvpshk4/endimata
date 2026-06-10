import 'package:flutter/material.dart';

class DebugLogger extends ChangeNotifier {
  static final DebugLogger instance = DebugLogger._();
  DebugLogger._();

  final List<String> _logs = [];
  List<String> get logs => _logs;

  void log(String message) {
    _logs.add('${DateTime.now().toIso8601String().substring(11, 19)} $message');
    if (_logs.length > 20) _logs.removeAt(0);
    notifyListeners();
  }
}

// Глобальная функция для удобства
void dlog(String message) => DebugLogger.instance.log(message);
