import 'package:flutter/cupertino.dart';
import 'package:flutter_practical_24/data/models/timer_model.dart';
import 'package:flutter_practical_24/ui/timer/timer_screen_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:just_audio/just_audio.dart';


class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockVibration extends Mock {
  Future<bool?> hasVibrator() => Future.value(true);
  Future<void> vibrate({int duration = 200}) => Future.value();
}

void main() {
  late TimerViewModel viewModel;
  late MockAudioPlayer mockAudioPlayer;
  late MockVibration mockVibration;

  setUp() {
  mockAudioPlayer = MockAudioPlayer();
  mockVibration = MockVibration();
  viewModel = TimerViewModel(audioPlayer: mockAudioPlayer);
  }

  tearDown() {
  viewModel.dispose();
  }

  test('TimerModel formats time correctly', () {
  final model = TimerModel(id: 'test');
  expect(model.formatTime(3665), '01:01:05');
  expect(model.formatTime(0), '00:00:00');
  expect(model.formatTime(7200), '02:00:00');
  });

  test('TimerViewModel validates invalid input', () {
  viewModel.hoursController.text = '0';
  viewModel.minutesController.text = '0';
  viewModel.secondsController.text = '0';
  viewModel.toggleTimer(null as BuildContext);
  expect(viewModel.isRunning, false);
  expect(viewModel.errorMessage, 'Please enter a valid duration');
  });

  test('TimerViewModel starts and updates timer', () async {
  viewModel.hoursController.text = '0';
  viewModel.minutesController.text = '0';
  viewModel.secondsController.text = '5';
  viewModel.toggleTimer(null as BuildContext);
  expect(viewModel.isRunning, true);
  expect(viewModel.model.totalSeconds, 5);
  expect(viewModel.model.remainingSeconds, 5);

  // Simulate 2 seconds
  await Future.delayed(const Duration(seconds: 2));
  expect(viewModel.model.elapsedSeconds, 2);
  expect(viewModel.model.remainingSeconds, 3);
  });

  test('TimerViewModel stops timer', () async {
  viewModel.hoursController.text = '0';
  viewModel.minutesController.text = '0';
  viewModel.secondsController.text = '5';
  viewModel.toggleTimer(null as BuildContext);
  expect(viewModel.isRunning, true);

  await Future.delayed(const Duration(seconds: 1));
  viewModel.toggleTimer(null as BuildContext); // Stop
  expect(viewModel.isRunning, false);
  final elapsed = viewModel.model.elapsedSeconds;
  await Future.delayed(const Duration(seconds: 1));
  expect(viewModel.model.elapsedSeconds, elapsed); // Should not increment
  });

  test('TimerViewModel plays sound', () async {
  when(mockAudioPlayer.seek(Duration.zero)).thenAnswer((_) async {});
  when(mockAudioPlayer.play()).thenAnswer((_) async {});
  await viewModel.playSound();
  verify(mockAudioPlayer.seek(Duration.zero)).called(1);
  verify(mockAudioPlayer.play()).called(1);
  });

  test('TimerViewModel triggers vibration', () async {
  when(mockVibration.hasVibrator()).thenAnswer((_) async => true);
  await viewModel.triggerVibration();
  verify(mockVibration.vibrate(duration: 200)).called(1);
  });

  test('TimerViewModel resumes timer correctly', () async {
  viewModel.hoursController.text = '0';
  viewModel.minutesController.text = '0';
  viewModel.secondsController.text = '10';
  viewModel.toggleTimer(null as BuildContext);
  expect(viewModel.isRunning, true);

  // Simulate 3 seconds
  await Future.delayed(const Duration(seconds: 3));
  expect(viewModel.model.elapsedSeconds, 3);
  expect(viewModel.model.remainingSeconds, 7);

  // Stop timer
  viewModel.toggleTimer(null as BuildContext);
  expect(viewModel.isRunning, false);

  // Resume timer
  viewModel.toggleTimer(null as BuildContext);
  expect(viewModel.isRunning, true);

  // Simulate 2 more seconds
  await Future.delayed(const Duration(seconds: 2));
  expect(viewModel.model.elapsedSeconds, 5);
  expect(viewModel.model.remainingSeconds, 5);
  });

  test('TimerViewModel resets on completion', () async {
  viewModel.hoursController.text = '0';
  viewModel.minutesController.text = '0';
  viewModel.secondsController.text = '2';
  viewModel.toggleTimer(null as BuildContext);
  expect(viewModel.isRunning, true);

  // Simulate 3 seconds to ensure completion
  await Future.delayed(const Duration(seconds: 3));
  expect(viewModel.isRunning, false);
  expect(viewModel.model.remainingSeconds, 2); // Reset to initial
  expect(viewModel.model.elapsedSeconds, 0);
  expect(viewModel.hoursController.text, '0');
  expect(viewModel.minutesController.text, '0');
  expect(viewModel.secondsController.text, '2');
  });
  }