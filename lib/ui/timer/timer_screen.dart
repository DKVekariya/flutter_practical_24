import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practical_24/ui/timer/timer_screen_view_model.dart';
import 'package:provider/provider.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TimerViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Countdown Timer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: viewModel.hoursController,
                    decoration: const InputDecoration(labelText: 'Hours'),
                    keyboardType: TextInputType.number,
                    enabled: !viewModel.isRunning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: viewModel.minutesController,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    keyboardType: TextInputType.number,
                    enabled: !viewModel.isRunning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: viewModel.secondsController,
                    decoration: const InputDecoration(labelText: 'Seconds'),
                    keyboardType: TextInputType.number,
                    enabled: !viewModel.isRunning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => viewModel.toggleTimer(context),
              child: Text(viewModel.isRunning ? 'Stop' : 'Start'),
            ),
            const SizedBox(height: 20),
            Text(
              'Remaining Time: ${viewModel.remainingTime}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Elapsed Time: ${viewModel.elapsedTime}',
              style: const TextStyle(fontSize: 20),
            ),
            if (viewModel.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  viewModel.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}