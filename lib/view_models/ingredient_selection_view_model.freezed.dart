// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_selection_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$IngredientSelectionState {
  List<Ingredient> get suggestions => throw _privateConstructorUsedError;
  int get currentEditingIndex => throw _privateConstructorUsedError;
  IngredientType get currentEditingType => throw _privateConstructorUsedError;
  List<TextEditingController> get nameControllers =>
      throw _privateConstructorUsedError;
  List<TextEditingController> get amountControllers =>
      throw _privateConstructorUsedError;
  List<FocusNode> get nameFocusNodes => throw _privateConstructorUsedError;
  List<FocusNode> get amountFocusNodes => throw _privateConstructorUsedError;
  List<TextEditingController> get seasoningNameControllers =>
      throw _privateConstructorUsedError;
  List<TextEditingController> get seasoningAmountControllers =>
      throw _privateConstructorUsedError;
  List<FocusNode> get seasoningNameFocusNodes =>
      throw _privateConstructorUsedError;
  List<FocusNode> get seasoningAmountFocusNodes =>
      throw _privateConstructorUsedError;

  /// Create a copy of IngredientSelectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IngredientSelectionStateCopyWith<IngredientSelectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientSelectionStateCopyWith<$Res> {
  factory $IngredientSelectionStateCopyWith(
    IngredientSelectionState value,
    $Res Function(IngredientSelectionState) then,
  ) = _$IngredientSelectionStateCopyWithImpl<$Res, IngredientSelectionState>;
  @useResult
  $Res call({
    List<Ingredient> suggestions,
    int currentEditingIndex,
    IngredientType currentEditingType,
    List<TextEditingController> nameControllers,
    List<TextEditingController> amountControllers,
    List<FocusNode> nameFocusNodes,
    List<FocusNode> amountFocusNodes,
    List<TextEditingController> seasoningNameControllers,
    List<TextEditingController> seasoningAmountControllers,
    List<FocusNode> seasoningNameFocusNodes,
    List<FocusNode> seasoningAmountFocusNodes,
  });
}

/// @nodoc
class _$IngredientSelectionStateCopyWithImpl<
  $Res,
  $Val extends IngredientSelectionState
>
    implements $IngredientSelectionStateCopyWith<$Res> {
  _$IngredientSelectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IngredientSelectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestions = null,
    Object? currentEditingIndex = null,
    Object? currentEditingType = null,
    Object? nameControllers = null,
    Object? amountControllers = null,
    Object? nameFocusNodes = null,
    Object? amountFocusNodes = null,
    Object? seasoningNameControllers = null,
    Object? seasoningAmountControllers = null,
    Object? seasoningNameFocusNodes = null,
    Object? seasoningAmountFocusNodes = null,
  }) {
    return _then(
      _value.copyWith(
            suggestions:
                null == suggestions
                    ? _value.suggestions
                    : suggestions // ignore: cast_nullable_to_non_nullable
                        as List<Ingredient>,
            currentEditingIndex:
                null == currentEditingIndex
                    ? _value.currentEditingIndex
                    : currentEditingIndex // ignore: cast_nullable_to_non_nullable
                        as int,
            currentEditingType:
                null == currentEditingType
                    ? _value.currentEditingType
                    : currentEditingType // ignore: cast_nullable_to_non_nullable
                        as IngredientType,
            nameControllers:
                null == nameControllers
                    ? _value.nameControllers
                    : nameControllers // ignore: cast_nullable_to_non_nullable
                        as List<TextEditingController>,
            amountControllers:
                null == amountControllers
                    ? _value.amountControllers
                    : amountControllers // ignore: cast_nullable_to_non_nullable
                        as List<TextEditingController>,
            nameFocusNodes:
                null == nameFocusNodes
                    ? _value.nameFocusNodes
                    : nameFocusNodes // ignore: cast_nullable_to_non_nullable
                        as List<FocusNode>,
            amountFocusNodes:
                null == amountFocusNodes
                    ? _value.amountFocusNodes
                    : amountFocusNodes // ignore: cast_nullable_to_non_nullable
                        as List<FocusNode>,
            seasoningNameControllers:
                null == seasoningNameControllers
                    ? _value.seasoningNameControllers
                    : seasoningNameControllers // ignore: cast_nullable_to_non_nullable
                        as List<TextEditingController>,
            seasoningAmountControllers:
                null == seasoningAmountControllers
                    ? _value.seasoningAmountControllers
                    : seasoningAmountControllers // ignore: cast_nullable_to_non_nullable
                        as List<TextEditingController>,
            seasoningNameFocusNodes:
                null == seasoningNameFocusNodes
                    ? _value.seasoningNameFocusNodes
                    : seasoningNameFocusNodes // ignore: cast_nullable_to_non_nullable
                        as List<FocusNode>,
            seasoningAmountFocusNodes:
                null == seasoningAmountFocusNodes
                    ? _value.seasoningAmountFocusNodes
                    : seasoningAmountFocusNodes // ignore: cast_nullable_to_non_nullable
                        as List<FocusNode>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IngredientSelectionStateImplCopyWith<$Res>
    implements $IngredientSelectionStateCopyWith<$Res> {
  factory _$$IngredientSelectionStateImplCopyWith(
    _$IngredientSelectionStateImpl value,
    $Res Function(_$IngredientSelectionStateImpl) then,
  ) = __$$IngredientSelectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Ingredient> suggestions,
    int currentEditingIndex,
    IngredientType currentEditingType,
    List<TextEditingController> nameControllers,
    List<TextEditingController> amountControllers,
    List<FocusNode> nameFocusNodes,
    List<FocusNode> amountFocusNodes,
    List<TextEditingController> seasoningNameControllers,
    List<TextEditingController> seasoningAmountControllers,
    List<FocusNode> seasoningNameFocusNodes,
    List<FocusNode> seasoningAmountFocusNodes,
  });
}

/// @nodoc
class __$$IngredientSelectionStateImplCopyWithImpl<$Res>
    extends
        _$IngredientSelectionStateCopyWithImpl<
          $Res,
          _$IngredientSelectionStateImpl
        >
    implements _$$IngredientSelectionStateImplCopyWith<$Res> {
  __$$IngredientSelectionStateImplCopyWithImpl(
    _$IngredientSelectionStateImpl _value,
    $Res Function(_$IngredientSelectionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IngredientSelectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestions = null,
    Object? currentEditingIndex = null,
    Object? currentEditingType = null,
    Object? nameControllers = null,
    Object? amountControllers = null,
    Object? nameFocusNodes = null,
    Object? amountFocusNodes = null,
    Object? seasoningNameControllers = null,
    Object? seasoningAmountControllers = null,
    Object? seasoningNameFocusNodes = null,
    Object? seasoningAmountFocusNodes = null,
  }) {
    return _then(
      _$IngredientSelectionStateImpl(
        suggestions:
            null == suggestions
                ? _value._suggestions
                : suggestions // ignore: cast_nullable_to_non_nullable
                    as List<Ingredient>,
        currentEditingIndex:
            null == currentEditingIndex
                ? _value.currentEditingIndex
                : currentEditingIndex // ignore: cast_nullable_to_non_nullable
                    as int,
        currentEditingType:
            null == currentEditingType
                ? _value.currentEditingType
                : currentEditingType // ignore: cast_nullable_to_non_nullable
                    as IngredientType,
        nameControllers:
            null == nameControllers
                ? _value._nameControllers
                : nameControllers // ignore: cast_nullable_to_non_nullable
                    as List<TextEditingController>,
        amountControllers:
            null == amountControllers
                ? _value._amountControllers
                : amountControllers // ignore: cast_nullable_to_non_nullable
                    as List<TextEditingController>,
        nameFocusNodes:
            null == nameFocusNodes
                ? _value._nameFocusNodes
                : nameFocusNodes // ignore: cast_nullable_to_non_nullable
                    as List<FocusNode>,
        amountFocusNodes:
            null == amountFocusNodes
                ? _value._amountFocusNodes
                : amountFocusNodes // ignore: cast_nullable_to_non_nullable
                    as List<FocusNode>,
        seasoningNameControllers:
            null == seasoningNameControllers
                ? _value._seasoningNameControllers
                : seasoningNameControllers // ignore: cast_nullable_to_non_nullable
                    as List<TextEditingController>,
        seasoningAmountControllers:
            null == seasoningAmountControllers
                ? _value._seasoningAmountControllers
                : seasoningAmountControllers // ignore: cast_nullable_to_non_nullable
                    as List<TextEditingController>,
        seasoningNameFocusNodes:
            null == seasoningNameFocusNodes
                ? _value._seasoningNameFocusNodes
                : seasoningNameFocusNodes // ignore: cast_nullable_to_non_nullable
                    as List<FocusNode>,
        seasoningAmountFocusNodes:
            null == seasoningAmountFocusNodes
                ? _value._seasoningAmountFocusNodes
                : seasoningAmountFocusNodes // ignore: cast_nullable_to_non_nullable
                    as List<FocusNode>,
      ),
    );
  }
}

/// @nodoc

class _$IngredientSelectionStateImpl implements _IngredientSelectionState {
  const _$IngredientSelectionStateImpl({
    final List<Ingredient> suggestions = const [],
    this.currentEditingIndex = -1,
    this.currentEditingType = IngredientType.ingredient,
    final List<TextEditingController> nameControllers = const [],
    final List<TextEditingController> amountControllers = const [],
    final List<FocusNode> nameFocusNodes = const [],
    final List<FocusNode> amountFocusNodes = const [],
    final List<TextEditingController> seasoningNameControllers = const [],
    final List<TextEditingController> seasoningAmountControllers = const [],
    final List<FocusNode> seasoningNameFocusNodes = const [],
    final List<FocusNode> seasoningAmountFocusNodes = const [],
  }) : _suggestions = suggestions,
       _nameControllers = nameControllers,
       _amountControllers = amountControllers,
       _nameFocusNodes = nameFocusNodes,
       _amountFocusNodes = amountFocusNodes,
       _seasoningNameControllers = seasoningNameControllers,
       _seasoningAmountControllers = seasoningAmountControllers,
       _seasoningNameFocusNodes = seasoningNameFocusNodes,
       _seasoningAmountFocusNodes = seasoningAmountFocusNodes;

  final List<Ingredient> _suggestions;
  @override
  @JsonKey()
  List<Ingredient> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  @JsonKey()
  final int currentEditingIndex;
  @override
  @JsonKey()
  final IngredientType currentEditingType;
  final List<TextEditingController> _nameControllers;
  @override
  @JsonKey()
  List<TextEditingController> get nameControllers {
    if (_nameControllers is EqualUnmodifiableListView) return _nameControllers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nameControllers);
  }

  final List<TextEditingController> _amountControllers;
  @override
  @JsonKey()
  List<TextEditingController> get amountControllers {
    if (_amountControllers is EqualUnmodifiableListView)
      return _amountControllers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amountControllers);
  }

  final List<FocusNode> _nameFocusNodes;
  @override
  @JsonKey()
  List<FocusNode> get nameFocusNodes {
    if (_nameFocusNodes is EqualUnmodifiableListView) return _nameFocusNodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nameFocusNodes);
  }

  final List<FocusNode> _amountFocusNodes;
  @override
  @JsonKey()
  List<FocusNode> get amountFocusNodes {
    if (_amountFocusNodes is EqualUnmodifiableListView)
      return _amountFocusNodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amountFocusNodes);
  }

  final List<TextEditingController> _seasoningNameControllers;
  @override
  @JsonKey()
  List<TextEditingController> get seasoningNameControllers {
    if (_seasoningNameControllers is EqualUnmodifiableListView)
      return _seasoningNameControllers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasoningNameControllers);
  }

  final List<TextEditingController> _seasoningAmountControllers;
  @override
  @JsonKey()
  List<TextEditingController> get seasoningAmountControllers {
    if (_seasoningAmountControllers is EqualUnmodifiableListView)
      return _seasoningAmountControllers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasoningAmountControllers);
  }

  final List<FocusNode> _seasoningNameFocusNodes;
  @override
  @JsonKey()
  List<FocusNode> get seasoningNameFocusNodes {
    if (_seasoningNameFocusNodes is EqualUnmodifiableListView)
      return _seasoningNameFocusNodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasoningNameFocusNodes);
  }

  final List<FocusNode> _seasoningAmountFocusNodes;
  @override
  @JsonKey()
  List<FocusNode> get seasoningAmountFocusNodes {
    if (_seasoningAmountFocusNodes is EqualUnmodifiableListView)
      return _seasoningAmountFocusNodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasoningAmountFocusNodes);
  }

  @override
  String toString() {
    return 'IngredientSelectionState(suggestions: $suggestions, currentEditingIndex: $currentEditingIndex, currentEditingType: $currentEditingType, nameControllers: $nameControllers, amountControllers: $amountControllers, nameFocusNodes: $nameFocusNodes, amountFocusNodes: $amountFocusNodes, seasoningNameControllers: $seasoningNameControllers, seasoningAmountControllers: $seasoningAmountControllers, seasoningNameFocusNodes: $seasoningNameFocusNodes, seasoningAmountFocusNodes: $seasoningAmountFocusNodes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientSelectionStateImpl &&
            const DeepCollectionEquality().equals(
              other._suggestions,
              _suggestions,
            ) &&
            (identical(other.currentEditingIndex, currentEditingIndex) ||
                other.currentEditingIndex == currentEditingIndex) &&
            (identical(other.currentEditingType, currentEditingType) ||
                other.currentEditingType == currentEditingType) &&
            const DeepCollectionEquality().equals(
              other._nameControllers,
              _nameControllers,
            ) &&
            const DeepCollectionEquality().equals(
              other._amountControllers,
              _amountControllers,
            ) &&
            const DeepCollectionEquality().equals(
              other._nameFocusNodes,
              _nameFocusNodes,
            ) &&
            const DeepCollectionEquality().equals(
              other._amountFocusNodes,
              _amountFocusNodes,
            ) &&
            const DeepCollectionEquality().equals(
              other._seasoningNameControllers,
              _seasoningNameControllers,
            ) &&
            const DeepCollectionEquality().equals(
              other._seasoningAmountControllers,
              _seasoningAmountControllers,
            ) &&
            const DeepCollectionEquality().equals(
              other._seasoningNameFocusNodes,
              _seasoningNameFocusNodes,
            ) &&
            const DeepCollectionEquality().equals(
              other._seasoningAmountFocusNodes,
              _seasoningAmountFocusNodes,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_suggestions),
    currentEditingIndex,
    currentEditingType,
    const DeepCollectionEquality().hash(_nameControllers),
    const DeepCollectionEquality().hash(_amountControllers),
    const DeepCollectionEquality().hash(_nameFocusNodes),
    const DeepCollectionEquality().hash(_amountFocusNodes),
    const DeepCollectionEquality().hash(_seasoningNameControllers),
    const DeepCollectionEquality().hash(_seasoningAmountControllers),
    const DeepCollectionEquality().hash(_seasoningNameFocusNodes),
    const DeepCollectionEquality().hash(_seasoningAmountFocusNodes),
  );

  /// Create a copy of IngredientSelectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientSelectionStateImplCopyWith<_$IngredientSelectionStateImpl>
  get copyWith => __$$IngredientSelectionStateImplCopyWithImpl<
    _$IngredientSelectionStateImpl
  >(this, _$identity);
}

abstract class _IngredientSelectionState implements IngredientSelectionState {
  const factory _IngredientSelectionState({
    final List<Ingredient> suggestions,
    final int currentEditingIndex,
    final IngredientType currentEditingType,
    final List<TextEditingController> nameControllers,
    final List<TextEditingController> amountControllers,
    final List<FocusNode> nameFocusNodes,
    final List<FocusNode> amountFocusNodes,
    final List<TextEditingController> seasoningNameControllers,
    final List<TextEditingController> seasoningAmountControllers,
    final List<FocusNode> seasoningNameFocusNodes,
    final List<FocusNode> seasoningAmountFocusNodes,
  }) = _$IngredientSelectionStateImpl;

  @override
  List<Ingredient> get suggestions;
  @override
  int get currentEditingIndex;
  @override
  IngredientType get currentEditingType;
  @override
  List<TextEditingController> get nameControllers;
  @override
  List<TextEditingController> get amountControllers;
  @override
  List<FocusNode> get nameFocusNodes;
  @override
  List<FocusNode> get amountFocusNodes;
  @override
  List<TextEditingController> get seasoningNameControllers;
  @override
  List<TextEditingController> get seasoningAmountControllers;
  @override
  List<FocusNode> get seasoningNameFocusNodes;
  @override
  List<FocusNode> get seasoningAmountFocusNodes;

  /// Create a copy of IngredientSelectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IngredientSelectionStateImplCopyWith<_$IngredientSelectionStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
