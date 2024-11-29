import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class FocusTimePage extends StatefulWidget {
  const FocusTimePage({super.key});

  @override
  State<FocusTimePage> createState() => _FocusTimePageState();
}

class _FocusTimePageState extends State<FocusTimePage> {
  Stopwatch _stopwatch = Stopwatch();
  late final Ticker _ticker;
  bool showPomodoro = true;

  Timer? _pomodoroTimer;

  static const int pomodoroDuration = 20; // 25 minutes in seconds
  static const int breakDuration = 5 * 60; // 5 minutes in seconds
  int _remainingTime = pomodoroDuration;
  bool isPomodoroRunning = false;
  bool isOnBreak = false;

  AudioPlayer _audioPlayer = AudioPlayer();


  @override
  void initState() {
    super.initState();
    _ticker = Ticker((_) {
      // Triggers a rebuild every tick to show elapsed time
      setState(() {});
    });
  }


  void _startStopwatch() {
    _stopwatch.start();
    _ticker.start();
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _ticker.stop();
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    setState(() {});
  }

  // Pomodoro logic
  void _startPomodoro() {
    if (_remainingTime == 0) {
      _remainingTime = pomodoroDuration;
    }
    isPomodoroRunning = true;
    _pomodoroTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _stopPomodoro(); // Stop timer when it hits 0
          _playAlert();
          _startBreak();
        }
      });
    });
  }

  void _stopPomodoro() {
    _pomodoroTimer?.cancel(); // Cancel the timer
    isPomodoroRunning = false;
  }

  void _resetPomodoro() {
    _remainingTime = pomodoroDuration;
    setState(() {}); // Reset Pomodoro time
  }

  void _startBreak() {
    setState(() {
      isOnBreak = true;
      _remainingTime = breakDuration; // Set break time to 5 minutes
    });

    // Start the break countdown
    _pomodoroTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _playAlert();
          _endBreak(); // End the break when it hits 0
        }
      });
    });
  }

  void _endBreak() {
    setState(() {
      isOnBreak = false;
      _remainingTime = pomodoroDuration; // Reset for next Pomodoro session
    });
  }

  void _playAlert() async {
    await _audioPlayer.play(AssetSource('assets/sounds/beep.mp3'));
  }

  // Format the time in mm:ss
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }




//widget
  Widget _buildUIStopwatch(){
    return Column(
      children: [
        ElevatedButton(
            onPressed:_startStopwatch,
            child: Text('Start')
        ),
        Text("${_stopwatch.elapsed.inSeconds} seconds"),
        ElevatedButton(
            onPressed: _stopStopwatch,
            child: Text('Stop')
        ),
        ElevatedButton(
            onPressed: _resetStopwatch,
            child: Text('Reset'))
      ],
    );
  }

  Widget _buildUIPomodoro() {
    return Column(
      children: [
        Text('Pomodoro Timer'),
        SizedBox(height: 20),
        Text(_formatTime(_remainingTime), style: TextStyle(fontSize: 48)),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: isPomodoroRunning ? _stopPomodoro : _startPomodoro,
          child: Text(isPomodoroRunning ? 'Stop' : 'Start'),
        ),
        ElevatedButton(
          onPressed: _resetPomodoro,
          child: Text('Reset'),
        ),
        Text(isOnBreak ? "On break" : "Keep Working!"),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Focus Time'),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              ToggleButtons(
                isSelected: [showPomodoro, !showPomodoro],
                onPressed: (index) {
                  setState(() {
                    showPomodoro = index == 0;
                  });
                },
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Pomodoro'),
                  ),Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Stopwatch'),
                  )
                ],
              ),
              SizedBox(height: 10,),
              showPomodoro ? _buildUIPomodoro() : _buildUIStopwatch(),
            ],
          ),
        ),
      ),
    );
  }
}
