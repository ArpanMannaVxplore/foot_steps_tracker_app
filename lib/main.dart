import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int walkingStepCount = 0;
  int runningStepCount = 0;
  bool isWalking = false;
  bool isRunning = false;
  double lastX = 0.0;
  double lastY = 0.0;
  double lastZ = 0.0;
  double walkingThreshold = 10.0; // Adjust these thresholds as needed
  double runningThreshold = 20.0;
  DateTime walkingStartTime = DateTime.now();
  DateTime runningStartTime = DateTime.now();
  DateTime? walkingEndTime;
  DateTime? runningEndTime;
  double walkingDistance = 0.0;
  double runningDistance = 0.0;

  @override
  void initState() {
    super.initState();
    accelerometerEventStream().listen((AccelerometerEvent event) {
      double acceleration = event.x.abs() + event.y.abs() + event.z.abs();
      DateTime now = DateTime.now();

      setState(() {
        if (acceleration > walkingThreshold) {
          if (!isWalking) {
            isWalking = true;
            walkingStartTime = now;
            walkingStepCount++;
          }
          if (isRunning) {
            isRunning = false;
            runningEndTime = now;
            runningDistance += calculateDistance(runningStartTime, runningEndTime!);
          }
        } else if (acceleration > runningThreshold) {
          if (!isRunning) {
            isRunning = true;
            runningStartTime = now;
            runningStepCount++;
          }
          if (isWalking) {
            isWalking = false;
            walkingEndTime = now;
            walkingDistance += calculateDistance(walkingStartTime, walkingEndTime!);
          }
        } else {
          if (isWalking) {
            isWalking = false;
            walkingEndTime = now;
            walkingDistance += calculateDistance(walkingStartTime, walkingEndTime!);
          }
          if (isRunning) {
            isRunning = false;
            runningEndTime = now;
            runningDistance += calculateDistance(runningStartTime, runningEndTime!);
          }
        }
      });

      lastX = event.x;
      lastY = event.y;
      lastZ = event.z;
    });
  }

  double calculateDistance(DateTime start, DateTime end) {
    // Calculate distance based on time and speed (you can use more accurate methods like GPS if available)
    // For simplicity, let's assume constant speed for walking and running
    const walkingSpeed = 1.4; // m/s
    const runningSpeed = 2.8; // m/s

    return (end.difference(start).inSeconds / 3600) * (isWalking ? walkingSpeed : runningSpeed);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    // Calculate average speeds
    double walkingAvgSpeed = walkingDistance != 0 ? walkingDistance / walkingEndTime!.difference(walkingStartTime).inHours : 0.0;
    double runningAvgSpeed = runningDistance != 0 ? runningDistance / runningEndTime!.difference(runningStartTime).inHours : 0.0;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Activity Tracker'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Walking Steps: $walkingStepCount',
              ),
              Text(
                'Running Steps: $runningStepCount',
              ),
              Text(
                'Walking Distance: ${walkingDistance.toStringAsFixed(2)} meters',
              ),
              Text(
                'Running Distance: ${runningDistance.toStringAsFixed(2)} meters',
              ),
              if (walkingStartTime != null && walkingEndTime != null) ...[
                Text(
                  'Walking Duration: ${formatDuration(walkingEndTime!.difference(walkingStartTime))}',
                ),
                Text(
                  'Walking Avg Speed: ${walkingAvgSpeed.toStringAsFixed(2)} m/h',
                ),
              ],
              if (runningStartTime != null && runningEndTime != null) ...[
                Text(
                  'Running Duration: ${formatDuration(runningEndTime!.difference(runningStartTime))}',
                ),
                Text(
                  'Running Avg Speed: ${runningAvgSpeed.toStringAsFixed(2)} m/h',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
