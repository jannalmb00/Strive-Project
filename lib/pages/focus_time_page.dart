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
  bool showTimer = true;

  late Timer _timer;
  int _seconds = 0; // To store seconds
  String _input = ''; // To store user input
  bool _isTimerActive = false;


  AudioPlayer _audioPlayer = AudioPlayer();


  @override
  void initState() {
    super.initState();
    _ticker = Ticker((_) {
      // Triggers a rebuild every tick to show elapsed time
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel(); // Clean up the timer when the widget is disposed
    }
    super.dispose();
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

  //timer
  void startTimer() {
    if (_input.isEmpty) return; // Ensure input is not empty
    int minutes = int.tryParse(_input) ?? 0;
    _seconds = minutes * 60; // Convert minutes to seconds

    if (_seconds > 0) {
      setState(() {
        _isTimerActive = true;
      });
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_seconds > 0) {
          setState(() {
            _seconds--;
          });
        } else {
          _timer.cancel(); // Stop the timer when seconds reach 0
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Time\'s Up!'),
              content: Text('The timer has finished.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
          setState(() {
            _isTimerActive = false;
          });
        }
      });
    }
  }

  void resetTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _seconds = 0;
      _input = '';
      _isTimerActive = false;
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
        SizedBox(height: 20),
        ElevatedButton(
            onPressed:_startStopwatch,
            child: Text('Start')
        ),
        Text("${_stopwatch.elapsed.inSeconds} seconds", style: TextStyle(fontSize: 48)),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: _stopStopwatch,
                child: Text('Stop')
            ),
            SizedBox(width: 20),
            ElevatedButton(
                onPressed: _resetStopwatch,
                child: Text('Reset'))
          ],
        ),
      ],
    );
  }

  Widget _buildUITimer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // TextField for user input to set the timer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter time in minutes',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _input = value;
              });
            },
          ),
        ),
        SizedBox(height: 20),

        Text(
          _isTimerActive
              ? 'Time Remaining: ${_seconds ~/ 60} minute(s) ${_seconds % 60} second(s)'
              : 'Enter the time and start the timer',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isTimerActive ? null : startTimer, // Disable button if timer is active
              child: Text('Start Timer'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: resetTimer,
              child: Text('Reset Timer'),
            ),
          ],
        ),
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
                isSelected: [showTimer, !showTimer],
                onPressed: (index) {
                  setState(() {
                    showTimer = index == 0;
                  });
                },
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Pomodoro'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Stopwatch'),
                  )
                ],
              ),
              SizedBox(height: 10,),
              showTimer ? _buildUITimer() : _buildUIStopwatch(),
            ],
          ),
        ),
      ),
    );
  }
}
