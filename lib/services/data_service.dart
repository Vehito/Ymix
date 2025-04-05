import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive_io.dart';

class DataService {
  static final DataService instance = DataService._internal();
  DataService._internal();

  Future<Directory> getDatabaseDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory dbDir = Directory('${appDir.path}/databases');

    if (!dbDir.existsSync()) {
      print("Database directory not found: ${dbDir.path}");
    }

    return dbDir;
  }

  Future<File> _zipFiles(List<File> files, String zipPath) async {
    final archive = Archive();
    for (File file in files) {
      final fileName = file.path.split('/').last;
      final fileBytes = await file.readAsBytes();

      archive.addFile(ArchiveFile(fileName, fileBytes.length, fileBytes));
    }
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(zipData);

    return zipFile;
  }

  Future<List<File>> getDatabaseFiles() async {
    final String dbPath = await getDatabasesPath();
    final Directory dbDir = Directory(dbPath);

    if (!dbDir.existsSync()) {
      print("Thư mục db không tồn tại: $dbPath");
      return [];
    }
    List<File> dbFiles = dbDir.listSync().whereType<File>().where((file) {
      return file.path.endsWith('.db'); // Chỉ lấy file .db
    }).toList();

    return dbFiles;
  }

  Future<String> exportDatabase() async {
    try {
      if (await Permission.storage.request().isDenied) {
        return "Bạn chưa cấp quyền truy cập bộ nhớ ngoài!";
      }

      final List<File> dbFiles = await getDatabaseFiles();
      if (dbFiles.isEmpty) {
        return "Không tìm thấy file database";
      }

      final targetDir = Directory('/storage/emulated/0/Download');
      if (!(await targetDir.exists())) {
        return "Can't access Download";
      }

      final zipPath = '${targetDir.path}/ymix_data.zip';
      await _zipFiles(dbFiles, zipPath);
      return 'Saved at Download/ymix_data.zip';
    } catch (e) {
      return "Lỗi khi xuất database: $e";
    }
  }

  Future<String> importZipDB() async {
    try {
      if (await Permission.storage.request().isDenied) {
        return "Bạn chưa cấp quyền truy cập bộ nhớ ngoài!";
      }
      final selectedFile = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
      if (selectedFile == null || selectedFile.files.single.path == null) {
        return 'There is no selected file.zip';
      }

      return 'Import successfully';
    } catch (e) {
      return 'Lỗi khi import db: $e';
    }
  }
}
