import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/database.dart';
import '../services/database_service.dart';

part 'shopping_memo_view_model.freezed.dart';

@freezed
class ShoppingMemoState with _$ShoppingMemoState {
  const factory ShoppingMemoState({
    @Default([]) List<ShoppingItem> items,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ShoppingMemoState;
}

class ShoppingMemoViewModel extends StateNotifier<ShoppingMemoState> {
  ShoppingMemoViewModel(this._database) : super(const ShoppingMemoState()) {
    loadItems();
  }

  final TegakiDatabase _database;

  Future<void> loadItems() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final items = await _database.getAllShoppingItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addItem(String name) async {
    if (name.trim().isEmpty) return;

    try {
      await _database.addShoppingItem(name.trim());
      await loadItems(); // リストを再読み込み
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> toggleItemCompleted(int id, bool isCompleted) async {
    try {
      await _database.updateShoppingItemCompleted(id, isCompleted);
      await loadItems(); // リストを再読み込み
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await _database.deleteShoppingItem(id);
      await loadItems(); // リストを再読み込み
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> clearAllItems() async {
    try {
      await _database.clearAllShoppingItems();
      await loadItems(); // リストを再読み込み
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Riverpod Provider
final shoppingMemoViewModelProvider = 
    StateNotifierProvider<ShoppingMemoViewModel, ShoppingMemoState>((ref) {
  // シングルトンパターンでデータベースインスタンスを取得
  final database = DatabaseService.instance.database;
  return ShoppingMemoViewModel(database);
});