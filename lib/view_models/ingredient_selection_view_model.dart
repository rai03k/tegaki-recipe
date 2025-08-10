import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/ingredient.dart';

part 'ingredient_selection_view_model.freezed.dart';

enum IngredientType { ingredient, seasoning }

@freezed
class IngredientSelectionState with _$IngredientSelectionState {
  const factory IngredientSelectionState({
    @Default([]) List<Ingredient> suggestions,
    @Default(-1) int currentEditingIndex,
    @Default(IngredientType.ingredient) IngredientType currentEditingType,
    @Default([]) List<TextEditingController> nameControllers,
    @Default([]) List<TextEditingController> amountControllers,
    @Default([]) List<FocusNode> nameFocusNodes,
    @Default([]) List<FocusNode> amountFocusNodes,
    @Default([]) List<TextEditingController> seasoningNameControllers,
    @Default([]) List<TextEditingController> seasoningAmountControllers,
    @Default([]) List<FocusNode> seasoningNameFocusNodes,
    @Default([]) List<FocusNode> seasoningAmountFocusNodes,
  }) = _IngredientSelectionState;
}

class IngredientSelectionViewModel extends StateNotifier<IngredientSelectionState> {
  IngredientSelectionViewModel() : super(const IngredientSelectionState()) {
    _initializeControllers();
  }

  static const int _maxSuggestions = 5;
  static const Duration _focusDelay = Duration(milliseconds: 100);

  void _initializeControllers() {
    state = state.copyWith(
      nameControllers: [TextEditingController()],
      amountControllers: [TextEditingController()],
      nameFocusNodes: [FocusNode()],
      amountFocusNodes: [FocusNode()],
      seasoningNameControllers: [TextEditingController()],
      seasoningAmountControllers: [TextEditingController()],
      seasoningNameFocusNodes: [FocusNode()],
      seasoningAmountFocusNodes: [FocusNode()],
    );
  }

  void initializeWithExistingIngredients(List<RecipeIngredient>? existingIngredients) {
    if (existingIngredients == null || existingIngredients.isEmpty) {
      return;
    }

    // 既存のコントローラーをクリア
    _clearAllControllers();

    // 食材と調味料に分類
    final (ingredients, seasonings) = _classifyIngredients(existingIngredients);

    // 新しいコントローラーを設定
    _setupIngredientsControllers(ingredients);
    _setupSeasoningsControllers(seasonings);
  }

  void _clearAllControllers() {
    _disposeControllersList(state.nameControllers);
    _disposeControllersList(state.amountControllers);
    _disposeFocusNodesList(state.nameFocusNodes);
    _disposeFocusNodesList(state.amountFocusNodes);
    _disposeControllersList(state.seasoningNameControllers);
    _disposeControllersList(state.seasoningAmountControllers);
    _disposeFocusNodesList(state.seasoningNameFocusNodes);
    _disposeFocusNodesList(state.seasoningAmountFocusNodes);
  }

  void _disposeControllersList(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  void _disposeFocusNodesList(List<FocusNode> focusNodes) {
    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }
  }

  void _setupIngredientsControllers(List<RecipeIngredient> ingredients) {
    final nameControllers = <TextEditingController>[];
    final amountControllers = <TextEditingController>[];
    final nameFocusNodes = <FocusNode>[];
    final amountFocusNodes = <FocusNode>[];

    for (final ingredient in ingredients) {
      nameControllers.add(TextEditingController(text: ingredient.name));
      amountControllers.add(TextEditingController(text: ingredient.amount));
      nameFocusNodes.add(FocusNode());
      amountFocusNodes.add(FocusNode());
    }

    // 最後に空の行を追加
    if (nameControllers.isEmpty) {
      nameControllers.add(TextEditingController());
      amountControllers.add(TextEditingController());
      nameFocusNodes.add(FocusNode());
      amountFocusNodes.add(FocusNode());
    }

    state = state.copyWith(
      nameControllers: nameControllers,
      amountControllers: amountControllers,
      nameFocusNodes: nameFocusNodes,
      amountFocusNodes: amountFocusNodes,
    );
  }

  void _setupSeasoningsControllers(List<RecipeIngredient> seasonings) {
    final nameControllers = <TextEditingController>[];
    final amountControllers = <TextEditingController>[];
    final nameFocusNodes = <FocusNode>[];
    final amountFocusNodes = <FocusNode>[];

    for (final seasoning in seasonings) {
      nameControllers.add(TextEditingController(text: seasoning.name));
      amountControllers.add(TextEditingController(text: seasoning.amount));
      nameFocusNodes.add(FocusNode());
      amountFocusNodes.add(FocusNode());
    }

    // 最後に空の行を追加
    if (nameControllers.isEmpty) {
      nameControllers.add(TextEditingController());
      amountControllers.add(TextEditingController());
      nameFocusNodes.add(FocusNode());
      amountFocusNodes.add(FocusNode());
    }

    state = state.copyWith(
      seasoningNameControllers: nameControllers,
      seasoningAmountControllers: amountControllers,
      seasoningNameFocusNodes: nameFocusNodes,
      seasoningAmountFocusNodes: amountFocusNodes,
    );
  }

  (List<RecipeIngredient>, List<RecipeIngredient>) _classifyIngredients(
    List<RecipeIngredient> allIngredients,
  ) {
    final ingredients = <RecipeIngredient>[];
    final seasonings = <RecipeIngredient>[];

    for (final ingredient in allIngredients) {
      if (_isSeasoningIngredient(ingredient.name)) {
        seasonings.add(ingredient);
      } else {
        ingredients.add(ingredient);
      }
    }

    return (ingredients, seasonings);
  }

  bool _isSeasoningIngredient(String ingredientName) {
    final predefinedIngredient = IngredientData.predefinedIngredients
        .where((item) => item.name == ingredientName)
        .firstOrNull;

    return predefinedIngredient?.category == '調味料';
  }

  void onIngredientNameChanged(String value, int index, IngredientType type) {
    final currentEditingType = type == IngredientType.seasoning 
        ? IngredientType.seasoning 
        : IngredientType.ingredient;

    if (value.isEmpty) {
      state = state.copyWith(
        suggestions: [],
        currentEditingIndex: index,
        currentEditingType: currentEditingType,
      );
    } else {
      final allResults = IngredientData.searchByName(value);
      final filteredSuggestions = _filterIngredientsByType(allResults, type);

      state = state.copyWith(
        suggestions: filteredSuggestions,
        currentEditingIndex: index,
        currentEditingType: currentEditingType,
      );

      _addNewRowIfNeeded(type, index);
    }
  }

  List<Ingredient> _filterIngredientsByType(
    List<Ingredient> allResults,
    IngredientType type,
  ) {
    if (type == IngredientType.seasoning) {
      return allResults
          .where((ingredient) => ingredient.category == '調味料')
          .take(_maxSuggestions)
          .toList();
    } else {
      return allResults
          .where((ingredient) => ingredient.category != '調味料')
          .take(_maxSuggestions)
          .toList();
    }
  }

  void _addNewRowIfNeeded(IngredientType type, int currentIndex) {
    if (type == IngredientType.seasoning) {
      if (currentIndex == state.seasoningNameControllers.length - 1) {
        addNewSeasoningRow();
      }
    } else {
      if (currentIndex == state.nameControllers.length - 1) {
        addNewIngredientRow();
      }
    }
  }

  void onIngredientFieldTap(int index, IngredientType type) {
    final currentEditingType = type == IngredientType.seasoning 
        ? IngredientType.seasoning 
        : IngredientType.ingredient;

    final nameControllers = type == IngredientType.seasoning 
        ? state.seasoningNameControllers 
        : state.nameControllers;

    if (nameControllers[index].text.isNotEmpty) {
      final allResults = IngredientData.searchByName(nameControllers[index].text);
      final filteredSuggestions = _filterIngredientsByType(allResults, type);

      state = state.copyWith(
        suggestions: filteredSuggestions,
        currentEditingIndex: index,
        currentEditingType: currentEditingType,
      );
    } else {
      state = state.copyWith(
        suggestions: [],
        currentEditingIndex: index,
        currentEditingType: currentEditingType,
      );
    }
  }

  void onIngredientFieldTapOutside(int index, IngredientType type) {
    if (state.currentEditingIndex == index && 
        state.currentEditingType == type) {
      state = state.copyWith(
        suggestions: [],
        currentEditingIndex: -1,
      );
    }
  }

  void selectIngredient(Ingredient ingredient, int index) {
    final currentType = state.currentEditingType;

    if (currentType == IngredientType.seasoning) {
      if (index >= state.seasoningNameControllers.length) return;
      state.seasoningNameControllers[index].text = ingredient.name;
    } else {
      if (index >= state.nameControllers.length) return;
      state.nameControllers[index].text = ingredient.name;
    }

    state = state.copyWith(
      suggestions: [],
      currentEditingIndex: -1,
    );

    // フォーカス移動
    Future.delayed(_focusDelay, () {
      if (currentType == IngredientType.seasoning) {
        if (index < state.seasoningAmountFocusNodes.length) {
          state.seasoningAmountFocusNodes[index].requestFocus();
        }
      } else {
        if (index < state.amountFocusNodes.length) {
          state.amountFocusNodes[index].requestFocus();
        }
      }
    });
  }

  void addNewIngredientRow() {
    final newNameControllers = [...state.nameControllers, TextEditingController()];
    final newAmountControllers = [...state.amountControllers, TextEditingController()];
    final newNameFocusNodes = [...state.nameFocusNodes, FocusNode()];
    final newAmountFocusNodes = [...state.amountFocusNodes, FocusNode()];

    state = state.copyWith(
      nameControllers: newNameControllers,
      amountControllers: newAmountControllers,
      nameFocusNodes: newNameFocusNodes,
      amountFocusNodes: newAmountFocusNodes,
    );
  }

  void addNewSeasoningRow() {
    final newNameControllers = [...state.seasoningNameControllers, TextEditingController()];
    final newAmountControllers = [...state.seasoningAmountControllers, TextEditingController()];
    final newNameFocusNodes = [...state.seasoningNameFocusNodes, FocusNode()];
    final newAmountFocusNodes = [...state.seasoningAmountFocusNodes, FocusNode()];

    state = state.copyWith(
      seasoningNameControllers: newNameControllers,
      seasoningAmountControllers: newAmountControllers,
      seasoningNameFocusNodes: newNameFocusNodes,
      seasoningAmountFocusNodes: newAmountFocusNodes,
    );
  }

  void removeIngredientRow(int index) {
    if (state.nameControllers.length <= 1) return;

    state.nameControllers[index].dispose();
    state.amountControllers[index].dispose();
    state.nameFocusNodes[index].dispose();
    state.amountFocusNodes[index].dispose();

    final newNameControllers = [...state.nameControllers]..removeAt(index);
    final newAmountControllers = [...state.amountControllers]..removeAt(index);
    final newNameFocusNodes = [...state.nameFocusNodes]..removeAt(index);
    final newAmountFocusNodes = [...state.amountFocusNodes]..removeAt(index);

    state = state.copyWith(
      nameControllers: newNameControllers,
      amountControllers: newAmountControllers,
      nameFocusNodes: newNameFocusNodes,
      amountFocusNodes: newAmountFocusNodes,
    );

    if (state.currentEditingIndex == index &&
        state.currentEditingType == IngredientType.ingredient) {
      state = state.copyWith(
        suggestions: [],
        currentEditingIndex: -1,
      );
    }
  }

  void removeSeasoningRow(int index) {
    if (state.seasoningNameControllers.length <= 1) return;

    state.seasoningNameControllers[index].dispose();
    state.seasoningAmountControllers[index].dispose();
    state.seasoningNameFocusNodes[index].dispose();
    state.seasoningAmountFocusNodes[index].dispose();

    final newNameControllers = [...state.seasoningNameControllers]..removeAt(index);
    final newAmountControllers = [...state.seasoningAmountControllers]..removeAt(index);
    final newNameFocusNodes = [...state.seasoningNameFocusNodes]..removeAt(index);
    final newAmountFocusNodes = [...state.seasoningAmountFocusNodes]..removeAt(index);

    state = state.copyWith(
      seasoningNameControllers: newNameControllers,
      seasoningAmountControllers: newAmountControllers,
      seasoningNameFocusNodes: newNameFocusNodes,
      seasoningAmountFocusNodes: newAmountFocusNodes,
    );

    if (state.currentEditingIndex == index &&
        state.currentEditingType == IngredientType.seasoning) {
      state = state.copyWith(
        suggestions: [],
        currentEditingIndex: -1,
      );
    }
  }

  List<RecipeIngredient> saveIngredients() {
    final ingredients = <RecipeIngredient>[];

    // 食材を追加
    ingredients.addAll(
      _extractIngredientsFromControllers(
        state.nameControllers, 
        state.amountControllers,
      ),
    );

    // 調味料を追加
    ingredients.addAll(
      _extractIngredientsFromControllers(
        state.seasoningNameControllers,
        state.seasoningAmountControllers,
      ),
    );

    return ingredients;
  }

  List<RecipeIngredient> _extractIngredientsFromControllers(
    List<TextEditingController> nameControllers,
    List<TextEditingController> amountControllers,
  ) {
    final extractedIngredients = <RecipeIngredient>[];

    for (int i = 0; i < nameControllers.length; i++) {
      final name = nameControllers[i].text.trim();
      final amount = amountControllers[i].text.trim();

      if (name.isNotEmpty) {
        final predefinedIngredient = IngredientData.predefinedIngredients
            .where((ingredient) => ingredient.name == name)
            .firstOrNull;

        extractedIngredients.add(
          RecipeIngredient(
            name: name,
            amount: amount,
            iconPath: predefinedIngredient?.iconPath,
            backgroundColor: predefinedIngredient?.backgroundColor,
          ),
        );
      }
    }

    return extractedIngredients;
  }

  @override
  void dispose() {
    _disposeControllersList(state.nameControllers);
    _disposeControllersList(state.amountControllers);
    _disposeFocusNodesList(state.nameFocusNodes);
    _disposeFocusNodesList(state.amountFocusNodes);
    _disposeControllersList(state.seasoningNameControllers);
    _disposeControllersList(state.seasoningAmountControllers);
    _disposeFocusNodesList(state.seasoningNameFocusNodes);
    _disposeFocusNodesList(state.seasoningAmountFocusNodes);
    super.dispose();
  }
}

final ingredientSelectionViewModelProvider = 
    StateNotifierProvider<IngredientSelectionViewModel, IngredientSelectionState>(
  (ref) => IngredientSelectionViewModel(),
);