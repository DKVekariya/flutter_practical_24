class TimerModel {
  int totalSeconds;
  int remainingSeconds;
  int elapsedSeconds;
  final String id;
  final int initialHours;
  final int initialMinutes;
  final int initialSeconds;

  TimerModel({
    this.totalSeconds = 0,
    this.remainingSeconds = 0,
    this.elapsedSeconds = 0,
    required this.id,
    this.initialHours = 0,
    this.initialMinutes = 0,
    this.initialSeconds = 0,
  });

  String formatTime(int seconds) {
    final duration = Duration(seconds: seconds.clamp(0, seconds));
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }
}