// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_book_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RecipeBookState {
  List<RecipeBook> get recipeBooks => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of RecipeBookState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeBookStateCopyWith<RecipeBookState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeBookStateCopyWith<$Res> {
  factory $RecipeBookStateCopyWith(
    RecipeBookState value,
    $Res Function(RecipeBookState) then,
  ) = _$RecipeBookStateCopyWithImpl<$Res, RecipeBookState>;
  @useResult
  $Res call({
    List<RecipeBook> recipeBooks,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class _$RecipeBookStateCopyWithImpl<$Res, $Val extends RecipeBookState>
    implements $RecipeBookStateCopyWith<$Res> {
  _$RecipeBookStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeBookState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipeBooks = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            recipeBooks:
                null == recipeBooks
                    ? _value.recipeBooks
                    : recipeBooks // ignore: cast_nullable_to_non_nullable
                        as List<RecipeBook>,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeBookStateImplCopyWith<$Res>
    implements $RecipeBookStateCopyWith<$Res> {
  factory _$$RecipeBookStateImplCopyWith(
    _$RecipeBookStateImpl value,
    $Res Function(_$RecipeBookStateImpl) then,
  ) = __$$RecipeBookStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<RecipeBook> recipeBooks,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$RecipeBookStateImplCopyWithImpl<$Res>
    extends _$RecipeBookStateCopyWithImpl<$Res, _$RecipeBookStateImpl>
    implements _$$RecipeBookStateImplCopyWith<$Res> {
  __$$RecipeBookStateImplCopyWithImpl(
    _$RecipeBookStateImpl _value,
    $Res Function(_$RecipeBookStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecipeBookState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipeBooks = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$RecipeBookStateImpl(
        recipeBooks:
            null == recipeBooks
                ? _value._recipeBooks
                : recipeBooks // ignore: cast_nullable_to_non_nullable
                    as List<RecipeBook>,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$RecipeBookStateImpl implements _RecipeBookState {
  const _$RecipeBookStateImpl({
    final List<RecipeBook> recipeBooks = const [],
    this.isLoading = false,
    this.errorMessage,
  }) : _recipeBooks = recipeBooks;

  final List<RecipeBook> _recipeBooks;
  @override
  @JsonKey()
  List<RecipeBook> get recipeBooks {
    if (_recipeBooks is EqualUnmodifiableListView) return _recipeBooks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipeBooks);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'RecipeBookState(recipeBooks: $recipeBooks, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeBookStateImpl &&
            const DeepCollectionEquality().equals(
              other._recipeBooks,
              _recipeBooks,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_recipeBooks),
    isLoading,
    errorMessage,
  );

  /// Create a copy of RecipeBookState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeBookStateImplCopyWith<_$RecipeBookStateImpl> get copyWith =>
      __$$RecipeBookStateImplCopyWithImpl<_$RecipeBookStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RecipeBookState implements RecipeBookState {
  const factory _RecipeBookState({
    final List<RecipeBook> recipeBooks,
    final bool isLoading,
    final String? errorMessage,
  }) = _$RecipeBookStateImpl;

  @override
  List<RecipeBook> get recipeBooks;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of RecipeBookState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeBookStateImplCopyWith<_$RecipeBookStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
