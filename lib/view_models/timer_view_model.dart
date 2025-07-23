import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vibration/vibration.dart';

part 'timer_view_model.g.dart';

enum TimerState {
  stopped,
  running,
  paused,
  completed,
}

class TimerData {
  final int totalSeconds;
  final int remainingSeconds;
  final TimerState state;
  final int minutes;
  final int seconds;

  const TimerData({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.state,
    required this.minutes,
    required this.seconds,
  });

  TimerData copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    TimerState? state,
    int? minutes,
    int? seconds,
  }) {
    return TimerData(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      state: state ?? this.state,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
    );
  }
}

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _timer;
  AudioPlayer? _audioPlayer;

  @override
  TimerData build() {
    ref.onDispose(() {
      _timer?.cancel();
      _audioPlayer?.dispose();
    });
    
    _audioPlayer = AudioPlayer();
    
    return const TimerData(
      totalSeconds: 0,
      remainingSeconds: 0,
      state: TimerState.stopped,
      minutes: 0,
      seconds: 0,
    );
  }

  void setTime(int minutes, int seconds) {
    final totalSeconds = minutes * 60 + seconds;
    state = state.copyWith(
      totalSeconds: totalSeconds,
      remainingSeconds: totalSeconds,
      minutes: minutes,
      seconds: seconds,
    );
  }

  void startTimer() {
    if (state.totalSeconds == 0) return;
    
    final currentState = state.copyWith(state: TimerState.running);
    state = currentState;
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentData = state;
      
      if (currentData.remainingSeconds > 0) {
        state = currentData.copyWith(
          remainingSeconds: currentData.remainingSeconds - 1,
        );
      } else {
        _timer?.cancel();
        state = currentData.copyWith(state: TimerState.completed);
        _onTimerComplete();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(state: TimerState.paused);
  }

  void resetTimer() {
    _timer?.cancel();
    state = const TimerData(
      totalSeconds: 0,
      remainingSeconds: 0,
      state: TimerState.stopped,
      minutes: 0,
      seconds: 0,
    );
  }

  void toggleTimer() {
    switch (state.state) {
      case TimerState.stopped:
      case TimerState.paused:
        startTimer();
        break;
      case TimerState.running:
        pauseTimer();
        break;
      case TimerState.completed:
        resetTimer();
        break;
    }
  }

  Future<void> _onTimerComplete() async {
    // 音声再生
    try {
      await _audioPlayer?.setAsset('assets/se/switch.mp3');
      await _audioPlayer?.play();
    } catch (e) {
      // 音声再生エラーは無視
    }
    
    // 振動
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '０');
    String secondsStr = seconds.toString().padLeft(2, '０');
    return '${_toFullWidth(minutesStr)}：${_toFullWidth(secondsStr)}';
  }

  String _toFullWidth(String halfWidth) {
    return halfWidth
        .replaceAll('0', '０')
        .replaceAll('1', '１')
        .replaceAll('2', '２')
        .replaceAll('3', '３')
        .replaceAll('4', '４')
        .replaceAll('5', '５')
        .replaceAll('6', '６')
        .replaceAll('7', '７')
        .replaceAll('8', '８')
        .replaceAll('9', '９');
  }
}