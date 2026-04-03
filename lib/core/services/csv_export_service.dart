import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';

class CsvExportService {
  Future<String?> export({
    required String suggestedName,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [
        const XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );

    if (location == null) return null;

    final buffer = StringBuffer();
    buffer.writeln(headers.map(_escape).join(','));
    for (final row in rows) {
      buffer.writeln(row.map(_escape).join(','));
    }

    final file = File(location.path);
    await file.writeAsString(buffer.toString(), encoding: utf8);
    return file.path;
  }

  String _escape(String value) {
    final escaped = value.replaceAll('"', '""');
    if (escaped.contains(',') || escaped.contains('"') || escaped.contains('\n')) {
      return '"$escaped"';
    }
    return escaped;
  }
}
