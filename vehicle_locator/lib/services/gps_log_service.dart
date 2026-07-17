import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class GpsLogService {
  GpsLogService._();

  static File? _file;

  static Future<File> _getFile() async {
    if (_file != null) return _file!;

    final dir = await getApplicationDocumentsDirectory();

    final path = p.join(
      dir.path,
      'gps_log.txt',
    );

    _file = File(path);

    if (!await _file!.exists()) {
      await _file!.create(recursive: true);
    }

    return _file!;
  }
	
	static Future<String> getFilePath() async {
		final file = await _getFile();
		return file.path;
	}	

  static Future<void> write(String text) async {
    try {
      final file = await _getFile();

      await file.writeAsString(
        '$text\n',
        mode: FileMode.append,
      );
    } catch (_) {}
  }

  static Future<void> clear() async {
    try {
      final file = await _getFile();

      await file.writeAsString('');
    } catch (_) {}
  }
}