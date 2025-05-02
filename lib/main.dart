import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_practical_24/ui/timer/timer_screen.dart';
import 'package:flutter_practical_24/ui/timer/timer_screen_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const CountdownTimerApp());
}

class CountdownTimerApp extends StatelessWidget {
  const CountdownTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerViewModel(),
      child: MaterialApp(
        title: 'Countdown Timer',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const TimerScreen(),
      ),
    );
  }
}
