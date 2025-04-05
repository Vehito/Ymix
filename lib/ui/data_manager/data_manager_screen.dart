import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/data_manager.dart';
import '../shared/dialog_utils.dart';

class DataManagerScreen extends StatelessWidget {
  static const routeName = '/data_manager';
  const DataManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Manager'),
      ),
      body: ListView(
        children: [
          _buildListTile(
              title: 'Export to zip file',
              subtitle: 'Saved at Download/ymix_data.zip',
              trailing: IconButton(
                  onPressed: () async {
                    final message = await context
                        .read<DataManager>()
                        .exportDatabaseToDevice();
                    if (context.mounted) {
                      showSnackBar(message: message, context: context);
                    }
                  },
                  icon: const Icon(Icons.archive)))
        ],
      ),
    );
  }

  Widget _buildListTile(
      {required String title,
      String? subtitle,
      Widget? leading,
      Widget? trailing}) {
    return Card(
        child: ListTile(
      title: Text(title),
      trailing: trailing,
      leading: leading,
      subtitle: subtitle == null ? null : Text(subtitle),
    ));
  }
}
