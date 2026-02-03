import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetBalanceScreen extends StatefulWidget {
  final VoidCallback onBalanceSet;

  const SetBalanceScreen({Key? key, required this.onBalanceSet}) : super(key: key);

  @override
  _SetBalanceScreenState createState() => _SetBalanceScreenState();
}

class _SetBalanceScreenState extends State<SetBalanceScreen> {
  final _balanceController = TextEditingController();

  void _saveBalance() async {
    final balance = double.tryParse(_balanceController.text);
    if (balance != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('monthly_balance', balance);
      widget.onBalanceSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Monthly Balance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter your monthly balance',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveBalance,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
