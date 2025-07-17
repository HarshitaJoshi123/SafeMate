import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class JourneyTimerScreen extends StatefulWidget {
  const JourneyTimerScreen({super.key});

  @override
  State<JourneyTimerScreen> createState() => _JourneyTimerScreenState();
}

class _JourneyTimerScreenState extends State<JourneyTimerScreen> {
  int selectedHours = 0;
  int selectedMinutes = 15;
  int selectedSeconds = 0;

  late Duration journeyDuration;
  late Duration remainingTime;

  Timer? countdownTimer;
  bool isTimerRunning = false;
  bool autoAlertEnabled = true;

  double get progress =>
      1 - remainingTime.inSeconds / journeyDuration.inSeconds;

  @override
  void initState() {
    super.initState();
    journeyDuration = Duration(
        hours: selectedHours,
        minutes: selectedMinutes,
        seconds: selectedSeconds);
    remainingTime = journeyDuration;
  }

  void updateJourneyDuration() {
    setState(() {
      journeyDuration = Duration(
        hours: selectedHours,
        minutes: selectedMinutes,
        seconds: selectedSeconds,
      );
      remainingTime = journeyDuration;
    });
  }

  void startTimer() {
    if (journeyDuration.inSeconds == 0) return;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds <= 1) {
        timer.cancel();
        isTimerRunning = false;
        setState(() {});
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(autoAlertEnabled
                ? "Auto Alert Sent!"
                : "Timer Ended"),
            content: Text(autoAlertEnabled
                ? "Time's up! An alert has been sent to your trusted contact."
                : "Your journey time is over."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"))
            ],
          ),
        );
      } else {
        setState(() {
          remainingTime -= const Duration(seconds: 1);
        });
      }
    });

    setState(() {
      isTimerRunning = true;
    });
  }

  void stopTimer() {
    countdownTimer?.cancel();
    setState(() {
      isTimerRunning = false;
      remainingTime = journeyDuration;
    });
  }

  void markSafe() {
    countdownTimer?.cancel();
    setState(() {
      isTimerRunning = false;
      remainingTime = journeyDuration;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("✅ Marked Safe"),
        content: const Text("Glad to hear you're safe!"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: const Text("Journey Timer"),
        backgroundColor: const Color(0xFF302B63),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_rounded,
                size: 60, color: Colors.deepPurpleAccent),
            const SizedBox(height: 10),
            const Text(
              "Track Your Journey Safely",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Circular timer
            CircularPercentIndicator(
              radius: 110.0,
              lineWidth: 12.0,
              percent: isTimerRunning ? progress.clamp(0.0, 1.0) : 0,
              center: Text(
                formatDuration(remainingTime),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              progressColor: Colors.purpleAccent,
              backgroundColor: Colors.white24,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
            ),

            const SizedBox(height: 25),

            // Dropdown Duration Selectors
            if (!isTimerRunning)
              Column(
                children: [
                  const Text(
                    "Set Journey Duration",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      dropdownSelector(
                          label: "Hours",
                          value: selectedHours,
                          max: 23,
                          onChanged: (val) {
                            selectedHours = val;
                            updateJourneyDuration();
                          }),
                      const SizedBox(width: 12),
                      dropdownSelector(
                          label: "Minutes",
                          value: selectedMinutes,
                          max: 59,
                          onChanged: (val) {
                            selectedMinutes = val;
                            updateJourneyDuration();
                          }),
                      const SizedBox(width: 12),
                      dropdownSelector(
                          label: "Seconds",
                          value: selectedSeconds,
                          max: 59,
                          onChanged: (val) {
                            selectedSeconds = val;
                            updateJourneyDuration();
                          }),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Auto Alert Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Auto Alert", style: TextStyle(color: Colors.white)),
                Switch(
                  value: autoAlertEnabled,
                  onChanged: (value) {
                    setState(() {
                      autoAlertEnabled = value;
                    });
                  },
                  activeColor: Colors.deepPurpleAccent,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Start/Stop Timer Button
            gradientButton(
              icon: isTimerRunning ? Icons.stop_circle : Icons.play_arrow,
              text: isTimerRunning ? "Stop Timer" : "Start Journey",
              color1: isTimerRunning
                  ? const Color(0xFFEF3B36)
                  : const Color(0xFF43CEA2),
              color2: isTimerRunning
                  ? const Color(0xFFCB2D3E)
                  : const Color(0xFF185A9D),
              onPressed: isTimerRunning ? stopTimer : startTimer,
            ),

            const SizedBox(height: 15),

            // I'm Safe Button
            gradientButton(
              icon: Icons.check_circle,
              text: "I'm Safe",
              color1: const Color(0xFF36D1DC),
              color2: const Color(0xFF5B86E5),
              onPressed: isTimerRunning ? markSafe : null,
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Gradient Button
  Widget gradientButton({
    required IconData icon,
    required String text,
    required Color color1,
    required Color color2,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text,
            style: const TextStyle(fontSize: 18, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Dropdown Widget
  Widget dropdownSelector({
    required String label,
    required int value,
    required int max,
    required void Function(int) onChanged,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: value,
            dropdownColor: const Color(0xFF302B63),
            iconEnabledColor: Colors.white,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white),
            items: List.generate(max + 1, (index) {
              return DropdownMenuItem<int>(
                value: index,
                child: Text(index.toString().padLeft(2, '0')),
              );
            }),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ),
      ],
    );
  }
}
