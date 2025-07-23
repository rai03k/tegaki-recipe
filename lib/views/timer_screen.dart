import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import '../view_models/theme_view_model.dart';
import 'dart:async';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  late AudioPlayer _audioPlayer;
  Timer? _timer;
  
  int _minutes = 0;
  int _seconds = 0;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPickerMode = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_totalSeconds == 0) return;
    
    setState(() {
      _isRunning = true;
      _isPickerMode = false;
      // 初回開始時のみ残り時間を設定
      if (_remainingSeconds == 0) {
        _remainingSeconds = _totalSeconds;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _onTimerComplete();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      // ピッカーモードには戻らず、停止状態を保持
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPickerMode = true;
      _remainingSeconds = 0;
    });
  }

  Future<void> _onTimerComplete() async {
    // 音声再生
    try {
      await _audioPlayer.setAsset('assets/se/switch.mp3');
      await _audioPlayer.play();
    } catch (e) {
      // 音声再生エラーは無視
    }
    
    // 振動
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  String _formatTime(int totalSeconds) {
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

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 戻るボタン
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // タイマー表示部分
              _isPickerMode ? _buildTimePicker(isDarkMode) : _buildTimerDisplay(isDarkMode),
              
              const Spacer(),
              
              // ボタン類
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // リセットボタン
                  GestureDetector(
                    onTap: _resetTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'リセット',
                        style: TextStyle(
                          fontFamily: 'ArmedLemon',
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // スタート/ストップボタン
                  GestureDetector(
                    onTap: _totalSeconds == 0 ? null : _toggleTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: _totalSeconds == 0
                          ? (isDarkMode ? Colors.white24 : Colors.black12)
                          : (isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        _isRunning ? 'ストップ' : 'スタート',
                        style: TextStyle(
                          fontFamily: 'ArmedLemon',
                          fontSize: 16,
                          color: _totalSeconds == 0
                            ? (isDarkMode ? Colors.white54 : Colors.black54)
                            : (isDarkMode ? Colors.black : Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 分のピッカー
        SizedBox(
          width: 100, // 幅を広げて全角文字に対応
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 60,
            onSelectedItemChanged: (index) {
              setState(() {
                _minutes = index;
                _totalSeconds = _minutes * 60 + _seconds;
              });
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index > 59) return null;
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _toFullWidth(index.toString().padLeft(2, '０')),
                    style: TextStyle(
                      fontFamily: 'ArmedLemon',
                      fontSize: _minutes == index ? 40 : 24,
                      color: _minutes == index 
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : (isDarkMode ? Colors.white54 : Colors.black54),
                      fontWeight: _minutes == index ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
              childCount: 60,
            ),
          ),
        ),
        
        // コロン
        Text(
          '：',
          style: TextStyle(
            fontFamily: 'ArmedLemon',
            fontSize: 40,
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // 秒のピッカー
        SizedBox(
          width: 100, // 幅を広げて全角文字に対応
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 60,
            onSelectedItemChanged: (index) {
              setState(() {
                _seconds = index;
                _totalSeconds = _minutes * 60 + _seconds;
              });
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index > 59) return null;
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _toFullWidth(index.toString().padLeft(2, '０')),
                    style: TextStyle(
                      fontFamily: 'ArmedLemon',
                      fontSize: _seconds == index ? 40 : 24,
                      color: _seconds == index 
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : (isDarkMode ? Colors.white54 : Colors.black54),
                      fontWeight: _seconds == index ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
              childCount: 60,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay(bool isDarkMode) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _formatTime(_remainingSeconds),
          style: TextStyle(
            fontFamily: 'ArmedLemon',
            fontSize: 60, // 80 → 60に縮小
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}