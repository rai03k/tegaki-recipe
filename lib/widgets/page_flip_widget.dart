import 'dart:math' as math;
import 'package:flutter/material.dart';

/// カスタムページめくりウィジェット
/// turn_page_transitionライクな動作を軽量に実装
class PageFlipWidget extends StatefulWidget {
  final List<Widget> children;
  final int initialPage;
  final Duration animationDuration;
  final Curve animationCurve;
  final ValueChanged<int>? onPageChanged;
  final PageFlipController? controller;

  const PageFlipWidget({
    super.key,
    required this.children,
    this.initialPage = 0,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = Curves.easeInOut,
    this.onPageChanged,
    this.controller,
  });

  @override
  State<PageFlipWidget> createState() => _PageFlipWidgetState();
}

class _PageFlipWidgetState extends State<PageFlipWidget>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  int _currentPage = 0;
  bool _isFlipping = false;
  double _dragStartX = 0;
  bool _isDragging = false;
  bool _isForward = true; // true: 次のページ, false: 前のページ

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    
    _pageController = PageController(initialPage: widget.initialPage);
    _flipController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: widget.animationCurve,
    ));

    _flipAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isFlipping = false;
        });
        _flipController.reset();
      }
    });

    // コントローラーを接続
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _pageController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _isDragging = true;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging || _isFlipping) return;

    final deltaX = details.globalPosition.dx - _dragStartX;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // ドラッグ方向を更新
    _isForward = deltaX < 0;
    
    // ドラッグ距離に応じてアニメーション値を設定（より敏感に）
    final progress = math.min(deltaX.abs() / (screenWidth * 0.4), 1.0);
    _flipController.value = progress;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging || _isFlipping) return;

    _isDragging = false;
    final deltaX = details.globalPosition.dx - _dragStartX;
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.15;

    // ドラッグ方向を判定
    _isForward = deltaX < 0;

    if (deltaX.abs() > threshold) {
      // ページ変更
      if (deltaX > 0 && _currentPage > 0) {
        _flipToPage(_currentPage - 1);
      } else if (deltaX < 0 && _currentPage < widget.children.length - 1) {
        _flipToPage(_currentPage + 1);
      } else {
        _flipController.reverse();
      }
    } else {
      // 元に戻す
      _flipController.reverse();
    }
  }

  void _flipToPage(int page) {
    if (_isFlipping || page == _currentPage) return;

    setState(() {
      _isFlipping = true;
      _currentPage = page;
    });

    _flipController.forward().then((_) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
      widget.onPageChanged?.call(page);
    });
  }

  /// 次のページに移動
  void nextPage() {
    if (_currentPage < widget.children.length - 1) {
      _flipToPage(_currentPage + 1);
    }
  }

  /// 前のページに移動
  void previousPage() {
    if (_currentPage > 0) {
      _flipToPage(_currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // 現在のページ
              _buildPage(_currentPage),
              
              // フリップ効果
              if (_flipAnimation.value > 0)
                _buildFlipEffect(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    if (index < 0 || index >= widget.children.length) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.children[index],
    );
  }

  Widget _buildFlipEffect() {
    final flipValue = _flipAnimation.value;
    final isFirstHalf = flipValue < 0.5;
    
    // 影の強度をより自然に
    final shadowOpacity = (0.4 * flipValue).clamp(0.0, 0.6);
    final shadowBlur = (15 * flipValue).clamp(0.0, 20.0);
    final shadowOffset = _isForward ? Offset(-3 * flipValue, 2) : Offset(3 * flipValue, 2);
    
    return ClipRect(
      child: Align(
        alignment: _isForward ? Alignment.centerRight : Alignment.centerLeft,
        widthFactor: isFirstHalf ? 1.0 - (flipValue * 2) : (flipValue - 0.5) * 2,
        child: Transform(
          alignment: _isForward ? Alignment.centerRight : Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // より強い遠近効果
            ..rotateY(_isForward 
                ? (isFirstHalf ? flipValue * math.pi : math.pi - (flipValue * math.pi))
                : (isFirstHalf ? -flipValue * math.pi : -math.pi + (flipValue * math.pi))),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(shadowOpacity),
                  blurRadius: shadowBlur,
                  offset: shadowOffset,
                ),
              ],
              // ページに微妙な立体感を与える
              gradient: LinearGradient(
                begin: _isForward ? Alignment.centerLeft : Alignment.centerRight,
                end: _isForward ? Alignment.centerRight : Alignment.centerLeft,
                colors: [
                  Colors.white.withOpacity(1.0),
                  Colors.white.withOpacity(0.9),
                ],
                stops: [0.7, 1.0],
              ),
            ),
            child: isFirstHalf
                ? _buildPage(_currentPage) // 現在のページ
                : _buildPage(_getNextPageIndex()), // 次/前のページ
          ),
        ),
      ),
    );
  }

  int _getNextPageIndex() {
    if (!_isForward && _currentPage > 0) {
      return _currentPage - 1; // 右から左へ → 前のページ
    } else if (_isForward && _currentPage < widget.children.length - 1) {
      return _currentPage + 1; // 左から右へ → 次のページ
    }
    
    // 範囲外の場合は現在のページを返す
    return _currentPage;
  }
}

/// PageFlipWidgetのコントローラー
class PageFlipController {
  _PageFlipWidgetState? _state;

  void _attach(_PageFlipWidgetState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  /// 次のページに移動
  void nextPage() {
    _state?.nextPage();
  }

  /// 前のページに移動
  void previousPage() {
    _state?.previousPage();
  }

  /// 現在のページ番号を取得
  int get currentPage => _state?._currentPage ?? 0;

  /// 総ページ数を取得
  int get pageCount => _state?.widget.children.length ?? 0;
}