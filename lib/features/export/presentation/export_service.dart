import 'dart:typed_data';
import 'package:printing/printing.dart';
import '../../../shared/models/notebook_template.dart';
import '../domain/pdf_builder.dart';

class ExportService {
  static Future<void> sharePdf(NotebookTemplate template, {int? pageCount}) async {
    final bytes = await PdfBuilder.build(template, pageCountOverride: pageCount);
    await Printing.sharePdf(
      bytes: Uint8List.fromList(bytes),
      filename: '${template.name}.pdf',
    );
  }
}
