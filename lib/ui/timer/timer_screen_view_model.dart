import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../../data/models/timer_model.dart';

class TimerViewModel extends ChangeNotifier {
  TimerModel model;
  Timer? _timer;
  bool _isRunning = false;
  bool _notificationShown = false;
  final AudioPlayer _audioPlayer;
  String _errorMessage = '';
  final TextEditingController _hoursController = TextEditingController(text: '0');
  final TextEditingController _minutesController = TextEditingController(text: '0');
  final TextEditingController _secondsController = TextEditingController(text: '0');

  TimerViewModel({AudioPlayer? audioPlayer})
      : model = TimerModel(id: const Uuid().v4()),
        _audioPlayer = audioPlayer ?? AudioPlayer() {
    _initializeAudio();
  }

  bool get isRunning => _isRunning;
  String get remainingTime => model.formatTime(model.remainingSeconds);
  String get elapsedTime => model.formatTime(model.elapsedSeconds);
  String get errorMessage => _errorMessage;
  TextEditingController get hoursController => _hoursController;
  TextEditingController get minutesController => _minutesController;
  TextEditingController get secondsController => _secondsController;
  bool get canStart {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    return (hours * 3600 + minutes * 60 + seconds) > 0 || model.remainingSeconds > 0;
  }

  Future<void> _initializeAudio() async {
    try {
      await _audioPlayer.setAsset('assets/notification.mp3');
    } catch (e) {
      _errorMessage = 'Error loading audio';
      notifyListeners();
    }
  }

  void toggleTimer(BuildContext context) {
    if (!_isRunning) {
      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final seconds = int.tryParse(_secondsController.text) ?? 0;
      final totalSeconds = hours * 3600 + minutes * 60 + seconds;

      if (totalSeconds <= 0 && model.remainingSeconds <= 0) {
        _errorMessage = 'Please enter a valid duration';
        notifyListeners();
        return;
      }

      if (model.remainingSeconds == 0) {
        model = TimerModel(
          id: model.id,
          totalSeconds: totalSeconds,
          remainingSeconds: totalSeconds,
          elapsedSeconds: 0,
          initialHours: hours,
          initialMinutes: minutes,
          initialSeconds: seconds,
        );
      }

      _isRunning = true;
      _notificationShown = false;
      _errorMessage = '';
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        model.elapsedSeconds++;
        model.remainingSeconds = (model.totalSeconds - model.elapsedSeconds).clamp(0, model.totalSeconds);
        notifyListeners();

        if (model.remainingSeconds <= 0) {
          _timer?.cancel();
          _isRunning = false;
          if (!_notificationShown) {
            _showCompletionNotification(context);
            playSound();
            triggerVibration();
            _notificationShown = true;
            // Reset to initial values
            _hoursController.text = model.initialHours.toString();
            _minutesController.text = model.initialMinutes.toString();
            _secondsController.text = model.initialSeconds.toString();
            model = TimerModel(
              id: model.id,
              totalSeconds: model.initialHours * 3600 + model.initialMinutes * 60 + model.initialSeconds,
              remainingSeconds: model.initialHours * 3600 + model.initialMinutes * 60 + model.initialSeconds,
              elapsedSeconds: 0,
              initialHours: model.initialHours,
              initialMinutes: model.initialMinutes,
              initialSeconds: model.initialSeconds,
            );
            notifyListeners();
          }
        }
      });
    } else {
      _isRunning = false;
      _timer?.cancel();
    }
    notifyListeners();
  }

  void _showCompletionNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timer Complete!')),
    );
  }

  Future<void> playSound() async {
    try {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      _errorMessage = 'Error playing sound';
      notifyListeners();
    }
  }

  Future<void> triggerVibration() async {
      HapticFeedback.vibrate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}