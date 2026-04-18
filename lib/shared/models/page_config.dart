import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_config.freezed.dart';
part 'page_config.g.dart';

enum PaperSize { a4, b5 }
enum PaperOrientation { portrait, landscape }
enum HoleConfig { none, h26, h30 }

@freezed
class PageConfig with _$PageConfig {
  const factory PageConfig({
    @Default(PaperSize.a4) PaperSize paperSize,
    @Default(PaperOrientation.portrait) PaperOrientation orientation,
    @Default(10.0) double marginTopMm,
    @Default(10.0) double marginBottomMm,
    @Default(10.0) double marginLeftMm,
    @Default(10.0) double marginRightMm,
    @Default(HoleConfig.h26) HoleConfig holeConfig,
    @Default(1) int pageCount,
  }) = _PageConfig;

  factory PageConfig.fromJson(Map<String, dynamic> json) =>
      _$PageConfigFromJson(json);
}
