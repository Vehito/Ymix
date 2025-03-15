import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/wallet_manager.dart';
import 'package:ymix/models/wallet.dart';
import 'package:ymix/ui/shared/build_form.dart';

class WalletForm extends StatefulWidget {
  const WalletForm(this.wallet, {super.key});

  static const routeName = "/wallet_form";

  final Wallet? wallet;

  @override
  State<WalletForm> createState() => _WalletFormState();
}

class _WalletFormState extends State<WalletForm> {
  final _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color _formColor = Colors.white54;

  double? _balance;
  String? _name;
  String? _description;

  @override
  void initState() {
    final originalWallet = widget.wallet;
    if (originalWallet != null) {
      _controller.text = originalWallet.id!;
      _name = originalWallet.name;
      _balance = originalWallet.balance;
      _description = originalWallet.description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet == null ? "Add Wallet" : "Edit Wallet"),
        actions: [
          IconButton(onPressed: _submitForm, icon: const Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Name
                buildTextForm(_name, 'Wallet\'s Name *', _formColor,
                    (newValue) => _name = newValue),
                // Balance
                buildAmountForm(_balance, 'Balance *', _formColor,
                    (newValue) => _balance = newValue),
                // Description
                buildTextForm(_description, 'Description', _formColor,
                    (newValue) => _description = newValue,
                    isTextArea: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    final id = widget.wallet?.id;
    id == null
        ? await context
            .read<WalletManager>()
            .addWallet(_name!, _balance!, _description)
        : await context.read<WalletManager>().editWallet(
            id: id, name: _name, balance: _balance, description: _description);
    if (mounted) Navigator.pop(context);
  }
}
