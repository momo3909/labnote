// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'layer_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LayerConfig _$LayerConfigFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'grid':
      return GridLayerConfig.fromJson(json);
    case 'hex':
      return HexLayerConfig.fromJson(json);
    case 'isometric':
      return IsometricLayerConfig.fromJson(json);
    case 'region':
      return RegionLayerConfig.fromJson(json);
    case 'guide':
      return GuideLayerConfig.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'runtimeType',
        'LayerConfig',
        'Invalid union type "${json['runtimeType']}"!',
      );
  }
}

/// @nodoc
mixin _$LayerConfig {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )
    grid,
    required TResult Function(double hexSizeMm, HexOrientation orientation) hex,
    required TResult Function(double spacingMm) isometric,
    required TResult Function(List<PageRegion> regions) region,
    required TResult Function(GuideType guideType, Map<String, dynamic> params)
    guide,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult? Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult? Function(double spacingMm)? isometric,
    TResult? Function(List<PageRegion> regions)? region,
    TResult? Function(GuideType guideType, Map<String, dynamic> params)? guide,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult Function(double spacingMm)? isometric,
    TResult Function(List<PageRegion> regions)? region,
    TResult Function(GuideType guideType, Map<String, dynamic> params)? guide,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GridLayerConfig value) grid,
    required TResult Function(HexLayerConfig value) hex,
    required TResult Function(IsometricLayerConfig value) isometric,
    required TResult Function(RegionLayerConfig value) region,
    required TResult Function(GuideLayerConfig value) guide,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GridLayerConfig value)? grid,
    TResult? Function(HexLayerConfig value)? hex,
    TResult? Function(IsometricLayerConfig value)? isometric,
    TResult? Function(RegionLayerConfig value)? region,
    TResult? Function(GuideLayerConfig value)? guide,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GridLayerConfig value)? grid,
    TResult Function(HexLayerConfig value)? hex,
    TResult Function(IsometricLayerConfig value)? isometric,
    TResult Function(RegionLayerConfig value)? region,
    TResult Function(GuideLayerConfig value)? guide,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this LayerConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LayerConfigCopyWith<$Res> {
  factory $LayerConfigCopyWith(
    LayerConfig value,
    $Res Function(LayerConfig) then,
  ) = _$LayerConfigCopyWithImpl<$Res, LayerConfig>;
}

/// @nodoc
class _$LayerConfigCopyWithImpl<$Res, $Val extends LayerConfig>
    implements $LayerConfigCopyWith<$Res> {
  _$LayerConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GridLayerConfigImplCopyWith<$Res> {
  factory _$$GridLayerConfigImplCopyWith(
    _$GridLayerConfigImpl value,
    $Res Function(_$GridLayerConfigImpl) then,
  ) = __$$GridLayerConfigImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    double cellWidthMm,
    double cellHeightMm,
    LineStyle lineStyle,
    int? boldEvery,
    bool showHorizontal,
    bool showVertical,
  });
}

/// @nodoc
class __$$GridLayerConfigImplCopyWithImpl<$Res>
    extends _$LayerConfigCopyWithImpl<$Res, _$GridLayerConfigImpl>
    implements _$$GridLayerConfigImplCopyWith<$Res> {
  __$$GridLayerConfigImplCopyWithImpl(
    _$GridLayerConfigImpl _value,
    $Res Function(_$GridLayerConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cellWidthMm = null,
    Object? cellHeightMm = null,
    Object? lineStyle = null,
    Object? boldEvery = freezed,
    Object? showHorizontal = null,
    Object? showVertical = null,
  }) {
    return _then(
      _$GridLayerConfigImpl(
        cellWidthMm: null == cellWidthMm
            ? _value.cellWidthMm
            : cellWidthMm // ignore: cast_nullable_to_non_nullable
                  as double,
        cellHeightMm: null == cellHeightMm
            ? _value.cellHeightMm
            : cellHeightMm // ignore: cast_nullable_to_non_nullable
                  as double,
        lineStyle: null == lineStyle
            ? _value.lineStyle
            : lineStyle // ignore: cast_nullable_to_non_nullable
                  as LineStyle,
        boldEvery: freezed == boldEvery
            ? _value.boldEvery
            : boldEvery // ignore: cast_nullable_to_non_nullable
                  as int?,
        showHorizontal: null == showHorizontal
            ? _value.showHorizontal
            : showHorizontal // ignore: cast_nullable_to_non_nullable
                  as bool,
        showVertical: null == showVertical
            ? _value.showVertical
            : showVertical // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GridLayerConfigImpl implements GridLayerConfig {
  const _$GridLayerConfigImpl({
    this.cellWidthMm = 5.0,
    this.cellHeightMm = 5.0,
    this.lineStyle = LineStyle.solid,
    this.boldEvery,
    this.showHorizontal = true,
    this.showVertical = true,
    final String? $type,
  }) : $type = $type ?? 'grid';

  factory _$GridLayerConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$GridLayerConfigImplFromJson(json);

  @override
  @JsonKey()
  final double cellWidthMm;
  @override
  @JsonKey()
  final double cellHeightMm;
  @override
  @JsonKey()
  final LineStyle lineStyle;
  @override
  final int? boldEvery;
  @override
  @JsonKey()
  final bool showHorizontal;
  @override
  @JsonKey()
  final bool showVertical;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'LayerConfig.grid(cellWidthMm: $cellWidthMm, cellHeightMm: $cellHeightMm, lineStyle: $lineStyle, boldEvery: $boldEvery, showHorizontal: $showHorizontal, showVertical: $showVertical)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GridLayerConfigImpl &&
            (identical(other.cellWidthMm, cellWidthMm) ||
                other.cellWidthMm == cellWidthMm) &&
            (identical(other.cellHeightMm, cellHeightMm) ||
                other.cellHeightMm == cellHeightMm) &&
            (identical(other.lineStyle, lineStyle) ||
                other.lineStyle == lineStyle) &&
            (identical(other.boldEvery, boldEvery) ||
                other.boldEvery == boldEvery) &&
            (identical(other.showHorizontal, showHorizontal) ||
                other.showHorizontal == showHorizontal) &&
            (identical(other.showVertical, showVertical) ||
                other.showVertical == showVertical));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    cellWidthMm,
    cellHeightMm,
    lineStyle,
    boldEvery,
    showHorizontal,
    showVertical,
  );

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GridLayerConfigImplCopyWith<_$GridLayerConfigImpl> get copyWith =>
      __$$GridLayerConfigImplCopyWithImpl<_$GridLayerConfigImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )
    grid,
    required TResult Function(double hexSizeMm, HexOrientation orientation) hex,
    required TResult Function(double spacingMm) isometric,
    required TResult Function(List<PageRegion> regions) region,
    required TResult Function(GuideType guideType, Map<String, dynamic> params)
    guide,
  }) {
    return grid(
      cellWidthMm,
      cellHeightMm,
      lineStyle,
      boldEvery,
      showHorizontal,
      showVertical,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult? Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult? Function(double spacingMm)? isometric,
    TResult? Function(List<PageRegion> regions)? region,
    TResult? Function(GuideType guideType, Map<String, dynamic> params)? guide,
  }) {
    return grid?.call(
      cellWidthMm,
      cellHeightMm,
      lineStyle,
      boldEvery,
      showHorizontal,
      showVertical,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult Function(double spacingMm)? isometric,
    TResult Function(List<PageRegion> regions)? region,
    TResult Function(GuideType guideType, Map<String, dynamic> params)? guide,
    required TResult orElse(),
  }) {
    if (grid != null) {
      return grid(
        cellWidthMm,
        cellHeightMm,
        lineStyle,
        boldEvery,
        showHorizontal,
        showVertical,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GridLayerConfig value) grid,
    required TResult Function(HexLayerConfig value) hex,
    required TResult Function(IsometricLayerConfig value) isometric,
    required TResult Function(RegionLayerConfig value) region,
    required TResult Function(GuideLayerConfig value) guide,
  }) {
    return grid(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GridLayerConfig value)? grid,
    TResult? Function(HexLayerConfig value)? hex,
    TResult? Function(IsometricLayerConfig value)? isometric,
    TResult? Function(RegionLayerConfig value)? region,
    TResult? Function(GuideLayerConfig value)? guide,
  }) {
    return grid?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GridLayerConfig value)? grid,
    TResult Function(HexLayerConfig value)? hex,
    TResult Function(IsometricLayerConfig value)? isometric,
    TResult Function(RegionLayerConfig value)? region,
    TResult Function(GuideLayerConfig value)? guide,
    required TResult orElse(),
  }) {
    if (grid != null) {
      return grid(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GridLayerConfigImplToJson(this);
  }
}

abstract class GridLayerConfig implements LayerConfig {
  const factory GridLayerConfig({
    final double cellWidthMm,
    final double cellHeightMm,
    final LineStyle lineStyle,
    final int? boldEvery,
    final bool showHorizontal,
    final bool showVertical,
  }) = _$GridLayerConfigImpl;

  factory GridLayerConfig.fromJson(Map<String, dynamic> json) =
      _$GridLayerConfigImpl.fromJson;

  double get cellWidthMm;
  double get cellHeightMm;
  LineStyle get lineStyle;
  int? get boldEvery;
  bool get showHorizontal;
  bool get showVertical;

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GridLayerConfigImplCopyWith<_$GridLayerConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$HexLayerConfigImplCopyWith<$Res> {
  factory _$$HexLayerConfigImplCopyWith(
    _$HexLayerConfigImpl value,
    $Res Function(_$HexLayerConfigImpl) then,
  ) = __$$HexLayerConfigImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double hexSizeMm, HexOrientation orientation});
}

/// @nodoc
class __$$HexLayerConfigImplCopyWithImpl<$Res>
    extends _$LayerConfigCopyWithImpl<$Res, _$HexLayerConfigImpl>
    implements _$$HexLayerConfigImplCopyWith<$Res> {
  __$$HexLayerConfigImplCopyWithImpl(
    _$HexLayerConfigImpl _value,
    $Res Function(_$HexLayerConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hexSizeMm = null, Object? orientation = null}) {
    return _then(
      _$HexLayerConfigImpl(
        hexSizeMm: null == hexSizeMm
            ? _value.hexSizeMm
            : hexSizeMm // ignore: cast_nullable_to_non_nullable
                  as double,
        orientation: null == orientation
            ? _value.orientation
            : orientation // ignore: cast_nullable_to_non_nullable
                  as HexOrientation,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HexLayerConfigImpl implements HexLayerConfig {
  const _$HexLayerConfigImpl({
    this.hexSizeMm = 5.0,
    this.orientation = HexOrientation.flat,
    final String? $type,
  }) : $type = $type ?? 'hex';

  factory _$HexLayerConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$HexLayerConfigImplFromJson(json);

  @override
  @JsonKey()
  final double hexSizeMm;
  @override
  @JsonKey()
  final HexOrientation orientation;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'LayerConfig.hex(hexSizeMm: $hexSizeMm, orientation: $orientation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HexLayerConfigImpl &&
            (identical(other.hexSizeMm, hexSizeMm) ||
                other.hexSizeMm == hexSizeMm) &&
            (identical(other.orientation, orientation) ||
                other.orientation == orientation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hexSizeMm, orientation);

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HexLayerConfigImplCopyWith<_$HexLayerConfigImpl> get copyWith =>
      __$$HexLayerConfigImplCopyWithImpl<_$HexLayerConfigImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )
    grid,
    required TResult Function(double hexSizeMm, HexOrientation orientation) hex,
    required TResult Function(double spacingMm) isometric,
    required TResult Function(List<PageRegion> regions) region,
    required TResult Function(GuideType guideType, Map<String, dynamic> params)
    guide,
  }) {
    return hex(hexSizeMm, orientation);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult? Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult? Function(double spacingMm)? isometric,
    TResult? Function(List<PageRegion> regions)? region,
    TResult? Function(GuideType guideType, Map<String, dynamic> params)? guide,
  }) {
    return hex?.call(hexSizeMm, orientation);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult Function(double spacingMm)? isometric,
    TResult Function(List<PageRegion> regions)? region,
    TResult Function(GuideType guideType, Map<String, dynamic> params)? guide,
    required TResult orElse(),
  }) {
    if (hex != null) {
      return hex(hexSizeMm, orientation);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GridLayerConfig value) grid,
    required TResult Function(HexLayerConfig value) hex,
    required TResult Function(IsometricLayerConfig value) isometric,
    required TResult Function(RegionLayerConfig value) region,
    required TResult Function(GuideLayerConfig value) guide,
  }) {
    return hex(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GridLayerConfig value)? grid,
    TResult? Function(HexLayerConfig value)? hex,
    TResult? Function(IsometricLayerConfig value)? isometric,
    TResult? Function(RegionLayerConfig value)? region,
    TResult? Function(GuideLayerConfig value)? guide,
  }) {
    return hex?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GridLayerConfig value)? grid,
    TResult Function(HexLayerConfig value)? hex,
    TResult Function(IsometricLayerConfig value)? isometric,
    TResult Function(RegionLayerConfig value)? region,
    TResult Function(GuideLayerConfig value)? guide,
    required TResult orElse(),
  }) {
    if (hex != null) {
      return hex(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$HexLayerConfigImplToJson(this);
  }
}

abstract class HexLayerConfig implements LayerConfig {
  const factory HexLayerConfig({
    final double hexSizeMm,
    final HexOrientation orientation,
  }) = _$HexLayerConfigImpl;

  factory HexLayerConfig.fromJson(Map<String, dynamic> json) =
      _$HexLayerConfigImpl.fromJson;

  double get hexSizeMm;
  HexOrientation get orientation;

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HexLayerConfigImplCopyWith<_$HexLayerConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$IsometricLayerConfigImplCopyWith<$Res> {
  factory _$$IsometricLayerConfigImplCopyWith(
    _$IsometricLayerConfigImpl value,
    $Res Function(_$IsometricLayerConfigImpl) then,
  ) = __$$IsometricLayerConfigImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double spacingMm});
}

/// @nodoc
class __$$IsometricLayerConfigImplCopyWithImpl<$Res>
    extends _$LayerConfigCopyWithImpl<$Res, _$IsometricLayerConfigImpl>
    implements _$$IsometricLayerConfigImplCopyWith<$Res> {
  __$$IsometricLayerConfigImplCopyWithImpl(
    _$IsometricLayerConfigImpl _value,
    $Res Function(_$IsometricLayerConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? spacingMm = null}) {
    return _then(
      _$IsometricLayerConfigImpl(
        spacingMm: null == spacingMm
            ? _value.spacingMm
            : spacingMm // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IsometricLayerConfigImpl implements IsometricLayerConfig {
  const _$IsometricLayerConfigImpl({this.spacingMm = 5.0, final String? $type})
    : $type = $type ?? 'isometric';

  factory _$IsometricLayerConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$IsometricLayerConfigImplFromJson(json);

  @override
  @JsonKey()
  final double spacingMm;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'LayerConfig.isometric(spacingMm: $spacingMm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IsometricLayerConfigImpl &&
            (identical(other.spacingMm, spacingMm) ||
                other.spacingMm == spacingMm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, spacingMm);

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IsometricLayerConfigImplCopyWith<_$IsometricLayerConfigImpl>
  get copyWith =>
      __$$IsometricLayerConfigImplCopyWithImpl<_$IsometricLayerConfigImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )
    grid,
    required TResult Function(double hexSizeMm, HexOrientation orientation) hex,
    required TResult Function(double spacingMm) isometric,
    required TResult Function(List<PageRegion> regions) region,
    required TResult Function(GuideType guideType, Map<String, dynamic> params)
    guide,
  }) {
    return isometric(spacingMm);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult? Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult? Function(double spacingMm)? isometric,
    TResult? Function(List<PageRegion> regions)? region,
    TResult? Function(GuideType guideType, Map<String, dynamic> params)? guide,
  }) {
    return isometric?.call(spacingMm);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult Function(double spacingMm)? isometric,
    TResult Function(List<PageRegion> regions)? region,
    TResult Function(GuideType guideType, Map<String, dynamic> params)? guide,
    required TResult orElse(),
  }) {
    if (isometric != null) {
      return isometric(spacingMm);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GridLayerConfig value) grid,
    required TResult Function(HexLayerConfig value) hex,
    required TResult Function(IsometricLayerConfig value) isometric,
    required TResult Function(RegionLayerConfig value) region,
    required TResult Function(GuideLayerConfig value) guide,
  }) {
    return isometric(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GridLayerConfig value)? grid,
    TResult? Function(HexLayerConfig value)? hex,
    TResult? Function(IsometricLayerConfig value)? isometric,
    TResult? Function(RegionLayerConfig value)? region,
    TResult? Function(GuideLayerConfig value)? guide,
  }) {
    return isometric?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GridLayerConfig value)? grid,
    TResult Function(HexLayerConfig value)? hex,
    TResult Function(IsometricLayerConfig value)? isometric,
    TResult Function(RegionLayerConfig value)? region,
    TResult Function(GuideLayerConfig value)? guide,
    required TResult orElse(),
  }) {
    if (isometric != null) {
      return isometric(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$IsometricLayerConfigImplToJson(this);
  }
}

abstract class IsometricLayerConfig implements LayerConfig {
  const factory IsometricLayerConfig({final double spacingMm}) =
      _$IsometricLayerConfigImpl;

  factory IsometricLayerConfig.fromJson(Map<String, dynamic> json) =
      _$IsometricLayerConfigImpl.fromJson;

  double get spacingMm;

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IsometricLayerConfigImplCopyWith<_$IsometricLayerConfigImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RegionLayerConfigImplCopyWith<$Res> {
  factory _$$RegionLayerConfigImplCopyWith(
    _$RegionLayerConfigImpl value,
    $Res Function(_$RegionLayerConfigImpl) then,
  ) = __$$RegionLayerConfigImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<PageRegion> regions});
}

/// @nodoc
class __$$RegionLayerConfigImplCopyWithImpl<$Res>
    extends _$LayerConfigCopyWithImpl<$Res, _$RegionLayerConfigImpl>
    implements _$$RegionLayerConfigImplCopyWith<$Res> {
  __$$RegionLayerConfigImplCopyWithImpl(
    _$RegionLayerConfigImpl _value,
    $Res Function(_$RegionLayerConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? regions = null}) {
    return _then(
      _$RegionLayerConfigImpl(
        regions: null == regions
            ? _value._regions
            : regions // ignore: cast_nullable_to_non_nullable
                  as List<PageRegion>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegionLayerConfigImpl implements RegionLayerConfig {
  const _$RegionLayerConfigImpl({
    final List<PageRegion> regions = const [],
    final String? $type,
  }) : _regions = regions,
       $type = $type ?? 'region';

  factory _$RegionLayerConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegionLayerConfigImplFromJson(json);

  final List<PageRegion> _regions;
  @override
  @JsonKey()
  List<PageRegion> get regions {
    if (_regions is EqualUnmodifiableListView) return _regions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_regions);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'LayerConfig.region(regions: $regions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegionLayerConfigImpl &&
            const DeepCollectionEquality().equals(other._regions, _regions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_regions));

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegionLayerConfigImplCopyWith<_$RegionLayerConfigImpl> get copyWith =>
      __$$RegionLayerConfigImplCopyWithImpl<_$RegionLayerConfigImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )
    grid,
    required TResult Function(double hexSizeMm, HexOrientation orientation) hex,
    required TResult Function(double spacingMm) isometric,
    required TResult Function(List<PageRegion> regions) region,
    required TResult Function(GuideType guideType, Map<String, dynamic> params)
    guide,
  }) {
    return region(regions);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult? Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult? Function(double spacingMm)? isometric,
    TResult? Function(List<PageRegion> regions)? region,
    TResult? Function(GuideType guideType, Map<String, dynamic> params)? guide,
  }) {
    return region?.call(regions);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult Function(double spacingMm)? isometric,
    TResult Function(List<PageRegion> regions)? region,
    TResult Function(GuideType guideType, Map<String, dynamic> params)? guide,
    required TResult orElse(),
  }) {
    if (region != null) {
      return region(regions);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GridLayerConfig value) grid,
    required TResult Function(HexLayerConfig value) hex,
    required TResult Function(IsometricLayerConfig value) isometric,
    required TResult Function(RegionLayerConfig value) region,
    required TResult Function(GuideLayerConfig value) guide,
  }) {
    return region(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GridLayerConfig value)? grid,
    TResult? Function(HexLayerConfig value)? hex,
    TResult? Function(IsometricLayerConfig value)? isometric,
    TResult? Function(RegionLayerConfig value)? region,
    TResult? Function(GuideLayerConfig value)? guide,
  }) {
    return region?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GridLayerConfig value)? grid,
    TResult Function(HexLayerConfig value)? hex,
    TResult Function(IsometricLayerConfig value)? isometric,
    TResult Function(RegionLayerConfig value)? region,
    TResult Function(GuideLayerConfig value)? guide,
    required TResult orElse(),
  }) {
    if (region != null) {
      return region(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$RegionLayerConfigImplToJson(this);
  }
}

abstract class RegionLayerConfig implements LayerConfig {
  const factory RegionLayerConfig({final List<PageRegion> regions}) =
      _$RegionLayerConfigImpl;

  factory RegionLayerConfig.fromJson(Map<String, dynamic> json) =
      _$RegionLayerConfigImpl.fromJson;

  List<PageRegion> get regions;

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegionLayerConfigImplCopyWith<_$RegionLayerConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GuideLayerConfigImplCopyWith<$Res> {
  factory _$$GuideLayerConfigImplCopyWith(
    _$GuideLayerConfigImpl value,
    $Res Function(_$GuideLayerConfigImpl) then,
  ) = __$$GuideLayerConfigImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GuideType guideType, Map<String, dynamic> params});
}

/// @nodoc
class __$$GuideLayerConfigImplCopyWithImpl<$Res>
    extends _$LayerConfigCopyWithImpl<$Res, _$GuideLayerConfigImpl>
    implements _$$GuideLayerConfigImplCopyWith<$Res> {
  __$$GuideLayerConfigImplCopyWithImpl(
    _$GuideLayerConfigImpl _value,
    $Res Function(_$GuideLayerConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? guideType = null, Object? params = null}) {
    return _then(
      _$GuideLayerConfigImpl(
        guideType: null == guideType
            ? _value.guideType
            : guideType // ignore: cast_nullable_to_non_nullable
                  as GuideType,
        params: null == params
            ? _value._params
            : params // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GuideLayerConfigImpl implements GuideLayerConfig {
  const _$GuideLayerConfigImpl({
    required this.guideType,
    final Map<String, dynamic> params = const {},
    final String? $type,
  }) : _params = params,
       $type = $type ?? 'guide';

  factory _$GuideLayerConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$GuideLayerConfigImplFromJson(json);

  @override
  final GuideType guideType;
  final Map<String, dynamic> _params;
  @override
  @JsonKey()
  Map<String, dynamic> get params {
    if (_params is EqualUnmodifiableMapView) return _params;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_params);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'LayerConfig.guide(guideType: $guideType, params: $params)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GuideLayerConfigImpl &&
            (identical(other.guideType, guideType) ||
                other.guideType == guideType) &&
            const DeepCollectionEquality().equals(other._params, _params));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    guideType,
    const DeepCollectionEquality().hash(_params),
  );

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GuideLayerConfigImplCopyWith<_$GuideLayerConfigImpl> get copyWith =>
      __$$GuideLayerConfigImplCopyWithImpl<_$GuideLayerConfigImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )
    grid,
    required TResult Function(double hexSizeMm, HexOrientation orientation) hex,
    required TResult Function(double spacingMm) isometric,
    required TResult Function(List<PageRegion> regions) region,
    required TResult Function(GuideType guideType, Map<String, dynamic> params)
    guide,
  }) {
    return guide(guideType, params);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult? Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult? Function(double spacingMm)? isometric,
    TResult? Function(List<PageRegion> regions)? region,
    TResult? Function(GuideType guideType, Map<String, dynamic> params)? guide,
  }) {
    return guide?.call(guideType, params);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      double cellWidthMm,
      double cellHeightMm,
      LineStyle lineStyle,
      int? boldEvery,
      bool showHorizontal,
      bool showVertical,
    )?
    grid,
    TResult Function(double hexSizeMm, HexOrientation orientation)? hex,
    TResult Function(double spacingMm)? isometric,
    TResult Function(List<PageRegion> regions)? region,
    TResult Function(GuideType guideType, Map<String, dynamic> params)? guide,
    required TResult orElse(),
  }) {
    if (guide != null) {
      return guide(guideType, params);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GridLayerConfig value) grid,
    required TResult Function(HexLayerConfig value) hex,
    required TResult Function(IsometricLayerConfig value) isometric,
    required TResult Function(RegionLayerConfig value) region,
    required TResult Function(GuideLayerConfig value) guide,
  }) {
    return guide(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GridLayerConfig value)? grid,
    TResult? Function(HexLayerConfig value)? hex,
    TResult? Function(IsometricLayerConfig value)? isometric,
    TResult? Function(RegionLayerConfig value)? region,
    TResult? Function(GuideLayerConfig value)? guide,
  }) {
    return guide?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GridLayerConfig value)? grid,
    TResult Function(HexLayerConfig value)? hex,
    TResult Function(IsometricLayerConfig value)? isometric,
    TResult Function(RegionLayerConfig value)? region,
    TResult Function(GuideLayerConfig value)? guide,
    required TResult orElse(),
  }) {
    if (guide != null) {
      return guide(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GuideLayerConfigImplToJson(this);
  }
}

abstract class GuideLayerConfig implements LayerConfig {
  const factory GuideLayerConfig({
    required final GuideType guideType,
    final Map<String, dynamic> params,
  }) = _$GuideLayerConfigImpl;

  factory GuideLayerConfig.fromJson(Map<String, dynamic> json) =
      _$GuideLayerConfigImpl.fromJson;

  GuideType get guideType;
  Map<String, dynamic> get params;

  /// Create a copy of LayerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GuideLayerConfigImplCopyWith<_$GuideLayerConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PageRegion _$PageRegionFromJson(Map<String, dynamic> json) {
  return _PageRegion.fromJson(json);
}

/// @nodoc
mixin _$PageRegion {
  double get xRatio => throw _privateConstructorUsedError;
  double get yRatio => throw _privateConstructorUsedError;
  double get widthRatio => throw _privateConstructorUsedError;
  double get heightRatio => throw _privateConstructorUsedError;
  LayerConfig get layerConfig => throw _privateConstructorUsedError;

  /// Serializes this PageRegion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PageRegion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageRegionCopyWith<PageRegion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageRegionCopyWith<$Res> {
  factory $PageRegionCopyWith(
    PageRegion value,
    $Res Function(PageRegion) then,
  ) = _$PageRegionCopyWithImpl<$Res, PageRegion>;
  @useResult
  $Res call({
    double xRatio,
    double yRatio,
    double widthRatio,
    double heightRatio,
    LayerConfig layerConfig,
  });

  $LayerConfigCopyWith<$Res> get layerConfig;
}

/// @nodoc
class _$PageRegionCopyWithImpl<$Res, $Val extends PageRegion>
    implements $PageRegionCopyWith<$Res> {
  _$PageRegionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageRegion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? xRatio = null,
    Object? yRatio = null,
    Object? widthRatio = null,
    Object? heightRatio = null,
    Object? layerConfig = null,
  }) {
    return _then(
      _value.copyWith(
            xRatio: null == xRatio
                ? _value.xRatio
                : xRatio // ignore: cast_nullable_to_non_nullable
                      as double,
            yRatio: null == yRatio
                ? _value.yRatio
                : yRatio // ignore: cast_nullable_to_non_nullable
                      as double,
            widthRatio: null == widthRatio
                ? _value.widthRatio
                : widthRatio // ignore: cast_nullable_to_non_nullable
                      as double,
            heightRatio: null == heightRatio
                ? _value.heightRatio
                : heightRatio // ignore: cast_nullable_to_non_nullable
                      as double,
            layerConfig: null == layerConfig
                ? _value.layerConfig
                : layerConfig // ignore: cast_nullable_to_non_nullable
                      as LayerConfig,
          )
          as $Val,
    );
  }

  /// Create a copy of PageRegion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayerConfigCopyWith<$Res> get layerConfig {
    return $LayerConfigCopyWith<$Res>(_value.layerConfig, (value) {
      return _then(_value.copyWith(layerConfig: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PageRegionImplCopyWith<$Res>
    implements $PageRegionCopyWith<$Res> {
  factory _$$PageRegionImplCopyWith(
    _$PageRegionImpl value,
    $Res Function(_$PageRegionImpl) then,
  ) = __$$PageRegionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double xRatio,
    double yRatio,
    double widthRatio,
    double heightRatio,
    LayerConfig layerConfig,
  });

  @override
  $LayerConfigCopyWith<$Res> get layerConfig;
}

/// @nodoc
class __$$PageRegionImplCopyWithImpl<$Res>
    extends _$PageRegionCopyWithImpl<$Res, _$PageRegionImpl>
    implements _$$PageRegionImplCopyWith<$Res> {
  __$$PageRegionImplCopyWithImpl(
    _$PageRegionImpl _value,
    $Res Function(_$PageRegionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PageRegion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? xRatio = null,
    Object? yRatio = null,
    Object? widthRatio = null,
    Object? heightRatio = null,
    Object? layerConfig = null,
  }) {
    return _then(
      _$PageRegionImpl(
        xRatio: null == xRatio
            ? _value.xRatio
            : xRatio // ignore: cast_nullable_to_non_nullable
                  as double,
        yRatio: null == yRatio
            ? _value.yRatio
            : yRatio // ignore: cast_nullable_to_non_nullable
                  as double,
        widthRatio: null == widthRatio
            ? _value.widthRatio
            : widthRatio // ignore: cast_nullable_to_non_nullable
                  as double,
        heightRatio: null == heightRatio
            ? _value.heightRatio
            : heightRatio // ignore: cast_nullable_to_non_nullable
                  as double,
        layerConfig: null == layerConfig
            ? _value.layerConfig
            : layerConfig // ignore: cast_nullable_to_non_nullable
                  as LayerConfig,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PageRegionImpl implements _PageRegion {
  const _$PageRegionImpl({
    required this.xRatio,
    required this.yRatio,
    required this.widthRatio,
    required this.heightRatio,
    required this.layerConfig,
  });

  factory _$PageRegionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PageRegionImplFromJson(json);

  @override
  final double xRatio;
  @override
  final double yRatio;
  @override
  final double widthRatio;
  @override
  final double heightRatio;
  @override
  final LayerConfig layerConfig;

  @override
  String toString() {
    return 'PageRegion(xRatio: $xRatio, yRatio: $yRatio, widthRatio: $widthRatio, heightRatio: $heightRatio, layerConfig: $layerConfig)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageRegionImpl &&
            (identical(other.xRatio, xRatio) || other.xRatio == xRatio) &&
            (identical(other.yRatio, yRatio) || other.yRatio == yRatio) &&
            (identical(other.widthRatio, widthRatio) ||
                other.widthRatio == widthRatio) &&
            (identical(other.heightRatio, heightRatio) ||
                other.heightRatio == heightRatio) &&
            (identical(other.layerConfig, layerConfig) ||
                other.layerConfig == layerConfig));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    xRatio,
    yRatio,
    widthRatio,
    heightRatio,
    layerConfig,
  );

  /// Create a copy of PageRegion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageRegionImplCopyWith<_$PageRegionImpl> get copyWith =>
      __$$PageRegionImplCopyWithImpl<_$PageRegionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PageRegionImplToJson(this);
  }
}

abstract class _PageRegion implements PageRegion {
  const factory _PageRegion({
    required final double xRatio,
    required final double yRatio,
    required final double widthRatio,
    required final double heightRatio,
    required final LayerConfig layerConfig,
  }) = _$PageRegionImpl;

  factory _PageRegion.fromJson(Map<String, dynamic> json) =
      _$PageRegionImpl.fromJson;

  @override
  double get xRatio;
  @override
  double get yRatio;
  @override
  double get widthRatio;
  @override
  double get heightRatio;
  @override
  LayerConfig get layerConfig;

  /// Create a copy of PageRegion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageRegionImplCopyWith<_$PageRegionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
