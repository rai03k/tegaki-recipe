import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/timer_view_model.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  int _tempMinutes = 0;
  int _tempSeconds = 0;

  @override
  void initState() {
    super.initState();
    // 初期化時にグローバル状態から値を取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerData = ref.read(timerNotifierProvider);
      setState(() {
        _tempMinutes = timerData.minutes;
        _tempSeconds = timerData.seconds;
      });
    });
  }

  void _updateTime() {
    final timerNotifier = ref.read(timerNotifierProvider.notifier);
    timerNotifier.setTime(_tempMinutes, _tempSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final timerData = ref.watch(timerNotifierProvider);
    final timerNotifier = ref.read(timerNotifierProvider.notifier);
    
    final isPickerMode = timerData.state == TimerState.stopped && timerData.totalSeconds == 0;
    final isRunning = timerData.state == TimerState.running;
    
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
              isPickerMode ? _buildTimePicker(isDarkMode) : _buildTimerDisplay(isDarkMode, timerData),
              
              const Spacer(),
              
              // ボタン類
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // リセットボタン
                  GestureDetector(
                    onTap: () => timerNotifier.resetTimer(),
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
                    onTap: () {
                      if (isPickerMode) {
                        _updateTime(); // まず時間を設定
                      }
                      timerNotifier.toggleTimer();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: (isPickerMode && _tempMinutes == 0 && _tempSeconds == 0)
                          ? (isDarkMode ? Colors.white24 : Colors.black12)
                          : (isDarkMode ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        _getButtonText(timerData.state, isPickerMode),
                        style: TextStyle(
                          fontFamily: 'ArmedLemon',
                          fontSize: 16,
                          color: (isPickerMode && _tempMinutes == 0 && _tempSeconds == 0)
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

  String _getButtonText(TimerState state, bool isPickerMode) {
    if (isPickerMode) return 'スタート';
    
    switch (state) {
      case TimerState.running:
        return 'ストップ';
      case TimerState.paused:
        return 'スタート';
      case TimerState.completed:
        return 'リセット';
      case TimerState.stopped:
        return 'スタート';
    }
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
                _tempMinutes = index;
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
                      fontSize: _tempMinutes == index ? 40 : 24,
                      color: _tempMinutes == index 
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : (isDarkMode ? Colors.white54 : Colors.black54),
                      fontWeight: _tempMinutes == index ? FontWeight.bold : FontWeight.normal,
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
                _tempSeconds = index;
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
                      fontSize: _tempSeconds == index ? 40 : 24,
                      color: _tempSeconds == index 
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : (isDarkMode ? Colors.white54 : Colors.black54),
                      fontWeight: _tempSeconds == index ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildTimerDisplay(bool isDarkMode, TimerData timerData) {
    final timerNotifier = ref.read(timerNotifierProvider.notifier);
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          timerNotifier.formatTime(timerData.remainingSeconds),
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