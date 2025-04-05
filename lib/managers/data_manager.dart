import 'package:flutter/widgets.dart';
import 'package:ymix/services/data_service.dart';

class DataManager with ChangeNotifier {
  static final DataManager _instance = DataManager._internal();
  static DataManager get instance => _instance;

  DataManager._internal();
  final DataService _dataService = DataService.instance;

  Future<String> exportDatabaseToDevice() async {
    return await _dataService.exportDatabase();
  }
}
