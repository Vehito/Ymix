import 'dart:io';
import 'dart:typed_data';
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

  // Future<File> _zipFiles(List<File> files, String zipPath) async {
  //   final archive = Archive();

  //   for (File file in files) {
  //     final fileName = file.path.split('/').last;
  //     final fileBytes = await file.readAsBytes();
  //     archive.addFile(ArchiveFile(fileName, fileBytes.length, fileBytes));
  //   }

  //   final zipData = ZipEncoder().encode(archive);

  //   final zipFile = File(zipPath);

  //   // Nếu file đã tồn tại, xóa đi trước
  //   if (await zipFile.exists()) {
  //     try {
  //       await zipFile.delete();
  //     } catch (e) {
  //       throw Exception("Không thể xóa file cũ: $e");
  //     }
  //   }
  //   await zipFile.writeAsBytes(zipData);

  //   return zipFile;
  // }

  Future<File> _zipFilesAndSave(List<File> files, String zipFileName) async {
    final archive = Archive();

    for (File file in files) {
      final fileName = file.path.split('/').last;
      final fileBytes = await file.readAsBytes();
      archive.addFile(ArchiveFile(fileName, fileBytes.length, fileBytes));
    }

    final zipData = ZipEncoder().encode(archive);

    // Lưu zip vào thư mục "Download"
    await saveFileToDownload(Uint8List.fromList(zipData), zipFileName);

    return File(zipFileName); // Hoặc trả về đường dẫn của file
  }

  Future<void> saveFileToDownload(Uint8List data, String fileName) async {
    try {
      final directory = Directory('/storage/emulated/0/Download');
      if (!(await directory.exists())) {
        print("Directory does not exist!");
        return;
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await file.writeAsBytes(data);
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  Future<Directory?> _upZip({required File zipFile}) async {
    try {
      final temDir = await getTemporaryDirectory();
      final unzipDir = Directory('${temDir.path}/unziped_db');
      if (unzipDir.existsSync()) {
        unzipDir.deleteSync(recursive: true);
      }
      unzipDir.createSync(recursive: true);

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final outPath = '${unzipDir.path}/${file.name}';
        if (file.isFile) {
          File(outPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(file.content as List<int>);
        }
      }
      return unzipDir;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _isValidDBFile(String path) async {
    try {
      final db = await openDatabase(path, readOnly: true);
      final result = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type = 'table';");
      await db.close();
      return result.isNotEmpty;
    } catch (e) {
      print("Không hợp lệ: $e");
      return false;
    }
  }

  Future<List<File>> getDatabaseFiles() async {
    final String dbPath = await getDatabasesPath();
    final Directory dbDir = Directory(dbPath);

    if (!dbDir.existsSync()) {
      print("Thư mục db không tồn tại: $dbPath");
      return [];
    }
    List<File> dbFiles = dbDir.listSync().whereType<File>().where((file) {
      return file.path.endsWith('.db');
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

      await _zipFilesAndSave(dbFiles, 'ymix_database.zip');

      return 'Saved at Download/ymix_database.zip';
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

      final zipPath = selectedFile.files.single.path!;
      final zipFile = File(zipPath);

      final unzipDir = await _upZip(zipFile: zipFile);
      if (unzipDir == null) {
        return "Can't unzip selected file";
      }

      final dbFiles = unzipDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.db'))
          .toList();
      if (dbFiles.isEmpty) return 'There no file .db';

      for (var file in dbFiles) {
        final isValid = await _isValidDBFile(file.path);
        if (!isValid) {
          return 'File ${file.path.split('/').last} is not valid';
        }
      }

      final dbDir = await getDatabaseDirectory();
      if (!dbDir.existsSync()) {
        dbDir.createSync(recursive: true);
      }
      dbDir.listSync().whereType<File>().forEach((f) => f.deleteSync());

      for (final file in dbFiles) {
        final fileName = file.path.split('/').last;
        await file.copy('${dbDir.path}/$fileName');
      }

      final dbPath = '${dbDir.path}/${dbFiles.first.path.split('/').last}';
      final db = await openDatabase(dbPath, readOnly: false);
      final tables = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'");
      print('Tables in imported DB: $tables');
      await db.close();

      return 'Import successfully';
    } catch (e) {
      return 'Lỗi khi import db: $e';
    }
  }
}
