import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// PDF 出力で使う日本語対応フォントを管理するシングルトン。
/// PdfBuilder.build() の冒頭で preload() を呼ぶこと。
class PdfFontStore {
  PdfFontStore._();

  static pw.Font? _ja;

  /// NotoSansJP を Google Fonts からダウンロード＆キャッシュ。
  /// 2回目以降は即時返却。失敗時は PdfFontLoadException をスロー。
  static Future<void> preload() async {
    if (_ja != null) return;
    try {
      _ja = await PdfGoogleFonts.notoSansJPRegular();
    } catch (e) {
      // _ja は null のままにして次回 preload() でリトライ可能にする
      throw PdfFontLoadException(cause: e);
    }
  }

  /// ロード済みの日本語フォント。preload() 前は Helvetica にフォールバック。
  static pw.Font get ja => _ja ?? pw.Font.helvetica();
}

class PdfFontLoadException implements Exception {
  const PdfFontLoadException({required this.cause});
  final Object cause;

  @override
  String toString() =>
      'PDF出力に必要な日本語フォントを取得できませんでした。\nインターネット接続を確認してから再度お試しください。';
}
